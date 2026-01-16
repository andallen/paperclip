//
// MemoryManager.swift
// InkOS
//
// Manages the hierarchical long-term memory system.
// Handles loading and saving memory nodes via Firestore.
// Uses local caching for offline support.
//

import Foundation

// MARK: - MemoryStorageProtocol

// Protocol for memory storage backends.
// Allows swapping between Firestore, mock storage, or local-only storage.
protocol MemoryStorageProtocol: Sendable {
  // Fetches memory nodes matching path prefixes.
  func fetchNodes(userId: String, pathPrefixes: [String]) async throws -> [MemoryNode]

  // Saves a memory node.
  func saveNode(userId: String, node: MemoryNode) async throws

  // Deletes a memory node.
  func deleteNode(userId: String, path: String) async throws
}

// MARK: - MemoryAPIClientProtocol

// Protocol for memory subagent API client.
protocol MemoryAPIClientProtocol: Sendable {
  // Calls the memory update endpoint.
  func updateMemory(request: MemoryUpdateRequest) async throws -> MemoryUpdateResponse
}

// MARK: - MemoryManager

// Actor that manages long-term memory operations.
// Coordinates between local storage and the memory subagent.
actor MemoryManager: MemoryManagerProtocol {
  private let storage: MemoryStorageProtocol
  private let apiClient: MemoryAPIClientProtocol
  private let userId: String

  // Cache of loaded memory nodes for quick access.
  private var cachedNodes: [String: MemoryNode] = [:]

  // Last update timestamp for cache invalidation.
  private var lastCacheUpdate: Date?

  // Cache expiration time (5 minutes).
  private let cacheExpiration: TimeInterval = 300

  init(
    storage: MemoryStorageProtocol,
    apiClient: MemoryAPIClientProtocol,
    userId: String
  ) {
    self.storage = storage
    self.apiClient = apiClient
    self.userId = userId
  }

  // MARK: - MemoryManagerProtocol

  // Loads memory nodes matching the given path prefixes.
  // Always includes root/ and pedagogy/ for context.
  func loadNodes(pathPrefixes: [String]) async throws -> [MemoryNode] {
    // Always load root and pedagogy for full context.
    var allPrefixes = Set(["root", "pedagogy"])
    allPrefixes.formUnion(pathPrefixes)

    // Check cache validity.
    if let lastUpdate = lastCacheUpdate,
      Date().timeIntervalSince(lastUpdate) < cacheExpiration
    {
      // Return cached nodes that match prefixes.
      return cachedNodes.values.filter { node in
        allPrefixes.contains { prefix in
          node.path.hasPrefix(prefix)
        }
      }
    }

    // Fetch from storage.
    let nodes = try await storage.fetchNodes(
      userId: userId,
      pathPrefixes: Array(allPrefixes)
    )

    // Update cache.
    cachedNodes = Dictionary(uniqueKeysWithValues: nodes.map { ($0.path, $0) })
    lastCacheUpdate = Date()

    return nodes
  }

  // Applies updates from the memory subagent to storage.
  func applyUpdates(_ updates: [MemoryNodeUpdate], sessionId: String) async throws {
    for update in updates {
      switch update.operation {
      case .create:
        // Create new node.
        let node = MemoryNode(
          path: update.path,
          content: update.content,
          confidence: max(0, min(1, update.confidenceDelta)),
          lastUpdated: Date(),
          updateCount: 1,
          sourceSessionIds: [sessionId]
        )
        try await storage.saveNode(userId: userId, node: node)
        cachedNodes[update.path] = node

      case .update:
        // Update existing node with new content.
        if var existing = cachedNodes[update.path] {
          let updatedNode = MemoryNode(
            path: existing.path,
            content: update.content,
            confidence: max(0, min(1, existing.confidence + update.confidenceDelta)),
            lastUpdated: Date(),
            updateCount: existing.updateCount + 1,
            sourceSessionIds: existing.sourceSessionIds + [sessionId]
          )
          try await storage.saveNode(userId: userId, node: updatedNode)
          cachedNodes[update.path] = updatedNode
        } else {
          // Node doesn't exist locally, create it.
          let node = MemoryNode(
            path: update.path,
            content: update.content,
            confidence: max(0, min(1, update.confidenceDelta)),
            lastUpdated: Date(),
            updateCount: 1,
            sourceSessionIds: [sessionId]
          )
          try await storage.saveNode(userId: userId, node: node)
          cachedNodes[update.path] = node
        }

      case .reinforce:
        // Reinforce existing node without changing content.
        if var existing = cachedNodes[update.path] {
          let updatedNode = MemoryNode(
            path: existing.path,
            content: existing.content,
            confidence: max(0, min(1, existing.confidence + update.confidenceDelta)),
            lastUpdated: Date(),
            updateCount: existing.updateCount + 1,
            sourceSessionIds: existing.sourceSessionIds + [sessionId]
          )
          try await storage.saveNode(userId: userId, node: updatedNode)
          cachedNodes[update.path] = updatedNode
        }
      }
    }
  }

  // Formats memory for inclusion in Alan's system prompt.
  func formatForAlan(nodes: [MemoryNode]) -> String {
    if nodes.isEmpty {
      return ""
    }

    var sections: [String] = []

    // Group nodes by category.
    let rootNodes = nodes.filter { $0.path.hasPrefix("root/") }
    let subjectNodes = nodes.filter { $0.path.hasPrefix("subjects/") }
    let pedagogyNodes = nodes.filter { $0.path.hasPrefix("pedagogy/") }

    // Format root nodes (About This Student).
    if !rootNodes.isEmpty {
      var aboutSection = "### About This Student\n"
      for node in rootNodes.sorted(by: { $0.path < $1.path }) {
        aboutSection += "- \(node.content)\n"
      }
      sections.append(aboutSection)
    }

    // Format subject nodes (Subject Knowledge).
    if !subjectNodes.isEmpty {
      var subjectSection = "### Subject Knowledge\n"
      for node in subjectNodes.sorted(by: { $0.path < $1.path }) {
        // Extract concept name from path (last component).
        let conceptName = node.path.components(separatedBy: "/").last ?? node.path
        let formattedName = conceptName.replacingOccurrences(of: "_", with: " ").capitalized
        subjectSection += "- \(formattedName): \(node.content)\n"
      }
      sections.append(subjectSection)
    }

    // Format pedagogy nodes (Teaching Preferences).
    if !pedagogyNodes.isEmpty {
      var pedagogySection = "### Teaching Preferences\n"
      for node in pedagogyNodes.sorted(by: { $0.path < $1.path }) {
        pedagogySection += "- \(node.content)\n"
      }
      sections.append(pedagogySection)
    }

    if sections.isEmpty {
      return ""
    }

    return "## Long-term Memory\n\n" + sections.joined(separator: "\n")
  }

  // Triggers a memory update by calling the memory subagent.
  func triggerUpdate(sessionModel: SessionModel, metadata: SessionMetadata) async throws {
    // Load relevant memory for context.
    let nodes = try await loadNodes(pathPrefixes: metadata.topicsCovered)

    // Build update request.
    let request = MemoryUpdateRequest(
      userId: userId,
      sessionModel: sessionModel,
      sessionMetadata: metadata,
      currentMemory: nodes
    )

    // Call memory subagent.
    let response = try await apiClient.updateMemory(request: request)

    // Apply updates.
    try await applyUpdates(response.updates, sessionId: sessionModel.sessionId)
  }

  // MARK: - Cache Management

  // Clears the memory cache.
  func clearCache() {
    cachedNodes.removeAll()
    lastCacheUpdate = nil
  }

  // Returns cached nodes without fetching.
  func getCachedNodes() -> [MemoryNode] {
    Array(cachedNodes.values)
  }
}

// MARK: - MockMemoryStorage

// Mock storage for testing and development.
final class MockMemoryStorage: MemoryStorageProtocol, @unchecked Sendable {
  private var nodes: [String: [String: MemoryNode]] = [:]  // userId -> path -> node
  private let lock = NSLock()

  func fetchNodes(userId: String, pathPrefixes: [String]) async throws -> [MemoryNode] {
    lock.lock()
    defer { lock.unlock() }

    guard let userNodes = nodes[userId] else {
      return []
    }

    return userNodes.values.filter { node in
      pathPrefixes.contains { prefix in
        node.path.hasPrefix(prefix)
      }
    }
  }

  func saveNode(userId: String, node: MemoryNode) async throws {
    lock.lock()
    defer { lock.unlock() }

    if nodes[userId] == nil {
      nodes[userId] = [:]
    }
    nodes[userId]?[node.path] = node
  }

  func deleteNode(userId: String, path: String) async throws {
    lock.lock()
    defer { lock.unlock() }

    nodes[userId]?[path] = nil
  }

  // Helper for testing.
  func setNodes(userId: String, nodes: [MemoryNode]) {
    lock.lock()
    defer { lock.unlock() }

    self.nodes[userId] = Dictionary(uniqueKeysWithValues: nodes.map { ($0.path, $0) })
  }
}

// MARK: - MockMemoryAPIClient

// Mock API client for testing.
final class MockMemoryAPIClient: MemoryAPIClientProtocol, @unchecked Sendable {
  var mockResponse: MemoryUpdateResponse?
  var mockError: Error?

  func updateMemory(request: MemoryUpdateRequest) async throws -> MemoryUpdateResponse {
    if let error = mockError {
      throw error
    }
    return mockResponse ?? MemoryUpdateResponse(updates: [])
  }
}

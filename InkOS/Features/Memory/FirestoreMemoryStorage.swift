//
// FirestoreMemoryStorage.swift
// InkOS
//
// Firestore-backed storage for memory nodes.
// Provides persistence with offline support via the Firestore SDK.
//

import FirebaseFirestore
import Foundation

// MARK: - FirestoreMemoryStorage

// Firestore-backed memory storage.
// Uses the Firestore SDK for persistence with automatic offline caching.
final class FirestoreMemoryStorage: MemoryStorageProtocol, @unchecked Sendable {
  private let lock = NSLock()

  // Date formatter for ISO8601 dates.
  private let dateFormatter: ISO8601DateFormatter = {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    return formatter
  }()

  init() {
    // Configure Firestore for offline persistence.
    let settings = FirestoreSettings()
    settings.cacheSettings = PersistentCacheSettings()
    Firestore.firestore().settings = settings
  }

  // MARK: - MemoryStorageProtocol

  func fetchNodes(userId: String, pathPrefixes: [String]) async throws -> [MemoryNode] {
    let db = Firestore.firestore()
    let collectionRef = db.collection("users").document(userId).collection("memory")

    var allNodes: [MemoryNode] = []

    // Fetch nodes for each prefix.
    for prefix in pathPrefixes {
      let query = collectionRef
        .whereField("path", isGreaterThanOrEqualTo: prefix)
        .whereField("path", isLessThan: prefix + "\u{f8ff}")

      let snapshot = try await query.getDocuments()

      for document in snapshot.documents {
        if let node = parseDocument(document.data()) {
          allNodes.append(node)
        }
      }
    }

    return allNodes
  }

  func saveNode(userId: String, node: MemoryNode) async throws {
    let db = Firestore.firestore()
    let docId = pathToDocId(node.path)
    let docRef = db.collection("users").document(userId).collection("memory").document(docId)

    let data: [String: Any] = [
      "path": node.path,
      "content": node.content,
      "confidence": node.confidence,
      "last_updated": dateFormatter.string(from: node.lastUpdated),
      "update_count": node.updateCount,
      "source_session_ids": node.sourceSessionIds,
    ]

    try await docRef.setData(data)
  }

  func deleteNode(userId: String, path: String) async throws {
    let db = Firestore.firestore()
    let docId = pathToDocId(path)
    let docRef = db.collection("users").document(userId).collection("memory").document(docId)

    try await docRef.delete()
  }

  // MARK: - Document Parsing

  private func parseDocument(_ data: [String: Any]) -> MemoryNode? {
    guard let path = data["path"] as? String,
      let content = data["content"] as? String,
      let confidence = data["confidence"] as? Double,
      let lastUpdatedString = data["last_updated"] as? String,
      let lastUpdated = dateFormatter.date(from: lastUpdatedString),
      let updateCount = data["update_count"] as? Int,
      let sourceSessionIds = data["source_session_ids"] as? [String]
    else {
      return nil
    }

    return MemoryNode(
      path: path,
      content: content,
      confidence: confidence,
      lastUpdated: lastUpdated,
      updateCount: updateCount,
      sourceSessionIds: sourceSessionIds
    )
  }

  // MARK: - Path Utilities

  // Converts a path to a Firestore document ID.
  // Replaces "/" with "__" since "/" is not allowed in doc IDs.
  private func pathToDocId(_ path: String) -> String {
    path.replacingOccurrences(of: "/", with: "__")
  }

  // Converts a Firestore document ID back to a path.
  private func docIdToPath(_ docId: String) -> String {
    docId.replacingOccurrences(of: "__", with: "/")
  }
}

// MARK: - MemoryStorageFactory

// Factory for creating memory storage instances.
enum MemoryStorageFactory {
  // Creates Firestore-backed storage for production use.
  static func createStorage() -> MemoryStorageProtocol {
    FirestoreMemoryStorage()
  }
}

//
// MemoryContract.swift
// InkOS
//
// Types for the hierarchical long-term memory system.
// Memory persists learnings from Alan's per-session SessionModel into a tree structure.
// Storage uses Firestore with local caching for offline support.
//

import Foundation

// MARK: - MemoryNode

// A single node in the memory tree.
// Represents an encoded learning (expertise, not conversation logs).
struct MemoryNode: Sendable, Codable, Equatable {
  // Path in the memory tree (e.g., "subjects/math/calculus/limits").
  let path: String

  // Human-readable content describing the learning.
  let content: String

  // Confidence level 0-1. Increases with reinforcement.
  let confidence: Double

  // When this node was last updated.
  let lastUpdated: Date

  // Number of times this learning has been reinforced.
  let updateCount: Int

  // Session IDs that contributed to this node.
  let sourceSessionIds: [String]

  private enum CodingKeys: String, CodingKey {
    case path
    case content
    case confidence
    case lastUpdated = "last_updated"
    case updateCount = "update_count"
    case sourceSessionIds = "source_session_ids"
  }

  init(
    path: String,
    content: String,
    confidence: Double,
    lastUpdated: Date,
    updateCount: Int,
    sourceSessionIds: [String]
  ) {
    self.path = path
    self.content = content
    self.confidence = confidence
    self.lastUpdated = lastUpdated
    self.updateCount = updateCount
    self.sourceSessionIds = sourceSessionIds
  }

  // Creates a new node with default values.
  static func create(path: String, content: String, sessionId: String) -> MemoryNode {
    MemoryNode(
      path: path,
      content: content,
      confidence: 0.7,
      lastUpdated: Date(),
      updateCount: 1,
      sourceSessionIds: [sessionId]
    )
  }
}

// MARK: - ConceptStatus

// The mastery status of a concept from a session.
struct ConceptStatus: Sendable, Codable, Equatable {
  // Current status: mastered, practicing, struggling, introduced.
  let status: String

  // Number of attempts in this session.
  let attempts: Int
}

// MARK: - SessionSignals

// Engagement signals observed during a session.
struct SessionSignals: Sendable, Codable, Equatable {
  // Engagement level: high, medium, low.
  let engagement: String

  // Frustration level: high, medium, low, none.
  let frustration: String

  // Learning pace: fast, normal, slow.
  let pace: String
}

// MARK: - SessionGoal

// The learner's goal for the session.
struct SessionGoal: Sendable, Codable, Equatable {
  // Description of the goal.
  let description: String

  // Current status: active, completed, paused, abandoned.
  let status: String

  // Progress percentage 0-100.
  let progress: Int
}

// MARK: - SessionModel

// Captures learnings from a tutoring session.
// This is what Alan-b produces and sends to the memory subagent.
struct SessionModel: Sendable, Codable, Equatable {
  // Unique session identifier.
  let sessionId: String

  // Number of conversation turns.
  let turnCount: Int

  // The learner's goal (nil if none set).
  let goal: SessionGoal?

  // Concept statuses keyed by concept name.
  let concepts: [String: ConceptStatus]

  // Session-level engagement signals.
  let signals: SessionSignals

  // Facts learned about the user.
  let facts: [String]

  private enum CodingKeys: String, CodingKey {
    case sessionId = "session_id"
    case turnCount = "turn_count"
    case goal
    case concepts
    case signals
    case facts
  }

  init(
    sessionId: String,
    turnCount: Int,
    goal: SessionGoal?,
    concepts: [String: ConceptStatus],
    signals: SessionSignals,
    facts: [String]
  ) {
    self.sessionId = sessionId
    self.turnCount = turnCount
    self.goal = goal
    self.concepts = concepts
    self.signals = signals
    self.facts = facts
  }
}

// MARK: - SessionMetadata

// Metadata about the session for memory processing.
struct SessionMetadata: Sendable, Codable, Equatable {
  // Session identifier.
  let sessionId: String

  // Topics covered in the session.
  let topicsCovered: [String]

  // Session duration in minutes.
  let durationMinutes: Int

  // Number of conversation turns.
  let turnCount: Int

  private enum CodingKeys: String, CodingKey {
    case sessionId = "session_id"
    case topicsCovered = "topics_covered"
    case durationMinutes = "duration_minutes"
    case turnCount = "turn_count"
  }

  init(
    sessionId: String,
    topicsCovered: [String],
    durationMinutes: Int,
    turnCount: Int
  ) {
    self.sessionId = sessionId
    self.topicsCovered = topicsCovered
    self.durationMinutes = durationMinutes
    self.turnCount = turnCount
  }
}

// MARK: - MemoryUpdateRequest

// Request sent to the memory update endpoint.
struct MemoryUpdateRequest: Sendable, Codable, Equatable {
  // User identifier.
  let userId: String

  // Session model with learnings.
  let sessionModel: SessionModel

  // Session metadata for context.
  let sessionMetadata: SessionMetadata

  // Current relevant memory nodes for context.
  let currentMemory: [MemoryNode]

  private enum CodingKeys: String, CodingKey {
    case userId = "user_id"
    case sessionModel = "session_model"
    case sessionMetadata = "session_metadata"
    case currentMemory = "current_memory"
  }

  init(
    userId: String,
    sessionModel: SessionModel,
    sessionMetadata: SessionMetadata,
    currentMemory: [MemoryNode]
  ) {
    self.userId = userId
    self.sessionModel = sessionModel
    self.sessionMetadata = sessionMetadata
    self.currentMemory = currentMemory
  }
}

// MARK: - MemoryNodeUpdate

// An update to apply to the memory tree.
struct MemoryNodeUpdate: Sendable, Codable, Equatable {
  // Path in the memory tree.
  let path: String

  // New content for the node.
  let content: String

  // How much to adjust confidence.
  let confidenceDelta: Double

  // Type of operation.
  let operation: MemoryOperation

  private enum CodingKeys: String, CodingKey {
    case path
    case content
    case confidenceDelta = "confidence_delta"
    case operation
  }

  init(path: String, content: String, confidenceDelta: Double, operation: MemoryOperation) {
    self.path = path
    self.content = content
    self.confidenceDelta = confidenceDelta
    self.operation = operation
  }
}

// MARK: - MemoryOperation

// Type of memory update operation.
enum MemoryOperation: String, Sendable, Codable, Equatable {
  // Create a new memory node.
  case create

  // Update an existing node.
  case update

  // Reinforce an existing node.
  case reinforce
}

// MARK: - MemoryUpdateResponse

// Response from the memory update endpoint.
struct MemoryUpdateResponse: Sendable, Codable, Equatable {
  // Updates to apply to the memory tree.
  let updates: [MemoryNodeUpdate]
}

// MARK: - MemoryUpdateError

// Error response from memory update endpoint.
struct MemoryUpdateError: Sendable, Codable, Equatable, Error {
  let error: String
  let details: String?
}

// MARK: - MemoryManagerProtocol

// Protocol for the memory manager actor.
// Handles loading and saving memory nodes via Firestore.
protocol MemoryManagerProtocol: Actor {
  // Loads memory nodes matching the given path prefixes.
  // Always includes root/ and pedagogy/.
  func loadNodes(pathPrefixes: [String]) async throws -> [MemoryNode]

  // Applies updates from the memory subagent to Firestore.
  func applyUpdates(_ updates: [MemoryNodeUpdate], sessionId: String) async throws

  // Formats memory for inclusion in Alan's system prompt.
  func formatForAlan(nodes: [MemoryNode]) -> String

  // Triggers a memory update by calling the memory subagent.
  func triggerUpdate(sessionModel: SessionModel, metadata: SessionMetadata) async throws
}

// MARK: - Test Contract
//
// TEST CASES FOR MemoryManagerTests:
//
// TEST 1: loadNodes - Basic loading
// GIVEN: A user with existing memory nodes
// WHEN: loadNodes is called with ["subjects/math"]
// THEN: Returns root/, pedagogy/, and subjects/math/* nodes
//
// TEST 2: loadNodes - Empty memory
// GIVEN: A new user with no memory
// WHEN: loadNodes is called
// THEN: Returns empty array
//
// TEST 3: applyUpdates - Create operation
// GIVEN: An update with operation = create
// WHEN: applyUpdates is called
// THEN: A new document is created in Firestore
//
// TEST 4: applyUpdates - Update operation
// GIVEN: An update with operation = update
// WHEN: applyUpdates is called
// THEN: Existing document is updated with new content
//
// TEST 5: applyUpdates - Reinforce operation
// GIVEN: An update with operation = reinforce
// WHEN: applyUpdates is called
// THEN: Confidence is increased, updateCount incremented
//
// TEST 6: formatForAlan - Full formatting
// GIVEN: Memory nodes from root/, subjects/, and pedagogy/
// WHEN: formatForAlan is called
// THEN: Returns formatted markdown with sections for each category
//
// TEST 7: formatForAlan - Empty memory
// GIVEN: No memory nodes
// WHEN: formatForAlan is called
// THEN: Returns empty string or "No prior memory"
//
// TEST 8: triggerUpdate - Successful update
// GIVEN: A valid session model
// WHEN: triggerUpdate is called
// THEN: Calls memory subagent and applies returned updates
//
// TEST 9: triggerUpdate - Subagent failure
// GIVEN: Memory subagent returns an error
// WHEN: triggerUpdate is called
// THEN: Throws MemoryUpdateError
//
// TEST 10: Offline behavior
// GIVEN: Device is offline
// WHEN: applyUpdates is called
// THEN: Update is queued locally for later sync

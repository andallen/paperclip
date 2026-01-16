//
// MemoryContractTests.swift
// InkOSTests
//
// Tests for Memory contract types and Codable conformance.
//

import XCTest

@testable import InkOS

final class MemoryContractTests: XCTestCase {

  // MARK: - MemoryNode Tests

  func testMemoryNodeCodable() throws {
    let node = MemoryNode(
      path: "subjects/math/calculus/limits",
      content: "Mastered limits after 5 attempts",
      confidence: 0.85,
      lastUpdated: Date(timeIntervalSince1970: 1_704_067_200),
      updateCount: 3,
      sourceSessionIds: ["sess-001", "sess-002"]
    )

    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    let data = try encoder.encode(node)

    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    let decoded = try decoder.decode(MemoryNode.self, from: data)

    XCTAssertEqual(decoded.path, node.path)
    XCTAssertEqual(decoded.content, node.content)
    XCTAssertEqual(decoded.confidence, 0.85, accuracy: 0.001)
    XCTAssertEqual(decoded.updateCount, 3)
    XCTAssertEqual(decoded.sourceSessionIds, ["sess-001", "sess-002"])
  }

  func testMemoryNodeCreate() {
    let node = MemoryNode.create(
      path: "root/profile",
      content: "Visual learner",
      sessionId: "sess-123"
    )

    XCTAssertEqual(node.path, "root/profile")
    XCTAssertEqual(node.content, "Visual learner")
    XCTAssertEqual(node.confidence, 0.7)
    XCTAssertEqual(node.updateCount, 1)
    XCTAssertEqual(node.sourceSessionIds, ["sess-123"])
  }

  // MARK: - ConceptStatus Tests

  func testConceptStatusCodable() throws {
    let status = ConceptStatus(status: "mastered", attempts: 5)

    let encoder = JSONEncoder()
    let data = try encoder.encode(status)

    let decoder = JSONDecoder()
    let decoded = try decoder.decode(ConceptStatus.self, from: data)

    XCTAssertEqual(decoded.status, "mastered")
    XCTAssertEqual(decoded.attempts, 5)
  }

  // MARK: - SessionSignals Tests

  func testSessionSignalsCodable() throws {
    let signals = SessionSignals(engagement: "high", frustration: "none", pace: "normal")

    let encoder = JSONEncoder()
    let data = try encoder.encode(signals)

    let decoder = JSONDecoder()
    let decoded = try decoder.decode(SessionSignals.self, from: data)

    XCTAssertEqual(decoded.engagement, "high")
    XCTAssertEqual(decoded.frustration, "none")
    XCTAssertEqual(decoded.pace, "normal")
  }

  // MARK: - SessionGoal Tests

  func testSessionGoalCodable() throws {
    let goal = SessionGoal(
      description: "Learn calculus basics",
      status: "active",
      progress: 60
    )

    let encoder = JSONEncoder()
    let data = try encoder.encode(goal)

    let decoder = JSONDecoder()
    let decoded = try decoder.decode(SessionGoal.self, from: data)

    XCTAssertEqual(decoded.description, "Learn calculus basics")
    XCTAssertEqual(decoded.status, "active")
    XCTAssertEqual(decoded.progress, 60)
  }

  // MARK: - SessionModel Tests

  func testSessionModelCodable() throws {
    let model = SessionModel(
      sessionId: "sess-abc",
      turnCount: 10,
      goal: SessionGoal(description: "Master limits", status: "active", progress: 50),
      concepts: [
        "limits": ConceptStatus(status: "mastered", attempts: 3),
        "derivatives": ConceptStatus(status: "practicing", attempts: 2),
      ],
      signals: SessionSignals(engagement: "high", frustration: "none", pace: "normal"),
      facts: ["AP Calculus student", "Visual learner"]
    )

    let encoder = JSONEncoder()
    let data = try encoder.encode(model)

    let decoder = JSONDecoder()
    let decoded = try decoder.decode(SessionModel.self, from: data)

    XCTAssertEqual(decoded.sessionId, "sess-abc")
    XCTAssertEqual(decoded.turnCount, 10)
    XCTAssertNotNil(decoded.goal)
    XCTAssertEqual(decoded.goal?.description, "Master limits")
    XCTAssertEqual(decoded.concepts.count, 2)
    XCTAssertEqual(decoded.concepts["limits"]?.status, "mastered")
    XCTAssertEqual(decoded.signals.engagement, "high")
    XCTAssertEqual(decoded.facts, ["AP Calculus student", "Visual learner"])
  }

  func testSessionModelWithNilGoal() throws {
    let model = SessionModel(
      sessionId: "sess-xyz",
      turnCount: 5,
      goal: nil,
      concepts: [:],
      signals: SessionSignals(engagement: "medium", frustration: "low", pace: "slow"),
      facts: []
    )

    let encoder = JSONEncoder()
    let data = try encoder.encode(model)

    let decoder = JSONDecoder()
    let decoded = try decoder.decode(SessionModel.self, from: data)

    XCTAssertEqual(decoded.sessionId, "sess-xyz")
    XCTAssertNil(decoded.goal)
    XCTAssertTrue(decoded.concepts.isEmpty)
    XCTAssertTrue(decoded.facts.isEmpty)
  }

  // MARK: - SessionMetadata Tests

  func testSessionMetadataCodable() throws {
    let metadata = SessionMetadata(
      sessionId: "sess-001",
      topicsCovered: ["calculus", "limits"],
      durationMinutes: 30,
      turnCount: 15
    )

    let encoder = JSONEncoder()
    let data = try encoder.encode(metadata)

    let decoder = JSONDecoder()
    let decoded = try decoder.decode(SessionMetadata.self, from: data)

    XCTAssertEqual(decoded.sessionId, "sess-001")
    XCTAssertEqual(decoded.topicsCovered, ["calculus", "limits"])
    XCTAssertEqual(decoded.durationMinutes, 30)
    XCTAssertEqual(decoded.turnCount, 15)
  }

  // MARK: - MemoryNodeUpdate Tests

  func testMemoryNodeUpdateCodable() throws {
    let update = MemoryNodeUpdate(
      path: "subjects/math/calculus/limits",
      content: "Mastered limits",
      confidenceDelta: 0.1,
      operation: .reinforce
    )

    let encoder = JSONEncoder()
    let data = try encoder.encode(update)

    let decoder = JSONDecoder()
    let decoded = try decoder.decode(MemoryNodeUpdate.self, from: data)

    XCTAssertEqual(decoded.path, "subjects/math/calculus/limits")
    XCTAssertEqual(decoded.content, "Mastered limits")
    XCTAssertEqual(decoded.confidenceDelta, 0.1, accuracy: 0.001)
    XCTAssertEqual(decoded.operation, .reinforce)
  }

  func testMemoryOperationCodable() throws {
    for operation in [MemoryOperation.create, .update, .reinforce] {
      let encoder = JSONEncoder()
      let data = try encoder.encode(operation)

      let decoder = JSONDecoder()
      let decoded = try decoder.decode(MemoryOperation.self, from: data)

      XCTAssertEqual(decoded, operation)
    }
  }

  // MARK: - MemoryUpdateRequest Tests

  func testMemoryUpdateRequestCodable() throws {
    let request = MemoryUpdateRequest(
      userId: "user-123",
      sessionModel: SessionModel(
        sessionId: "sess-001",
        turnCount: 10,
        goal: nil,
        concepts: ["limits": ConceptStatus(status: "mastered", attempts: 3)],
        signals: SessionSignals(engagement: "high", frustration: "none", pace: "normal"),
        facts: ["Visual learner"]
      ),
      sessionMetadata: SessionMetadata(
        sessionId: "sess-001",
        topicsCovered: ["calculus"],
        durationMinutes: 20,
        turnCount: 10
      ),
      currentMemory: []
    )

    let encoder = JSONEncoder()
    let data = try encoder.encode(request)

    let decoder = JSONDecoder()
    let decoded = try decoder.decode(MemoryUpdateRequest.self, from: data)

    XCTAssertEqual(decoded.userId, "user-123")
    XCTAssertEqual(decoded.sessionModel.sessionId, "sess-001")
    XCTAssertEqual(decoded.sessionMetadata.topicsCovered, ["calculus"])
    XCTAssertTrue(decoded.currentMemory.isEmpty)
  }

  // MARK: - MemoryUpdateResponse Tests

  func testMemoryUpdateResponseCodable() throws {
    let response = MemoryUpdateResponse(updates: [
      MemoryNodeUpdate(
        path: "subjects/math/calculus/limits",
        content: "Mastered limits",
        confidenceDelta: 0.7,
        operation: .create
      ),
      MemoryNodeUpdate(
        path: "root/profile",
        content: "Visual learner",
        confidenceDelta: 0.7,
        operation: .create
      ),
    ])

    let encoder = JSONEncoder()
    let data = try encoder.encode(response)

    let decoder = JSONDecoder()
    let decoded = try decoder.decode(MemoryUpdateResponse.self, from: data)

    XCTAssertEqual(decoded.updates.count, 2)
    XCTAssertEqual(decoded.updates[0].path, "subjects/math/calculus/limits")
    XCTAssertEqual(decoded.updates[1].path, "root/profile")
  }

  func testEmptyMemoryUpdateResponse() throws {
    let response = MemoryUpdateResponse(updates: [])

    let encoder = JSONEncoder()
    let data = try encoder.encode(response)

    let decoder = JSONDecoder()
    let decoded = try decoder.decode(MemoryUpdateResponse.self, from: data)

    XCTAssertTrue(decoded.updates.isEmpty)
  }

  // MARK: - MemoryUpdateError Tests

  func testMemoryUpdateErrorCodable() throws {
    let error = MemoryUpdateError(
      error: "Invalid request",
      details: "Missing user_id field"
    )

    let encoder = JSONEncoder()
    let data = try encoder.encode(error)

    let decoder = JSONDecoder()
    let decoded = try decoder.decode(MemoryUpdateError.self, from: data)

    XCTAssertEqual(decoded.error, "Invalid request")
    XCTAssertEqual(decoded.details, "Missing user_id field")
  }

  // MARK: - JSON Interoperability Tests

  func testDecodeFromFirebaseJSON() throws {
    // Test decoding from JSON that matches Firebase function format.
    let json = """
      {
        "updates": [
          {
            "path": "subjects/math/calculus/limits",
            "content": "Mastered limits after initial struggle",
            "confidence_delta": 0.8,
            "operation": "update"
          }
        ]
      }
      """

    let data = json.data(using: .utf8)!
    let decoder = JSONDecoder()
    let response = try decoder.decode(MemoryUpdateResponse.self, from: data)

    XCTAssertEqual(response.updates.count, 1)
    XCTAssertEqual(response.updates[0].path, "subjects/math/calculus/limits")
    XCTAssertEqual(response.updates[0].confidenceDelta, 0.8, accuracy: 0.001)
    XCTAssertEqual(response.updates[0].operation, .update)
  }

  func testDecodeMemoryNodeFromFirestore() throws {
    // Test decoding from JSON that matches Firestore document format.
    let json = """
      {
        "path": "root/profile",
        "content": "Visual learner, prefers diagrams",
        "confidence": 0.85,
        "last_updated": "2024-01-15T10:30:00Z",
        "update_count": 3,
        "source_session_ids": ["sess-001", "sess-002"]
      }
      """

    let data = json.data(using: .utf8)!
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    let node = try decoder.decode(MemoryNode.self, from: data)

    XCTAssertEqual(node.path, "root/profile")
    XCTAssertEqual(node.content, "Visual learner, prefers diagrams")
    XCTAssertEqual(node.confidence, 0.85, accuracy: 0.001)
    XCTAssertEqual(node.updateCount, 3)
    XCTAssertEqual(node.sourceSessionIds.count, 2)
  }
}

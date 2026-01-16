// memorySchema.test.ts
// Tests for memory system Zod schemas based on Contract.ts test cases.

import {
  MemoryNodeSchema,
  MemoryUpdateRequestSchema,
  MemoryUpdateResponseSchema,
  MemoryNodeUpdateSchema,
  SessionModelSchema,
} from "../../memory/memorySchema";

describe("MemoryNodeSchema", () => {
  describe("valid inputs", () => {
    it("should validate a complete valid memory node", () => {
      const validNode = {
        path: "subjects/math/calculus/derivatives",
        content: "Mastered after 5 attempts using area model",
        confidence: 0.8,
        lastUpdated: "2024-01-15T10:30:00Z",
        updateCount: 3,
        sourceSessionIds: ["session-abc", "session-def"],
      };

      const result = MemoryNodeSchema.safeParse(validNode);
      expect(result.success).toBe(true);
    });

    it("should validate a root path node", () => {
      const rootNode = {
        path: "root/profile",
        content: "Visual learner, prefers diagrams",
        confidence: 0.9,
        lastUpdated: "2024-01-15T10:30:00Z",
        updateCount: 5,
        sourceSessionIds: ["session-123"],
      };

      const result = MemoryNodeSchema.safeParse(rootNode);
      expect(result.success).toBe(true);
    });

    it("should validate a node with underscores in path", () => {
      const node = {
        path: "subjects/math/linear_algebra",
        content: "Introduction complete",
        confidence: 0.7,
        lastUpdated: "2024-01-15T10:30:00Z",
        updateCount: 1,
        sourceSessionIds: [],
      };

      const result = MemoryNodeSchema.safeParse(node);
      expect(result.success).toBe(true);
    });

    it("should validate minimum confidence (0)", () => {
      const node = {
        path: "root/test",
        content: "Low confidence",
        confidence: 0,
        lastUpdated: "2024-01-15T10:30:00Z",
        updateCount: 0,
        sourceSessionIds: [],
      };

      const result = MemoryNodeSchema.safeParse(node);
      expect(result.success).toBe(true);
    });

    it("should validate maximum confidence (1)", () => {
      const node = {
        path: "root/test",
        content: "High confidence",
        confidence: 1,
        lastUpdated: "2024-01-15T10:30:00Z",
        updateCount: 10,
        sourceSessionIds: [],
      };

      const result = MemoryNodeSchema.safeParse(node);
      expect(result.success).toBe(true);
    });
  });

  describe("invalid inputs", () => {
    it("should reject uppercase path", () => {
      const invalidNode = {
        path: "Subjects/Math",
        content: "Test",
        confidence: 0.5,
        lastUpdated: "2024-01-15T10:30:00Z",
        updateCount: 0,
        sourceSessionIds: [],
      };

      const result = MemoryNodeSchema.safeParse(invalidNode);
      expect(result.success).toBe(false);
    });

    it("should reject path with spaces", () => {
      const invalidNode = {
        path: "subjects/math algebra",
        content: "Test",
        confidence: 0.5,
        lastUpdated: "2024-01-15T10:30:00Z",
        updateCount: 0,
        sourceSessionIds: [],
      };

      const result = MemoryNodeSchema.safeParse(invalidNode);
      expect(result.success).toBe(false);
    });

    it("should reject path with special characters", () => {
      const invalidNode = {
        path: "subjects/math-calculus",
        content: "Test",
        confidence: 0.5,
        lastUpdated: "2024-01-15T10:30:00Z",
        updateCount: 0,
        sourceSessionIds: [],
      };

      const result = MemoryNodeSchema.safeParse(invalidNode);
      expect(result.success).toBe(false);
    });

    it("should reject confidence > 1", () => {
      const invalidNode = {
        path: "root/profile",
        content: "Visual learner",
        confidence: 1.5,
        lastUpdated: "2024-01-15T10:30:00Z",
        updateCount: 0,
        sourceSessionIds: [],
      };

      const result = MemoryNodeSchema.safeParse(invalidNode);
      expect(result.success).toBe(false);
    });

    it("should reject confidence < 0", () => {
      const invalidNode = {
        path: "root/profile",
        content: "Visual learner",
        confidence: -0.1,
        lastUpdated: "2024-01-15T10:30:00Z",
        updateCount: 0,
        sourceSessionIds: [],
      };

      const result = MemoryNodeSchema.safeParse(invalidNode);
      expect(result.success).toBe(false);
    });

    it("should reject empty content", () => {
      const invalidNode = {
        path: "root/profile",
        content: "",
        confidence: 0.5,
        lastUpdated: "2024-01-15T10:30:00Z",
        updateCount: 0,
        sourceSessionIds: [],
      };

      const result = MemoryNodeSchema.safeParse(invalidNode);
      expect(result.success).toBe(false);
    });

    it("should reject invalid datetime format", () => {
      const invalidNode = {
        path: "root/profile",
        content: "Test",
        confidence: 0.5,
        lastUpdated: "2024-01-15",
        updateCount: 0,
        sourceSessionIds: [],
      };

      const result = MemoryNodeSchema.safeParse(invalidNode);
      expect(result.success).toBe(false);
    });

    it("should reject negative updateCount", () => {
      const invalidNode = {
        path: "root/profile",
        content: "Test",
        confidence: 0.5,
        lastUpdated: "2024-01-15T10:30:00Z",
        updateCount: -1,
        sourceSessionIds: [],
      };

      const result = MemoryNodeSchema.safeParse(invalidNode);
      expect(result.success).toBe(false);
    });
  });
});

describe("SessionModelSchema", () => {
  it("should validate a complete session model", () => {
    const validSessionModel = {
      session_id: "session-xyz",
      turn_count: 15,
      goal: {description: "Learn derivatives", status: "active", progress: 50},
      concepts: {
        derivatives: {status: "practicing", attempts: 3},
        limits: {status: "mastered", attempts: 5},
      },
      signals: {engagement: "high", frustration: "none", pace: "normal"},
      facts: ["Prefers visual examples", "AP Calculus student"],
    };

    const result = SessionModelSchema.safeParse(validSessionModel);
    expect(result.success).toBe(true);
  });

  it("should validate session model with null goal", () => {
    const sessionWithNullGoal = {
      session_id: "session-abc",
      turn_count: 5,
      goal: null,
      concepts: {},
      signals: {engagement: "medium", frustration: "mild", pace: "slow"},
      facts: [],
    };

    const result = SessionModelSchema.safeParse(sessionWithNullGoal);
    expect(result.success).toBe(true);
  });

  it("should reject invalid concept status", () => {
    const invalidSessionModel = {
      session_id: "session-xyz",
      turn_count: 15,
      goal: null,
      concepts: {
        derivatives: {status: "unknown", attempts: 3},
      },
      signals: {engagement: "high", frustration: "none", pace: "normal"},
      facts: [],
    };

    const result = SessionModelSchema.safeParse(invalidSessionModel);
    expect(result.success).toBe(false);
  });

  it("should reject invalid signal values", () => {
    const invalidSessionModel = {
      session_id: "session-xyz",
      turn_count: 15,
      goal: null,
      concepts: {},
      signals: {engagement: "very_high", frustration: "none", pace: "normal"},
      facts: [],
    };

    const result = SessionModelSchema.safeParse(invalidSessionModel);
    expect(result.success).toBe(false);
  });
});

describe("MemoryUpdateRequestSchema", () => {
  const validSessionModel = {
    session_id: "session-xyz",
    turn_count: 15,
    goal: {description: "Learn derivatives", status: "active", progress: 50},
    concepts: {
      derivatives: {status: "practicing", attempts: 3},
      limits: {status: "mastered", attempts: 5},
    },
    signals: {engagement: "high", frustration: "none", pace: "normal"},
    facts: ["Prefers visual examples", "AP Calculus student"],
  };

  const validMetadata = {
    session_id: "session-xyz",
    topics_covered: ["calculus", "derivatives"],
    duration_minutes: 25,
    turn_count: 15,
  };

  it("should validate a complete update request", () => {
    const validRequest = {
      user_id: "user123",
      session_model: validSessionModel,
      session_metadata: validMetadata,
      current_memory: [],
    };

    const result = MemoryUpdateRequestSchema.safeParse(validRequest);
    expect(result.success).toBe(true);
  });

  it("should validate request with existing memory nodes", () => {
    const requestWithMemory = {
      user_id: "user456",
      session_model: validSessionModel,
      session_metadata: validMetadata,
      current_memory: [
        {
          path: "root/profile",
          content: "Visual learner",
          confidence: 0.8,
          lastUpdated: "2024-01-10T10:00:00Z",
          updateCount: 2,
          sourceSessionIds: ["session-old"],
        },
      ],
    };

    const result = MemoryUpdateRequestSchema.safeParse(requestWithMemory);
    expect(result.success).toBe(true);
  });

  it("should reject empty user_id", () => {
    const invalidRequest = {
      user_id: "",
      session_model: validSessionModel,
      session_metadata: validMetadata,
      current_memory: [],
    };

    const result = MemoryUpdateRequestSchema.safeParse(invalidRequest);
    expect(result.success).toBe(false);
  });

  it("should reject missing session_model", () => {
    const invalidRequest = {
      user_id: "user123",
      session_metadata: validMetadata,
      current_memory: [],
    };

    const result = MemoryUpdateRequestSchema.safeParse(invalidRequest);
    expect(result.success).toBe(false);
  });
});

describe("MemoryNodeUpdateSchema", () => {
  it("should validate create operation", () => {
    const createUpdate = {
      path: "subjects/math/calculus/derivatives",
      content: "Mastered using power rule approach",
      confidence_delta: 0.7,
      operation: "create",
    };

    const result = MemoryNodeUpdateSchema.safeParse(createUpdate);
    expect(result.success).toBe(true);
  });

  it("should validate reinforce operation", () => {
    const reinforceUpdate = {
      path: "root/profile",
      content: "Visual learner - confirmed again",
      confidence_delta: 0.1,
      operation: "reinforce",
    };

    const result = MemoryNodeUpdateSchema.safeParse(reinforceUpdate);
    expect(result.success).toBe(true);
  });

  it("should validate update operation (contradiction)", () => {
    const contradictionUpdate = {
      path: "subjects/math/algebra/factoring",
      content: "Now mastered (was previously struggling)",
      confidence_delta: 0.5,
      operation: "update",
    };

    const result = MemoryNodeUpdateSchema.safeParse(contradictionUpdate);
    expect(result.success).toBe(true);
  });

  it("should reject invalid operation", () => {
    const invalidUpdate = {
      path: "root/profile",
      content: "test",
      confidence_delta: 0.5,
      operation: "delete",
    };

    const result = MemoryNodeUpdateSchema.safeParse(invalidUpdate);
    expect(result.success).toBe(false);
  });

  it("should reject confidence_delta > 1", () => {
    const invalidUpdate = {
      path: "root/profile",
      content: "test",
      confidence_delta: 1.5,
      operation: "create",
    };

    const result = MemoryNodeUpdateSchema.safeParse(invalidUpdate);
    expect(result.success).toBe(false);
  });

  it("should reject confidence_delta < -1", () => {
    const invalidUpdate = {
      path: "root/profile",
      content: "test",
      confidence_delta: -1.5,
      operation: "update",
    };

    const result = MemoryNodeUpdateSchema.safeParse(invalidUpdate);
    expect(result.success).toBe(false);
  });

  it("should reject invalid path in update", () => {
    const invalidUpdate = {
      path: "Root/Profile",
      content: "test",
      confidence_delta: 0.5,
      operation: "create",
    };

    const result = MemoryNodeUpdateSchema.safeParse(invalidUpdate);
    expect(result.success).toBe(false);
  });
});

describe("MemoryUpdateResponseSchema", () => {
  it("should validate empty response (no updates needed)", () => {
    const emptyResponse = {
      updates: [],
    };

    const result = MemoryUpdateResponseSchema.safeParse(emptyResponse);
    expect(result.success).toBe(true);
  });

  it("should validate response with multiple updates", () => {
    const multiUpdateResponse = {
      updates: [
        {
          path: "root/profile",
          content: "Visual learner",
          confidence_delta: 0.7,
          operation: "create",
        },
        {
          path: "subjects/math/calculus",
          content: "Strong foundation",
          confidence_delta: 0.1,
          operation: "reinforce",
        },
      ],
    };

    const result = MemoryUpdateResponseSchema.safeParse(multiUpdateResponse);
    expect(result.success).toBe(true);
  });

  it("should reject response with invalid update", () => {
    const invalidResponse = {
      updates: [
        {
          path: "root/profile",
          content: "Visual learner",
          confidence_delta: 0.7,
          operation: "invalid_operation",
        },
      ],
    };

    const result = MemoryUpdateResponseSchema.safeParse(invalidResponse);
    expect(result.success).toBe(false);
  });
});

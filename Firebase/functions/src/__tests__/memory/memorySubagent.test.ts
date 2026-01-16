// memorySubagent.test.ts
// Tests for Memory Subagent endpoint based on subagentContract.ts test cases.

import {processMemoryUpdateRequest} from "../../memory/memorySubagent";
import {MemoryUpdateRequest, MemoryNode} from "../../memory/memorySchema";
import {LLMClient} from "../../memory/llmProcessor";

// Mock LLM client that returns expected responses.
const createMockLLMClient = (): LLMClient => ({
  generateContent: jest.fn().mockImplementation(async (prompt: string) => {
    // Handle contradiction prompts.
    if (prompt.includes("struggling") && prompt.includes("mastered")) {
      return JSON.stringify({
        new_content: "Mastered after initial struggle (8 attempts)",
        confidence: 0.8,
      });
    }
    // Handle fact merge prompts.
    if (prompt.includes("Existing fact")) {
      return JSON.stringify({
        decision: "keep_both",
        reasoning: "Distinct facts",
      });
    }
    return JSON.stringify({decision: "keep_both"});
  }),
});

// Helper to create a valid request.
const createValidRequest = (
  overrides: Partial<MemoryUpdateRequest> = {}
): MemoryUpdateRequest => ({
  user_id: "user123",
  session_model: {
    session_id: "sess1",
    turn_count: 10,
    goal: null,
    concepts: {},
    signals: {engagement: "medium", frustration: "none", pace: "normal"},
    facts: [],
  },
  session_metadata: {
    session_id: "sess1",
    topics_covered: ["calculus"],
    duration_minutes: 20,
    turn_count: 10,
  },
  current_memory: [],
  ...overrides,
});

// Helper to create a memory node.
const createNode = (path: string, content: string): MemoryNode => ({
  path,
  content,
  confidence: 0.7,
  lastUpdated: "2024-01-15T10:30:00Z",
  updateCount: 1,
  sourceSessionIds: ["session-old"],
});

describe("processMemoryUpdateRequest", () => {
  describe("TEST 1: Simple request with no existing memory", () => {
    it("should create updates for concepts, facts, and signals", async () => {
      const request = createValidRequest({
        session_model: {
          session_id: "sess1",
          turn_count: 10,
          goal: null,
          concepts: {derivatives: {status: "mastered", attempts: 5}},
          signals: {engagement: "high", frustration: "none", pace: "normal"},
          facts: ["AP Calculus student"],
        },
      });

      const result = await processMemoryUpdateRequest(request, createMockLLMClient());

      expect(result.success).toBe(true);
      expect(result.updates).toBeDefined();

      // Should have concept update.
      const conceptUpdate = result.updates!.find((u) =>
        u.path.includes("derivatives")
      );
      expect(conceptUpdate).toBeDefined();
      expect(conceptUpdate?.operation).toBe("create");
      expect(conceptUpdate?.content).toContain("mastered");

      // Should have fact update.
      const factUpdate = result.updates!.find(
        (u) => u.path === "root/profile" && u.content.includes("AP Calculus")
      );
      expect(factUpdate).toBeDefined();

      // Should have signal updates.
      const engagementUpdate = result.updates!.find(
        (u) => u.path === "root/engagement"
      );
      expect(engagementUpdate?.content).toContain("high");
    });
  });

  describe("TEST 2: Request with contradiction (requires LLM)", () => {
    it("should resolve contradiction via LLM", async () => {
      const request = createValidRequest({
        session_model: {
          session_id: "sess2",
          turn_count: 15,
          goal: null,
          concepts: {factoring: {status: "mastered", attempts: 8}},
          signals: {engagement: "medium", frustration: "none", pace: "slow"},
          facts: [],
        },
        session_metadata: {
          session_id: "sess2",
          topics_covered: ["algebra"],
          duration_minutes: 30,
          turn_count: 15,
        },
        current_memory: [
          createNode("subjects/math/algebra/factoring", "struggling"),
        ],
      });

      const result = await processMemoryUpdateRequest(request, createMockLLMClient());

      expect(result.success).toBe(true);

      // Should have LLM-resolved contradiction.
      const factoringUpdate = result.updates!.find((u) =>
        u.path.includes("factoring")
      );
      expect(factoringUpdate).toBeDefined();
      expect(factoringUpdate?.operation).toBe("update");
      expect(factoringUpdate?.content).toContain("Mastered");

      // Should still have signal updates.
      const engagementUpdate = result.updates!.find(
        (u) => u.path === "root/engagement"
      );
      expect(engagementUpdate).toBeDefined();
    });
  });

  describe("TEST 3: Invalid request body", () => {
    it("should return error for empty user_id", async () => {
      const invalidRequest = {
        user_id: "",
        session_model: {
          session_id: "sess1",
          turn_count: 10,
          goal: null,
          concepts: {},
          signals: {engagement: "medium", frustration: "none", pace: "normal"},
          facts: [],
        },
        session_metadata: {
          session_id: "sess1",
          topics_covered: [],
          duration_minutes: 20,
          turn_count: 10,
        },
        current_memory: [],
      };

      const result = await processMemoryUpdateRequest(
        invalidRequest as unknown,
        createMockLLMClient()
      );

      expect(result.success).toBe(false);
      expect(result.error).toBeDefined();
      expect(result.error?.code).toBe("INVALID_REQUEST");
    });

    it("should return error for missing session_model", async () => {
      const invalidRequest = {
        user_id: "user123",
        session_metadata: {
          session_id: "sess1",
          topics_covered: [],
          duration_minutes: 20,
          turn_count: 10,
        },
        current_memory: [],
      };

      const result = await processMemoryUpdateRequest(
        invalidRequest as unknown,
        createMockLLMClient()
      );

      expect(result.success).toBe(false);
      expect(result.error?.code).toBe("INVALID_REQUEST");
    });
  });

  describe("TEST 4: Empty session (only signals)", () => {
    it("should only return signal updates", async () => {
      const request = createValidRequest({
        session_model: {
          session_id: "sess3",
          turn_count: 5,
          goal: null,
          concepts: {},
          signals: {engagement: "low", frustration: "high", pace: "normal"},
          facts: [],
        },
      });

      const result = await processMemoryUpdateRequest(request, createMockLLMClient());

      expect(result.success).toBe(true);
      expect(result.updates).toHaveLength(2); // engagement + pace

      const engagementUpdate = result.updates!.find(
        (u) => u.path === "root/engagement"
      );
      expect(engagementUpdate?.content).toContain("low");
    });
  });

  describe("TEST 5: Multiple concepts and facts", () => {
    it("should handle multiple items in single request", async () => {
      const request = createValidRequest({
        session_model: {
          session_id: "sess4",
          turn_count: 25,
          goal: {description: "Learn calculus", status: "active", progress: 60},
          concepts: {
            limits: {status: "mastered", attempts: 3},
            derivatives: {status: "mastered", attempts: 7},
            integrals: {status: "practicing", attempts: 2},
          },
          signals: {engagement: "high", frustration: "none", pace: "fast"},
          facts: ["Prefers examples over theory", "Visual learner"],
        },
        session_metadata: {
          session_id: "sess4",
          topics_covered: ["calculus"],
          duration_minutes: 45,
          turn_count: 25,
        },
      });

      const result = await processMemoryUpdateRequest(request, createMockLLMClient());

      expect(result.success).toBe(true);

      // Should have 2 concept updates (mastered only, not practicing).
      const conceptUpdates = result.updates!.filter((u) =>
        u.path.startsWith("subjects/")
      );
      expect(conceptUpdates).toHaveLength(2);

      // Should have 2 fact updates.
      const factUpdates = result.updates!.filter(
        (u) => u.path === "root/profile"
      );
      expect(factUpdates).toHaveLength(2);

      // Should have 2 signal updates.
      const signalUpdates = result.updates!.filter(
        (u) => u.path === "root/engagement" || u.path === "root/pace"
      );
      expect(signalUpdates).toHaveLength(2);
    });
  });

  describe("TEST 6: LLM failure graceful degradation", () => {
    it("should return rule-based updates even if LLM fails", async () => {
      const failingLLMClient: LLMClient = {
        generateContent: jest.fn().mockRejectedValue(new Error("LLM unavailable")),
      };

      const request = createValidRequest({
        session_model: {
          session_id: "sess5",
          turn_count: 10,
          goal: null,
          concepts: {factoring: {status: "mastered", attempts: 8}},
          signals: {engagement: "medium", frustration: "none", pace: "normal"},
          facts: [],
        },
        session_metadata: {
          session_id: "sess5",
          topics_covered: ["algebra"],
          duration_minutes: 20,
          turn_count: 10,
        },
        current_memory: [
          createNode("subjects/math/algebra/factoring", "struggling"),
        ],
      });

      const result = await processMemoryUpdateRequest(request, failingLLMClient);

      // Should still succeed with partial results.
      expect(result.success).toBe(true);

      // Should have signal updates (rule-based).
      const signalUpdates = result.updates!.filter(
        (u) => u.path === "root/engagement" || u.path === "root/pace"
      );
      expect(signalUpdates.length).toBeGreaterThan(0);

      // Should NOT have factoring update (that needed LLM).
      const factoringUpdate = result.updates!.find((u) =>
        u.path.includes("factoring")
      );
      expect(factoringUpdate).toBeUndefined();
    });
  });

  describe("Edge cases", () => {
    it("should handle request with only reinforcement (no new data)", async () => {
      const request = createValidRequest({
        session_model: {
          session_id: "sess6",
          turn_count: 5,
          goal: null,
          concepts: {derivatives: {status: "mastered", attempts: 2}},
          signals: {engagement: "medium", frustration: "none", pace: "normal"},
          facts: [],
        },
        current_memory: [
          createNode("subjects/math/calculus/derivatives", "mastered"),
        ],
      });

      const result = await processMemoryUpdateRequest(request, createMockLLMClient());

      expect(result.success).toBe(true);

      // Should reinforce existing node.
      const derivativesUpdate = result.updates!.find((u) =>
        u.path.includes("derivatives")
      );
      expect(derivativesUpdate?.operation).toBe("reinforce");
    });
  });
});

// rules.test.ts
// Tests for rule-based memory processing based on rulesContract.ts test cases.

import {
  inferPath,
  processRuleBased,
  statusMatches,
  findSimilarFact,
} from "../../memory/rules";
import {MemoryNode, MemoryUpdateRequest} from "../../memory/memorySchema";

describe("inferPath", () => {
  it("should map derivatives with calculus hint to math/calculus path", () => {
    expect(inferPath("derivatives", ["calculus"])).toBe(
      "subjects/math/calculus/derivatives"
    );
  });

  it("should map derivatives with multiple hints to correct path", () => {
    expect(inferPath("derivatives", ["math", "calculus"])).toBe(
      "subjects/math/calculus/derivatives"
    );
  });

  it("should map limits with calculus hint", () => {
    expect(inferPath("limits", ["calculus", "math"])).toBe(
      "subjects/math/calculus/limits"
    );
  });

  it("should map factoring with algebra hint", () => {
    expect(inferPath("factoring", ["algebra"])).toBe(
      "subjects/math/algebra/factoring"
    );
  });

  it("should map biology concept to science path", () => {
    expect(inferPath("cell division", ["biology"])).toBe(
      "subjects/science/biology/cell_division"
    );
  });

  it("should use general path when no hint provided", () => {
    expect(inferPath("photosynthesis", [])).toBe(
      "subjects/general/photosynthesis"
    );
  });

  it("should map history concept correctly", () => {
    expect(inferPath("World War II", ["history"])).toBe(
      "subjects/history/world_war_ii"
    );
  });

  it("should handle math hint without specific area", () => {
    expect(inferPath("quadratic formula", ["math"])).toBe(
      "subjects/math/quadratic_formula"
    );
  });

  it("should be case insensitive", () => {
    expect(inferPath("DERIVATIVES", ["Calculus"])).toBe(
      "subjects/math/calculus/derivatives"
    );
  });

  it("should normalize spaces to underscores", () => {
    expect(inferPath("chain rule", ["calculus"])).toBe(
      "subjects/math/calculus/chain_rule"
    );
  });
});

describe("statusMatches", () => {
  it("should match mastered status with mastered content", () => {
    expect(statusMatches("mastered", {status: "mastered", attempts: 5})).toBe(
      true
    );
  });

  it("should match reinforced mastered content", () => {
    expect(
      statusMatches("mastered - reinforced", {status: "mastered", attempts: 3})
    ).toBe(true);
  });

  it("should match struggling status", () => {
    expect(
      statusMatches("struggling with factoring", {
        status: "struggling",
        attempts: 2,
      })
    ).toBe(true);
  });

  it("should detect contradiction: mastered content vs struggling status", () => {
    expect(statusMatches("mastered", {status: "struggling", attempts: 1})).toBe(
      false
    );
  });

  it("should detect contradiction: struggling content vs mastered status", () => {
    expect(statusMatches("struggling", {status: "mastered", attempts: 10})).toBe(
      false
    );
  });
});

describe("findSimilarFact", () => {
  it("should return null for empty memory", () => {
    expect(findSimilarFact("Prefers visual examples", [])).toBeNull();
  });

  it("should find similar fact with keyword overlap", () => {
    const existingNodes: MemoryNode[] = [
      {
        path: "root/profile",
        content: "Prefers visual examples",
        confidence: 0.8,
        lastUpdated: "2024-01-15T10:30:00Z",
        updateCount: 2,
        sourceSessionIds: ["session-old"],
      },
    ];

    const result = findSimilarFact("Likes diagrams and visual aids", existingNodes);
    expect(result).not.toBeNull();
    expect(result?.content).toBe("Prefers visual examples");
  });

  it("should return null when no keyword overlap", () => {
    const existingNodes: MemoryNode[] = [
      {
        path: "root/profile",
        content: "Prefers visual examples",
        confidence: 0.8,
        lastUpdated: "2024-01-15T10:30:00Z",
        updateCount: 2,
        sourceSessionIds: ["session-old"],
      },
    ];

    expect(findSimilarFact("AP Calculus student", existingNodes)).toBeNull();
  });

  it("should only check profile nodes", () => {
    const existingNodes: MemoryNode[] = [
      {
        path: "root/engagement",
        content: "high engagement",
        confidence: 0.8,
        lastUpdated: "2024-01-15T10:30:00Z",
        updateCount: 2,
        sourceSessionIds: ["session-old"],
      },
      {
        path: "root/profile",
        content: "Quick with new concepts",
        confidence: 0.7,
        lastUpdated: "2024-01-15T10:30:00Z",
        updateCount: 1,
        sourceSessionIds: ["session-old"],
      },
    ];

    const result = findSimilarFact("Fast learner", existingNodes);
    // Should find the profile node, not engagement
    expect(result?.path).toBe("root/profile");
  });
});

describe("processRuleBased", () => {
  const baseRequest: Omit<MemoryUpdateRequest, "session_model" | "current_memory"> = {
    user_id: "user123",
    session_metadata: {
      session_id: "session-xyz",
      topics_covered: ["calculus"],
      duration_minutes: 25,
      turn_count: 15,
    },
  };

  const baseSessionModel = {
    session_id: "session-xyz",
    turn_count: 15,
    goal: null,
    concepts: {},
    signals: {engagement: "medium" as const, frustration: "none" as const, pace: "normal" as const},
    facts: [],
  };

  it("TEST 1: should create update for new mastered concept", () => {
    const request: MemoryUpdateRequest = {
      ...baseRequest,
      session_model: {
        ...baseSessionModel,
        concepts: {derivatives: {status: "mastered", attempts: 5}},
      },
      current_memory: [],
    };

    const result = processRuleBased(request);

    expect(result.updates).toHaveLength(3); // concept + engagement + pace
    expect(result.updates[0]).toMatchObject({
      path: "subjects/math/calculus/derivatives",
      content: expect.stringContaining("mastered"),
      operation: "create",
      confidence_delta: 0.7,
    });
    expect(result.needsLLM).toHaveLength(0);
  });

  it("TEST 2: should reinforce existing concept with same status", () => {
    const request: MemoryUpdateRequest = {
      ...baseRequest,
      session_model: {
        ...baseSessionModel,
        concepts: {derivatives: {status: "mastered", attempts: 3}},
      },
      current_memory: [
        {
          path: "subjects/math/calculus/derivatives",
          content: "mastered",
          confidence: 0.7,
          lastUpdated: "2024-01-10T10:00:00Z",
          updateCount: 1,
          sourceSessionIds: ["session-old"],
        },
      ],
    };

    const result = processRuleBased(request);

    const conceptUpdate = result.updates.find(
      (u) => u.path === "subjects/math/calculus/derivatives"
    );
    expect(conceptUpdate).toMatchObject({
      operation: "reinforce",
      confidence_delta: 0.1,
    });
    expect(result.needsLLM).toHaveLength(0);
  });

  it("TEST 3: should defer contradiction to LLM", () => {
    const request: MemoryUpdateRequest = {
      ...baseRequest,
      session_metadata: {
        ...baseRequest.session_metadata,
        topics_covered: ["algebra"],
      },
      session_model: {
        ...baseSessionModel,
        concepts: {factoring: {status: "mastered", attempts: 8}},
      },
      current_memory: [
        {
          path: "subjects/math/algebra/factoring",
          content: "struggling",
          confidence: 0.6,
          lastUpdated: "2024-01-10T10:00:00Z",
          updateCount: 2,
          sourceSessionIds: ["session-old"],
        },
      ],
    };

    const result = processRuleBased(request);

    // Should not have update for factoring (deferred to LLM)
    const factoringUpdate = result.updates.find(
      (u) => u.path === "subjects/math/algebra/factoring"
    );
    expect(factoringUpdate).toBeUndefined();

    // Should have LLM task for contradiction
    expect(result.needsLLM).toHaveLength(1);
    expect(result.needsLLM[0]).toMatchObject({
      type: "contradiction",
      data: {
        concept: "factoring",
        status: {status: "mastered", attempts: 8},
      },
    });
  });

  it("TEST 4: should create update for new fact", () => {
    const request: MemoryUpdateRequest = {
      ...baseRequest,
      session_model: {
        ...baseSessionModel,
        facts: ["Prefers visual examples"],
      },
      current_memory: [],
    };

    const result = processRuleBased(request);

    const factUpdate = result.updates.find((u) => u.path === "root/profile");
    expect(factUpdate).toMatchObject({
      path: "root/profile",
      content: expect.stringContaining("Prefers visual examples"),
      operation: "create",
      confidence_delta: 0.7,
    });
    expect(result.needsLLM).toHaveLength(0);
  });

  it("TEST 5: should defer similar fact to LLM for merge", () => {
    const request: MemoryUpdateRequest = {
      ...baseRequest,
      session_model: {
        ...baseSessionModel,
        facts: ["Likes diagrams and visual learning"],
      },
      current_memory: [
        {
          path: "root/profile",
          content: "Prefers visual examples",
          confidence: 0.8,
          lastUpdated: "2024-01-10T10:00:00Z",
          updateCount: 2,
          sourceSessionIds: ["session-old"],
        },
      ],
    };

    const result = processRuleBased(request);

    // Should have LLM task for fact merge
    const mergeTask = result.needsLLM.find((t) => t.type === "fact_merge");
    expect(mergeTask).toBeDefined();
    expect(mergeTask?.data.newFact).toBe("Likes diagrams and visual learning");
  });

  it("TEST 6: should create signal updates", () => {
    const request: MemoryUpdateRequest = {
      ...baseRequest,
      session_model: {
        ...baseSessionModel,
        signals: {engagement: "high", frustration: "none", pace: "fast"},
      },
      current_memory: [],
    };

    const result = processRuleBased(request);

    const engagementUpdate = result.updates.find(
      (u) => u.path === "root/engagement"
    );
    const paceUpdate = result.updates.find((u) => u.path === "root/pace");

    expect(engagementUpdate).toMatchObject({
      content: expect.stringContaining("high"),
      operation: "create",
    });
    expect(paceUpdate).toMatchObject({
      content: expect.stringContaining("fast"),
      operation: "create",
    });
  });

  it("TEST 7: should handle multiple concepts with mixed outcomes", () => {
    const request: MemoryUpdateRequest = {
      ...baseRequest,
      session_metadata: {
        ...baseRequest.session_metadata,
        topics_covered: ["algebra"],
      },
      session_model: {
        ...baseSessionModel,
        concepts: {
          "quadratic equations": {status: "mastered", attempts: 5},
          "linear equations": {status: "practicing", attempts: 2},
          factoring: {status: "mastered", attempts: 8},
        },
      },
      current_memory: [
        {
          path: "subjects/math/algebra/factoring",
          content: "struggling",
          confidence: 0.6,
          lastUpdated: "2024-01-10T10:00:00Z",
          updateCount: 2,
          sourceSessionIds: ["session-old"],
        },
      ],
    };

    const result = processRuleBased(request);

    // Should have update for quadratic equations (new mastered)
    const quadraticUpdate = result.updates.find(
      (u) => u.path === "subjects/math/algebra/quadratic_equations"
    );
    expect(quadraticUpdate).toBeDefined();
    expect(quadraticUpdate?.operation).toBe("create");

    // Should NOT have update for linear equations (practicing is not significant)
    const linearUpdate = result.updates.find((u) =>
      u.path.includes("linear_equations")
    );
    expect(linearUpdate).toBeUndefined();

    // Should defer factoring contradiction to LLM
    expect(result.needsLLM).toHaveLength(1);
    expect(result.needsLLM[0].type).toBe("contradiction");
  });

  it("TEST 8: should handle empty session with only signals", () => {
    const request: MemoryUpdateRequest = {
      ...baseRequest,
      session_model: {
        ...baseSessionModel,
        concepts: {},
        facts: [],
        signals: {engagement: "medium", frustration: "none", pace: "normal"},
      },
      current_memory: [],
    };

    const result = processRuleBased(request);

    // Should only have signal updates
    expect(result.updates).toHaveLength(2); // engagement and pace
    expect(result.updates.some((u) => u.path === "root/engagement")).toBe(true);
    expect(result.updates.some((u) => u.path === "root/pace")).toBe(true);
    expect(result.needsLLM).toHaveLength(0);
  });
});

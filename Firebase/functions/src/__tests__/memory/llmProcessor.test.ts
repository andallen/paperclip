// llmProcessor.test.ts
// Tests for LLM-based memory processing based on llmContract.ts test cases.
// Uses mocked Gemini responses.

import {processLLMTasks, LLMClient} from "../../memory/llmProcessor";
import {LLMTask} from "../../memory/rules";
import {MemoryNode} from "../../memory/memorySchema";

// Mock LLM client for testing.
const createMockClient = (responses: Record<string, object>): LLMClient => ({
  generateContent: jest.fn().mockImplementation(async (prompt: string) => {
    // Find matching response based on prompt content.
    for (const [key, response] of Object.entries(responses)) {
      if (prompt.includes(key)) {
        return JSON.stringify(response);
      }
    }
    // Default response.
    return JSON.stringify({decision: "keep_both"});
  }),
});

// Helper to create a base memory node.
const createNode = (path: string, content: string): MemoryNode => ({
  path,
  content,
  confidence: 0.7,
  lastUpdated: "2024-01-15T10:30:00Z",
  updateCount: 1,
  sourceSessionIds: ["session-old"],
});

describe("processLLMTasks - fact_merge", () => {
  it("TEST 1: should merge clearly related facts", async () => {
    const mockClient = createMockClient({
      "Likes diagrams": {
        decision: "merge",
        merged_content: "Visual learner - prefers diagrams and examples",
        reasoning: "Both facts describe visual learning preference",
      },
    });

    const tasks: LLMTask[] = [
      {
        type: "fact_merge",
        data: {
          newFact: "Likes diagrams",
          similarFact: createNode("root/profile", "Prefers visual examples"),
        },
      },
    ];

    const updates = await processLLMTasks(tasks, mockClient);

    expect(updates).toHaveLength(1);
    expect(updates[0]).toMatchObject({
      path: "root/profile",
      content: "Visual learner - prefers diagrams and examples",
      operation: "update",
    });
    expect(updates[0].confidence_delta).toBeGreaterThanOrEqual(0.7);
  });

  it("TEST 2: should keep distinct facts separate", async () => {
    const mockClient = createMockClient({
      "AP Calculus student": {
        decision: "keep_both",
        reasoning: "Facts are about different aspects",
      },
    });

    const tasks: LLMTask[] = [
      {
        type: "fact_merge",
        data: {
          newFact: "AP Calculus student",
          similarFact: createNode("root/profile", "Prefers visual examples"),
        },
      },
    ];

    const updates = await processLLMTasks(tasks, mockClient);

    expect(updates).toHaveLength(1);
    expect(updates[0]).toMatchObject({
      path: "root/profile",
      content: "AP Calculus student",
      operation: "create",
      confidence_delta: 0.7,
    });
  });

  it("TEST 3: should replace when new fact supersedes old", async () => {
    const mockClient = createMockClient({
      "Prefers text explanations now": {
        decision: "replace",
        reasoning: "New preference overrides old",
      },
    });

    const tasks: LLMTask[] = [
      {
        type: "fact_merge",
        data: {
          newFact: "Prefers text explanations now",
          similarFact: createNode("root/profile", "Prefers visual examples"),
        },
      },
    ];

    const updates = await processLLMTasks(tasks, mockClient);

    expect(updates).toHaveLength(1);
    expect(updates[0]).toMatchObject({
      path: "root/profile",
      content: "Prefers text explanations now",
      operation: "update",
    });
    // Lower confidence for replacement (preference changed).
    expect(updates[0].confidence_delta).toBeLessThanOrEqual(0.7);
  });
});

describe("processLLMTasks - contradiction", () => {
  it("TEST 4: should resolve struggling -> mastered progression", async () => {
    const mockClient = createMockClient({
      factoring: {
        new_content: "Mastered after initial struggle (8 attempts)",
        confidence: 0.8,
      },
    });

    const tasks: LLMTask[] = [
      {
        type: "contradiction",
        data: {
          concept: "factoring",
          status: {status: "mastered", attempts: 8},
          existing: createNode("subjects/math/algebra/factoring", "struggling"),
        },
      },
    ];

    const updates = await processLLMTasks(tasks, mockClient);

    expect(updates).toHaveLength(1);
    expect(updates[0]).toMatchObject({
      path: "subjects/math/algebra/factoring",
      content: "Mastered after initial struggle (8 attempts)",
      operation: "update",
      confidence_delta: 0.8,
    });
  });

  it("TEST 5: should resolve mastered -> struggling regression", async () => {
    const mockClient = createMockClient({
      derivatives: {
        new_content: "Struggling again (was mastered, may need review)",
        confidence: 0.7,
      },
    });

    const tasks: LLMTask[] = [
      {
        type: "contradiction",
        data: {
          concept: "derivatives",
          status: {status: "struggling", attempts: 3},
          existing: createNode(
            "subjects/math/calculus/derivatives",
            "mastered"
          ),
        },
      },
    ];

    const updates = await processLLMTasks(tasks, mockClient);

    expect(updates).toHaveLength(1);
    expect(updates[0]).toMatchObject({
      path: "subjects/math/calculus/derivatives",
      content: expect.stringContaining("Struggling"),
      operation: "update",
      confidence_delta: 0.7,
    });
  });
});

describe("processLLMTasks - ambiguous_path", () => {
  it("TEST 6: should resolve ambiguous concept to most common path", async () => {
    const mockClient = createMockClient({
      probability: {
        path: "subjects/math/statistics/probability",
        reasoning: "Probability is most commonly taught in math/statistics",
      },
    });

    const tasks: LLMTask[] = [
      {
        type: "ambiguous_path",
        data: {
          concept: "probability",
          status: {status: "mastered", attempts: 5},
        },
      },
    ];

    const updates = await processLLMTasks(tasks, mockClient);

    expect(updates).toHaveLength(1);
    expect(updates[0]).toMatchObject({
      path: "subjects/math/statistics/probability",
      content: expect.stringContaining("mastered"),
      operation: "create",
      confidence_delta: 0.7,
    });
  });
});

describe("processLLMTasks - error handling", () => {
  it("TEST 7: should return empty array on LLM failure", async () => {
    const mockClient: LLMClient = {
      generateContent: jest.fn().mockRejectedValue(new Error("API Error")),
    };

    const tasks: LLMTask[] = [
      {
        type: "fact_merge",
        data: {
          newFact: "Some fact",
          similarFact: createNode("root/profile", "Existing fact"),
        },
      },
    ];

    const updates = await processLLMTasks(tasks, mockClient);

    expect(updates).toHaveLength(0);
  });

  it("TEST 8: should return empty array on invalid LLM response", async () => {
    const mockClient: LLMClient = {
      generateContent: jest.fn().mockResolvedValue("not valid json {{{"),
    };

    const tasks: LLMTask[] = [
      {
        type: "fact_merge",
        data: {
          newFact: "Some fact",
          similarFact: createNode("root/profile", "Existing fact"),
        },
      },
    ];

    const updates = await processLLMTasks(tasks, mockClient);

    expect(updates).toHaveLength(0);
  });
});

describe("processLLMTasks - batch processing", () => {
  it("TEST 9: should process multiple tasks", async () => {
    const mockClient = createMockClient({
      "Likes diagrams": {
        decision: "merge",
        merged_content: "Visual learner",
        reasoning: "Related",
      },
      factoring: {
        new_content: "Mastered factoring",
        confidence: 0.8,
      },
    });

    const tasks: LLMTask[] = [
      {
        type: "fact_merge",
        data: {
          newFact: "Likes diagrams",
          similarFact: createNode("root/profile", "Visual examples"),
        },
      },
      {
        type: "contradiction",
        data: {
          concept: "factoring",
          status: {status: "mastered", attempts: 8},
          existing: createNode("subjects/math/algebra/factoring", "struggling"),
        },
      },
    ];

    const updates = await processLLMTasks(tasks, mockClient);

    expect(updates).toHaveLength(2);
    expect(updates.some((u) => u.path === "root/profile")).toBe(true);
    expect(updates.some((u) => u.path === "subjects/math/algebra/factoring")).toBe(
      true
    );
  });

  it("should continue processing if one task fails", async () => {
    let callCount = 0;
    const mockClient: LLMClient = {
      generateContent: jest.fn().mockImplementation(async (prompt: string) => {
        callCount++;
        if (callCount === 1) {
          throw new Error("First call fails");
        }
        return JSON.stringify({
          new_content: "Mastered factoring",
          confidence: 0.8,
        });
      }),
    };

    const tasks: LLMTask[] = [
      {
        type: "fact_merge",
        data: {
          newFact: "Some fact",
          similarFact: createNode("root/profile", "Existing"),
        },
      },
      {
        type: "contradiction",
        data: {
          concept: "factoring",
          status: {status: "mastered", attempts: 8},
          existing: createNode("subjects/math/algebra/factoring", "struggling"),
        },
      },
    ];

    const updates = await processLLMTasks(tasks, mockClient);

    // Should get result from second task even though first failed.
    expect(updates).toHaveLength(1);
    expect(updates[0].path).toBe("subjects/math/algebra/factoring");
  });
});

describe("processLLMTasks - empty input", () => {
  it("should return empty array for empty tasks", async () => {
    const mockClient = createMockClient({});

    const updates = await processLLMTasks([], mockClient);

    expect(updates).toHaveLength(0);
    expect(mockClient.generateContent).not.toHaveBeenCalled();
  });
});

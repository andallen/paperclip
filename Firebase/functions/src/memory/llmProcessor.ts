// llmProcessor.ts
// LLM-based memory processing for edge cases.
// Handles fact merging, contradiction resolution, and ambiguous path inference.

import {LLMTask} from "./rules";
import {MemoryNodeUpdate} from "./memorySchema";

// ============================================================================
// LLM CLIENT INTERFACE
// ============================================================================

// Interface for LLM client (allows mocking in tests).
export interface LLMClient {
  generateContent(prompt: string): Promise<string>;
}

// ============================================================================
// PROMPTS
// ============================================================================

// Prompt for fact merge decisions.
function createFactMergePrompt(newFact: string, existingContent: string): string {
  return `You are updating a learner's long-term memory profile.

Existing fact: "${existingContent}"
New fact from session: "${newFact}"

These facts seem related. Decide:
1. MERGE: Combine into one fact that captures both
2. KEEP_BOTH: They're distinct enough to keep separate
3. REPLACE: New fact supersedes the old one

Output ONLY valid JSON (no markdown, no explanation outside JSON):
{
  "decision": "merge" | "keep_both" | "replace",
  "merged_content": "combined fact if decision is merge",
  "reasoning": "brief explanation"
}`;
}

// Prompt for contradiction resolution.
function createContradictionPrompt(
  concept: string,
  existingContent: string,
  newStatus: string,
  attempts: number
): string {
  return `A learner's memory shows they were "${existingContent}" with ${concept}.
The latest session shows they now have status "${newStatus}" after ${attempts} attempts.

This represents a learning progression or regression. Create updated content that:
1. Reflects the new status
2. Acknowledges the change from previous status
3. Includes attempt count for context

Output ONLY valid JSON (no markdown, no explanation outside JSON):
{
  "new_content": "description of new status with progression context",
  "confidence": 0.0 to 1.0 (how confident in new status)
}`;
}

// Prompt for ambiguous path resolution.
function createAmbiguousPathPrompt(concept: string): string {
  return `Determine the most appropriate memory tree path for the concept "${concept}".

Possible subject areas:
- subjects/math/[area]/[concept] (for mathematical concepts)
- subjects/science/[area]/[concept] (for science concepts)
- subjects/english/[area]/[concept] (for language arts)
- subjects/history/[area]/[concept] (for history/social studies)
- subjects/general/[concept] (if no clear subject area)

Select the most typical educational context for this concept.

Output ONLY valid JSON (no markdown, no explanation outside JSON):
{
  "path": "full path like subjects/math/statistics/probability",
  "reasoning": "brief explanation of why this path"
}`;
}

// ============================================================================
// RESPONSE PARSING
// ============================================================================

interface FactMergeResponse {
  decision: "merge" | "keep_both" | "replace";
  merged_content?: string;
  reasoning?: string;
}

interface ContradictionResponse {
  new_content: string;
  confidence: number;
}

interface AmbiguousPathResponse {
  path: string;
  reasoning?: string;
}

// Parses JSON response from LLM, handling common issues.
function parseResponse<T>(response: string): T | null {
  try {
    // Try to extract JSON from response (handle markdown code blocks).
    let jsonStr = response;

    // Remove markdown code blocks if present.
    const jsonMatch = response.match(/```(?:json)?\s*([\s\S]*?)```/);
    if (jsonMatch) {
      jsonStr = jsonMatch[1];
    }

    return JSON.parse(jsonStr.trim()) as T;
  } catch {
    return null;
  }
}

// ============================================================================
// TASK PROCESSORS
// ============================================================================

// Processes a fact merge task.
async function processFactMerge(
  task: LLMTask,
  client: LLMClient
): Promise<MemoryNodeUpdate | null> {
  const {newFact, similarFact} = task.data;
  if (!newFact || !similarFact) return null;

  const prompt = createFactMergePrompt(newFact, similarFact.content);
  const response = await client.generateContent(prompt);
  const parsed = parseResponse<FactMergeResponse>(response);

  if (!parsed) return null;

  switch (parsed.decision) {
  case "merge":
    return {
      path: similarFact.path,
      content: parsed.merged_content || `${similarFact.content}; ${newFact}`,
      confidence_delta: 0.8,
      operation: "update",
    };

  case "keep_both":
    return {
      path: similarFact.path,
      content: newFact,
      confidence_delta: 0.7,
      operation: "create",
    };

  case "replace":
    return {
      path: similarFact.path,
      content: newFact,
      confidence_delta: 0.6,
      operation: "update",
    };

  default:
    return null;
  }
}

// Processes a contradiction task.
async function processContradiction(
  task: LLMTask,
  client: LLMClient
): Promise<MemoryNodeUpdate | null> {
  const {concept, status, existing} = task.data;
  if (!concept || !status || !existing) return null;

  const prompt = createContradictionPrompt(
    concept,
    existing.content,
    status.status,
    status.attempts
  );
  const response = await client.generateContent(prompt);
  const parsed = parseResponse<ContradictionResponse>(response);

  if (!parsed) return null;

  return {
    path: existing.path,
    content: parsed.new_content,
    confidence_delta: Math.max(0, Math.min(1, parsed.confidence)),
    operation: "update",
  };
}

// Processes an ambiguous path task.
async function processAmbiguousPath(
  task: LLMTask,
  client: LLMClient
): Promise<MemoryNodeUpdate | null> {
  const {concept, status} = task.data;
  if (!concept || !status) return null;

  const prompt = createAmbiguousPathPrompt(concept);
  const response = await client.generateContent(prompt);
  const parsed = parseResponse<AmbiguousPathResponse>(response);

  if (!parsed || !parsed.path) return null;

  return {
    path: parsed.path,
    content: status.status,
    confidence_delta: 0.7,
    operation: "create",
  };
}

// ============================================================================
// MAIN FUNCTION
// ============================================================================

// Processes all LLM tasks and returns resolved updates.
export async function processLLMTasks(
  tasks: LLMTask[],
  client: LLMClient
): Promise<MemoryNodeUpdate[]> {
  if (tasks.length === 0) return [];

  const updates: MemoryNodeUpdate[] = [];

  // Process each task independently (failure in one doesn't affect others).
  for (const task of tasks) {
    try {
      let update: MemoryNodeUpdate | null = null;

      switch (task.type) {
      case "fact_merge":
        update = await processFactMerge(task, client);
        break;

      case "contradiction":
        update = await processContradiction(task, client);
        break;

      case "ambiguous_path":
        update = await processAmbiguousPath(task, client);
        break;
      }

      if (update) {
        updates.push(update);
      }
    } catch (error) {
      // Log error but continue processing other tasks.
      console.error(`Error processing LLM task ${task.type}:`, error);
    }
  }

  return updates;
}

// ============================================================================
// PRODUCTION CLIENT (uses Gemini via genkit)
// ============================================================================

// Creates a production LLM client using Gemini.
// This will be used in the actual memory subagent endpoint.
export function createGeminiClient(): LLMClient {
  // Import dynamically to avoid issues in test environment.
  // eslint-disable-next-line @typescript-eslint/no-require-imports
  const {GoogleGenerativeAI} = require("@google/genai");

  const genAI = new GoogleGenerativeAI(process.env.GOOGLE_API_KEY);
  const model = genAI.getGenerativeModel({model: "gemini-1.5-flash"});

  return {
    generateContent: async (prompt: string): Promise<string> => {
      const result = await model.generateContent(prompt);
      return result.response.text();
    },
  };
}

// memorySubagent.ts
// Memory Subagent HTTP endpoint.
// Combines rule-based and LLM processing to generate memory updates.

import {onRequest} from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";
import {
  MemoryUpdateRequest,
  MemoryUpdateRequestSchema,
  MemoryNodeUpdate,
  MemoryUpdateResponse,
} from "./memorySchema";
import {processRuleBased} from "./rules";
import {processLLMTasks, LLMClient, createGeminiClient} from "./llmProcessor";

// ============================================================================
// TYPES
// ============================================================================

// Result from processing a memory update request.
export interface ProcessingResult {
  success: boolean;
  updates?: MemoryNodeUpdate[];
  error?: {
    code: string;
    message: string;
    details?: unknown;
  };
}

// ============================================================================
// MAIN PROCESSING FUNCTION
// ============================================================================

// Processes a memory update request and returns updates.
// This is the core logic, separated from HTTP handling for testability.
export async function processMemoryUpdateRequest(
  request: unknown,
  llmClient: LLMClient
): Promise<ProcessingResult> {
  // 1. Validate request.
  const parseResult = MemoryUpdateRequestSchema.safeParse(request);

  if (!parseResult.success) {
    return {
      success: false,
      error: {
        code: "INVALID_REQUEST",
        message: "Invalid request body",
        details: parseResult.error.issues,
      },
    };
  }

  const validRequest: MemoryUpdateRequest = parseResult.data;

  try {
    // 2. Run rule-based processing.
    const ruleResult = processRuleBased(validRequest);

    // 3. Run LLM processing for edge cases.
    let llmUpdates: MemoryNodeUpdate[] = [];
    if (ruleResult.needsLLM.length > 0) {
      try {
        llmUpdates = await processLLMTasks(ruleResult.needsLLM, llmClient);
      } catch (error) {
        // Log but don't fail - LLM is optional enhancement.
        console.error("LLM processing failed, continuing with rule-based updates:", error);
      }
    }

    // 4. Combine all updates.
    const allUpdates = [...ruleResult.updates, ...llmUpdates];

    return {
      success: true,
      updates: allUpdates,
    };
  } catch (error) {
    console.error("Memory update processing failed:", error);
    return {
      success: false,
      error: {
        code: "PROCESSING_ERROR",
        message: "Failed to process memory update",
        details: error instanceof Error ? error.message : String(error),
      },
    };
  }
}

// ============================================================================
// HTTP HANDLER (for Firebase Functions)
// ============================================================================

// Creates the HTTP handler for the memory update endpoint.
// Uses dependency injection for the LLM client (production vs test).
export function createMemoryUpdateHandler(llmClient?: LLMClient) {
  const client = llmClient || createGeminiClient();

  return async (req: {body: unknown}): Promise<{
    status: number;
    body: MemoryUpdateResponse | {error: string; details?: unknown};
  }> => {
    const result = await processMemoryUpdateRequest(req.body, client);

    if (!result.success) {
      return {
        status: result.error?.code === "INVALID_REQUEST" ? 400 : 500,
        body: {
          error: result.error?.message || "Unknown error",
          details: result.error?.details,
        },
      };
    }

    return {
      status: 200,
      body: {
        updates: result.updates || [],
      },
    };
  };
}

// ============================================================================
// FIREBASE FUNCTION EXPORT
// ============================================================================

// Memory update endpoint.
// POST /memoryUpdate
// Body: MemoryUpdateRequest
// Response: MemoryUpdateResponse | {error: string, details?: unknown}
export const memoryUpdate = onRequest({cors: true, maxInstances: 5}, async (req, res) => {
  // Only allow POST requests.
  if (req.method !== "POST") {
    res.status(405).send({error: "Method not allowed. Use POST."});
    return;
  }

  logger.info("Memory update request received");

  const llmClient = createGeminiClient();
  const result = await processMemoryUpdateRequest(req.body, llmClient);

  if (!result.success) {
    const statusCode = result.error?.code === "INVALID_REQUEST" ? 400 : 500;
    logger.error("Memory update failed", {error: result.error});
    res.status(statusCode).send({
      error: result.error?.message || "Unknown error",
      details: result.error?.details,
    });
    return;
  }

  logger.info("Memory update successful", {updateCount: result.updates?.length || 0});
  res.status(200).send({
    updates: result.updates || [],
  } as MemoryUpdateResponse);
});

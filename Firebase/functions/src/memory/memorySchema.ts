// memorySchema.ts
// Zod schemas for the memory system.
// These schemas define the structure for long-term memory storage and updates.

import {z} from "zod";

// ============================================================================
// MEMORY NODE - Stored in Firestore
// ============================================================================

// A single node in the memory tree.
// Path examples: "root/profile", "subjects/math/calculus/derivatives", "pedagogy/explanations"
export const MemoryNodeSchema = z.object({
  // Tree path using lowercase alphanumeric, underscores, and slashes.
  path: z.string().regex(
    /^[a-z0-9_\/]+$/,
    "Path must be lowercase alphanumeric with underscores and slashes"
  ),

  // The encoded learning - natural language description.
  content: z.string().min(1).max(2000),

  // Confidence level 0-1. Increases when reinforced, decreases/resets on contradiction.
  confidence: z.number().min(0).max(1),

  // ISO datetime when this node was last updated.
  lastUpdated: z.string().datetime(),

  // How many times this node has been updated/reinforced.
  updateCount: z.number().int().min(0),

  // Session IDs that contributed to this node (for debugging/tracing).
  sourceSessionIds: z.array(z.string()),
});

export type MemoryNode = z.infer<typeof MemoryNodeSchema>;

// ============================================================================
// SESSION MODEL - Received from Alan
// ============================================================================

// Session goal status.
export const SessionGoalSchema = z.object({
  description: z.string(),
  status: z.enum(["active", "completed", "abandoned"]),
  progress: z.number().min(0).max(100),
});

// Concept learning status.
export const ConceptStatusSchema = z.object({
  status: z.enum(["introduced", "practicing", "mastered", "struggling"]),
  attempts: z.number().int().min(0),
});

// Session engagement signals.
export const SessionSignalsSchema = z.object({
  engagement: z.enum(["high", "medium", "low"]),
  frustration: z.enum(["none", "mild", "high"]),
  pace: z.enum(["fast", "normal", "slow"]),
});

// Full session model as updated by Alan during a tutoring session.
export const SessionModelSchema = z.object({
  session_id: z.string(),
  turn_count: z.number().int().min(0),
  goal: SessionGoalSchema.nullable(),
  concepts: z.record(z.string(), ConceptStatusSchema),
  signals: SessionSignalsSchema,
  facts: z.array(z.string()),
});

export type SessionGoal = z.infer<typeof SessionGoalSchema>;
export type ConceptStatus = z.infer<typeof ConceptStatusSchema>;
export type SessionSignals = z.infer<typeof SessionSignalsSchema>;
export type SessionModel = z.infer<typeof SessionModelSchema>;

// ============================================================================
// MEMORY UPDATE REQUEST - Sent by iOS to memory subagent
// ============================================================================

// Metadata about the session for context.
export const SessionMetadataSchema = z.object({
  session_id: z.string(),
  topics_covered: z.array(z.string()),
  duration_minutes: z.number().min(0),
  turn_count: z.number().int().min(0),
});

// Request to update long-term memory based on session data.
export const MemoryUpdateRequestSchema = z.object({
  user_id: z.string().min(1),
  session_model: SessionModelSchema,
  session_metadata: SessionMetadataSchema,
  current_memory: z.array(MemoryNodeSchema),
});

export type SessionMetadata = z.infer<typeof SessionMetadataSchema>;
export type MemoryUpdateRequest = z.infer<typeof MemoryUpdateRequestSchema>;

// ============================================================================
// MEMORY UPDATE RESPONSE - Returned by memory subagent
// ============================================================================

// Operations the memory system can perform on a node.
export const MemoryOperationSchema = z.enum(["create", "update", "reinforce"]);

// A single update to apply to the memory tree.
export const MemoryNodeUpdateSchema = z.object({
  // Target path in the memory tree.
  path: z.string().regex(/^[a-z0-9_\/]+$/),

  // New or updated content for this node.
  content: z.string().min(1).max(2000),

  // How to adjust confidence.
  confidence_delta: z.number().min(-1).max(1),

  // What operation to perform.
  operation: MemoryOperationSchema,
});

// Response from memory subagent with all updates to apply.
export const MemoryUpdateResponseSchema = z.object({
  updates: z.array(MemoryNodeUpdateSchema),
});

export type MemoryOperation = z.infer<typeof MemoryOperationSchema>;
export type MemoryNodeUpdate = z.infer<typeof MemoryNodeUpdateSchema>;
export type MemoryUpdateResponse = z.infer<typeof MemoryUpdateResponseSchema>;

// ============================================================================
// HELPER FUNCTIONS
// ============================================================================

// Converts a tree path to a Firestore document ID.
// Example: "subjects/math/calculus" -> "subjects__math__calculus"
export function pathToDocId(path: string): string {
  return path.replace(/\//g, "__");
}

// Converts a Firestore document ID back to a tree path.
// Example: "subjects__math__calculus" -> "subjects/math/calculus"
export function docIdToPath(docId: string): string {
  return docId.replace(/__/g, "/");
}

// Checks if prefix is a prefix of path.
// Example: isPathPrefix("subjects/math", "subjects/math/calculus") -> true
export function isPathPrefix(prefix: string, path: string): boolean {
  if (prefix === path) return true;
  return path.startsWith(prefix + "/");
}

// Returns the depth of a path in the tree.
// Example: getPathDepth("root") -> 1
// Example: getPathDepth("subjects/math/calculus") -> 3
export function getPathDepth(path: string): number {
  return path.split("/").length;
}

// Returns the parent path or null if at root level.
// Example: getParentPath("subjects/math/calculus") -> "subjects/math"
// Example: getParentPath("root") -> null
export function getParentPath(path: string): string | null {
  const parts = path.split("/");
  if (parts.length <= 1) return null;
  return parts.slice(0, -1).join("/");
}

// Creates a new MemoryNode with default values.
export function createMemoryNode(
  path: string,
  content: string,
  sessionId: string,
  confidence: number = 0.7
): MemoryNode {
  return {
    path,
    content,
    confidence,
    lastUpdated: new Date().toISOString(),
    updateCount: 1,
    sourceSessionIds: [sessionId],
  };
}

// Applies an update to an existing node or creates a new one.
export function applyUpdate(
  existing: MemoryNode | undefined,
  update: MemoryNodeUpdate,
  sessionId: string
): MemoryNode {
  const now = new Date().toISOString();

  if (!existing || update.operation === "create") {
    return {
      path: update.path,
      content: update.content,
      confidence: Math.max(0, Math.min(1, update.confidence_delta)),
      lastUpdated: now,
      updateCount: 1,
      sourceSessionIds: [sessionId],
    };
  }

  if (update.operation === "reinforce") {
    return {
      ...existing,
      content: update.content,
      confidence: Math.max(0, Math.min(1, existing.confidence + update.confidence_delta)),
      lastUpdated: now,
      updateCount: existing.updateCount + 1,
      sourceSessionIds: [...existing.sourceSessionIds, sessionId],
    };
  }

  // update operation (contradiction)
  return {
    ...existing,
    content: update.content,
    confidence: Math.max(0, Math.min(1, update.confidence_delta)),
    lastUpdated: now,
    updateCount: existing.updateCount + 1,
    sourceSessionIds: [...existing.sourceSessionIds, sessionId],
  };
}

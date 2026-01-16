// rules.ts
// Rule-based memory processing.
// Handles deterministic updates; defers edge cases to LLM.

import {
  MemoryNode,
  MemoryNodeUpdate,
  MemoryUpdateRequest,
  ConceptStatus,
} from "./memorySchema";

// ============================================================================
// TYPES
// ============================================================================

// Task that needs LLM processing.
export interface LLMTask {
  type: "fact_merge" | "contradiction" | "ambiguous_path";
  data: {
    concept?: string;
    status?: ConceptStatus;
    existing?: MemoryNode;
    newFact?: string;
    similarFact?: MemoryNode;
  };
}

// Result from rule-based processing.
export interface RuleBasedResult {
  updates: MemoryNodeUpdate[];
  needsLLM: LLMTask[];
}

// ============================================================================
// SUBJECT MAPPING
// ============================================================================

// Maps topic keywords to subject areas.
const SUBJECT_KEYWORDS: Record<string, string[]> = {
  math: [
    "algebra", "calculus", "geometry", "trigonometry", "statistics",
    "arithmetic", "math", "mathematics", "precalculus", "linear_algebra",
  ],
  science: [
    "physics", "chemistry", "biology", "earth_science", "science",
    "astronomy", "ecology", "genetics",
  ],
  english: [
    "writing", "reading", "grammar", "literature", "english",
    "composition", "rhetoric",
  ],
  history: [
    "us_history", "world_history", "civics", "history", "government",
    "economics", "geography",
  ],
};

// Maps specific topics to their parent area within a subject.
const TOPIC_TO_AREA: Record<string, {subject: string; area: string}> = {
  calculus: {subject: "math", area: "calculus"},
  algebra: {subject: "math", area: "algebra"},
  geometry: {subject: "math", area: "geometry"},
  trigonometry: {subject: "math", area: "trigonometry"},
  statistics: {subject: "math", area: "statistics"},
  precalculus: {subject: "math", area: "precalculus"},
  linear_algebra: {subject: "math", area: "linear_algebra"},
  physics: {subject: "science", area: "physics"},
  chemistry: {subject: "science", area: "chemistry"},
  biology: {subject: "science", area: "biology"},
  earth_science: {subject: "science", area: "earth_science"},
};

// ============================================================================
// PATH INFERENCE
// ============================================================================

// Maps a concept name to a tree path using topic hints.
export function inferPath(concept: string, topicsHint: string[]): string {
  // Normalize concept: lowercase, replace spaces with underscores.
  const normalizedConcept = concept.toLowerCase().replace(/\s+/g, "_");

  // Normalize hints.
  const normalizedHints = topicsHint.map((h) => h.toLowerCase());

  // Try to find a specific topic area from hints.
  let subject: string | null = null;
  let area: string | null = null;

  for (const hint of normalizedHints) {
    // Check if hint is a specific topic area.
    if (TOPIC_TO_AREA[hint]) {
      subject = TOPIC_TO_AREA[hint].subject;
      area = TOPIC_TO_AREA[hint].area;
      break;
    }
  }

  // If no specific area found, try to find subject from hints.
  if (!subject) {
    for (const hint of normalizedHints) {
      for (const [subj, keywords] of Object.entries(SUBJECT_KEYWORDS)) {
        if (keywords.includes(hint)) {
          subject = subj;
          break;
        }
      }
      if (subject) break;
    }
  }

  // Build path.
  if (subject && area) {
    return `subjects/${subject}/${area}/${normalizedConcept}`;
  } else if (subject) {
    return `subjects/${subject}/${normalizedConcept}`;
  } else {
    return `subjects/general/${normalizedConcept}`;
  }
}

// ============================================================================
// STATUS MATCHING
// ============================================================================

// Checks if existing node content matches new status.
export function statusMatches(
  existingContent: string,
  newStatus: ConceptStatus
): boolean {
  const contentLower = existingContent.toLowerCase();
  const statusLower = newStatus.status.toLowerCase();

  // Check if the key status word appears in the content.
  if (statusLower === "mastered") {
    return contentLower.includes("mastered");
  } else if (statusLower === "struggling") {
    return contentLower.includes("struggling");
  }

  return false;
}

// ============================================================================
// FACT SIMILARITY
// ============================================================================

// Common words to ignore when comparing facts.
const STOP_WORDS = new Set([
  "a", "an", "the", "is", "are", "was", "were", "be", "been", "being",
  "have", "has", "had", "do", "does", "did", "will", "would", "could",
  "should", "may", "might", "must", "shall", "can", "need", "dare",
  "to", "of", "in", "for", "on", "with", "at", "by", "from", "as",
  "into", "through", "during", "before", "after", "above", "below",
  "between", "under", "again", "further", "then", "once", "and", "but",
  "or", "nor", "so", "yet", "both", "either", "neither", "not", "only",
  "own", "same", "than", "too", "very", "just", "also",
]);

// Extracts significant words from text.
function extractKeywords(text: string): Set<string> {
  const words = text.toLowerCase().split(/\W+/).filter((w) => w.length > 2);
  return new Set(words.filter((w) => !STOP_WORDS.has(w)));
}

// Finds an existing fact that might be similar to the new fact.
export function findSimilarFact(
  newFact: string,
  existingNodes: MemoryNode[]
): MemoryNode | null {
  // Only check profile nodes.
  const profileNodes = existingNodes.filter((n) =>
    n.path.startsWith("root/profile")
  );

  if (profileNodes.length === 0) return null;

  const newKeywords = extractKeywords(newFact);
  if (newKeywords.size === 0) return null;

  // Find node with most keyword overlap.
  let bestMatch: MemoryNode | null = null;
  let bestOverlap = 0;

  for (const node of profileNodes) {
    const existingKeywords = extractKeywords(node.content);
    if (existingKeywords.size === 0) continue;

    // Count overlapping keywords.
    let overlap = 0;
    for (const keyword of newKeywords) {
      if (existingKeywords.has(keyword)) {
        overlap++;
      }
    }

    // Also check for semantic similarity with common learning-related words.
    const semanticPairs: [string, string][] = [
      ["visual", "diagram"],
      ["visual", "picture"],
      ["visual", "image"],
      ["fast", "quick"],
      ["slow", "careful"],
      ["like", "prefer"],
      ["enjoy", "prefer"],
      ["learner", "learning"],
      ["learner", "concepts"],
      ["quick", "concepts"],
      ["fast", "concepts"],
    ];

    for (const [word1, word2] of semanticPairs) {
      if (
        (newKeywords.has(word1) && existingKeywords.has(word2)) ||
        (newKeywords.has(word2) && existingKeywords.has(word1))
      ) {
        overlap += 0.5; // Partial credit for semantic match.
      }
    }

    // Require at least 1 keyword overlap to consider similar.
    if (overlap >= 1 && overlap > bestOverlap) {
      bestOverlap = overlap;
      bestMatch = node;
    }
  }

  return bestMatch;
}

// ============================================================================
// MAIN PROCESSING FUNCTION
// ============================================================================

// Processes a memory update request using deterministic rules.
export function processRuleBased(request: MemoryUpdateRequest): RuleBasedResult {
  const updates: MemoryNodeUpdate[] = [];
  const needsLLM: LLMTask[] = [];

  const {session_model, session_metadata, current_memory} = request;

  // 1. Process concepts.
  for (const [concept, status] of Object.entries(session_model.concepts)) {
    // Only process significant statuses.
    if (status.status !== "mastered" && status.status !== "struggling") {
      continue;
    }

    // Infer path for this concept.
    const path = inferPath(concept, session_metadata.topics_covered);

    // Check if path exists in current memory.
    const existing = current_memory.find((n) => n.path === path);

    if (!existing) {
      // New concept: create.
      updates.push({
        path,
        content: status.status,
        confidence_delta: 0.7,
        operation: "create",
      });
    } else if (statusMatches(existing.content, status)) {
      // Same status: reinforce.
      updates.push({
        path,
        content: `${status.status} - reinforced`,
        confidence_delta: 0.1,
        operation: "reinforce",
      });
    } else {
      // Contradiction: defer to LLM.
      needsLLM.push({
        type: "contradiction",
        data: {
          concept,
          status,
          existing,
        },
      });
    }
  }

  // 2. Process facts.
  for (const fact of session_model.facts) {
    // Check for similar existing fact.
    const similarFact = findSimilarFact(fact, current_memory);

    if (!similarFact) {
      // New unique fact: create in profile.
      updates.push({
        path: "root/profile",
        content: fact,
        confidence_delta: 0.7,
        operation: "create",
      });
    } else {
      // Similar fact exists: defer to LLM for merge decision.
      needsLLM.push({
        type: "fact_merge",
        data: {
          newFact: fact,
          similarFact,
        },
      });
    }
  }

  // 3. Process signals.
  const {signals} = session_model;

  // Create engagement update.
  updates.push({
    path: "root/engagement",
    content: `${signals.engagement} engagement`,
    confidence_delta: 0.7,
    operation: "create",
  });

  // Create pace update.
  updates.push({
    path: "root/pace",
    content: `${signals.pace} pace`,
    confidence_delta: 0.7,
    operation: "create",
  });

  return {updates, needsLLM};
}

// embedSubagent.ts
// Generates EmbedContent blocks for interactive external tools.
// Supports PhET, Desmos, CircuitJS, and YouTube.
// Returns complete URLs; iOS simply displays them in WKWebView.

import * as logger from "firebase-functions/logger";
import {
  SubagentRequest,
  SubagentResponse,
  VisualRouterDecision,
  ResponseMetadata,
  generateBlockId,
  currentTimestamp,
  readyResponse,
  failedResponse,
} from "./types";

// Known PhET simulations with their IDs.
const PHET_SIMULATIONS: Record<string, string> = {
  "projectile motion": "projectile-motion",
  "projectile": "projectile-motion",
  "gravity": "gravity-force-lab",
  "gravity force": "gravity-force-lab",
  "forces": "forces-and-motion-basics",
  "friction": "friction",
  "pendulum": "pendulum-lab",
  "wave": "wave-on-a-string",
  "waves": "wave-interference",
  "sound": "sound",
  "circuit": "circuit-construction-kit-dc",
  "circuits": "circuit-construction-kit-dc",
  "resistance": "resistance-in-a-wire",
  "ohms law": "ohms-law",
  "energy": "energy-skate-park-basics",
  "skate park": "energy-skate-park",
  "atom": "build-an-atom",
  "molecule": "molecule-shapes",
  "states of matter": "states-of-matter-basics",
  "ph scale": "ph-scale",
  "concentration": "concentration",
  "balancing equations": "balancing-chemical-equations",
  "area": "area-model-algebra",
  "fractions": "fractions-intro",
  "graphing": "graphing-lines",
  "quadratics": "graphing-quadratics",
  "trig": "trig-tour",
  "natural selection": "natural-selection",
  "gene expression": "gene-expression-essentials",
};

// URL builder functions for each provider.

// Builds PhET simulation URL.
function buildPhETUrl(simulationId: string, language: string = "en"): string {
  return `https://phet.colorado.edu/sims/html/${simulationId}/latest/${simulationId}_${language}.html`;
}

// Builds Desmos calculator URL.
function buildDesmosUrl(calculatorType: string = "graphing"): string {
  const paths: Record<string, string> = {
    graphing: "calculator",
    scientific: "scientific",
    fourfunction: "fourfunction",
    geometry: "geometry",
  };
  return `https://www.desmos.com/${paths[calculatorType] || "calculator"}`;
}

// Builds YouTube embed URL with parameters.
// Uses youtube-nocookie.com for privacy-enhanced embedding.
function buildYouTubeUrl(
  videoId: string,
  startTime?: number,
  autoplay: boolean = false
): string {
  // Use nocookie domain to avoid playback errors in WKWebView.
  const base = `https://www.youtube-nocookie.com/embed/${videoId}`;

  // Only add params if needed.
  const params = new URLSearchParams();
  if (startTime) params.set("start", String(startTime));
  if (autoplay) params.set("autoplay", "1");

  const paramString = params.toString();
  return paramString ? `${base}?${paramString}` : base;
}

// Builds CircuitJS URL with optional circuit data.
function buildCircuitJSUrl(circuitData?: string): string {
  const base = "https://www.falstad.com/circuit/circuitjs.html";
  if (circuitData) {
    return `${base}?ctz=${encodeURIComponent(circuitData)}`;
  }
  return base;
}

// Returns aspect ratio for provider.
function getAspectRatio(provider: string): number {
  switch (provider) {
  case "youtube":
    return 16 / 9; // 1.777
  case "phet":
    return 16 / 10; // 1.6
  case "desmos":
    return 4 / 3; // 1.333
  case "circuitjs":
    return 16 / 10;
  default:
    return 16 / 9;
  }
}

// Result from inferEmbed containing URL and metadata.
interface EmbedResult {
  provider: string;
  url: string;
  caption: string;
  simulationMatched?: string;
}

/**
 * Executes embed generation subagent.
 * Returns complete URLs ready for iOS WKWebView rendering.
 */
export async function executeEmbedSubagent(
  request: SubagentRequest,
  apiKey: string,
  decision: VisualRouterDecision
): Promise<SubagentResponse> {
  const startTime = Date.now();

  logger.info("Embed subagent executing", {
    concept: request.concept,
    intent: request.intent,
    recommendation: decision.specific_recommendation,
  });

  try {
    // Determine provider and URL.
    const embedResult = inferEmbed(
      request.concept,
      request.description,
      decision.specific_recommendation
    );

    // Build EmbedContent with complete URL.
    const embedContent = {
      url: embedResult.url,
      provider: embedResult.provider,
      sizing: {
        width: "100%",
        aspect_ratio: getAspectRatio(embedResult.provider),
      },
      caption: embedResult.caption,
      allow_fullscreen: true,
    };

    // Build complete Block.
    const block = {
      id: generateBlockId(),
      type: "embed" as const,
      created_at: currentTimestamp(),
      status: "ready" as const,
      content: embedContent,
    };

    // Build response metadata.
    const metadata: ResponseMetadata = {
      fulfillment_method: "embed_match",
      latency_ms: Date.now() - startTime,
      provider: embedResult.provider,
      simulation_matched: embedResult.simulationMatched,
    };

    logger.info("Embed subagent completed", {
      blockId: block.id,
      provider: embedResult.provider,
      url: embedResult.url,
      simulationMatched: embedResult.simulationMatched,
      latencyMs: metadata.latency_ms,
    });

    return readyResponse(request.id, block, metadata);
  } catch (error) {
    logger.error("Embed generation failed", {error, requestId: request.id});
    return failedResponse(
      request.id,
      "generation_failed",
      error instanceof Error ? error.message : "Unknown error",
      {latency_ms: Date.now() - startTime}
    );
  }
}

/**
 * Infers the embed provider and builds complete URL from concept/description.
 * Returns URL ready for iOS WKWebView rendering.
 */
function inferEmbed(
  concept: string,
  description: string,
  recommendation: string | undefined
): EmbedResult {
  const searchText = `${concept} ${description} ${recommendation || ""}`.toLowerCase();

  // Check for PhET simulations.
  for (const [keyword, simId] of Object.entries(PHET_SIMULATIONS)) {
    if (searchText.includes(keyword)) {
      // Format simulation name for caption (e.g., "projectile-motion" -> "Projectile Motion").
      const simName = simId
        .split("-")
        .map((word) => word.charAt(0).toUpperCase() + word.slice(1))
        .join(" ");

      return {
        provider: "phet",
        url: buildPhETUrl(simId),
        caption: `PhET: ${simName}`,
        simulationMatched: simId,
      };
    }
  }

  // Check for Desmos.
  if (
    searchText.includes("desmos") ||
    searchText.includes("graphing calculator") ||
    (searchText.includes("graph") && searchText.includes("function"))
  ) {
    return {
      provider: "desmos",
      url: buildDesmosUrl("graphing"),
      caption: "Desmos Graphing Calculator",
      simulationMatched: "desmos-graphing",
    };
  }

  // Check for CircuitJS.
  if (searchText.includes("circuit") && !searchText.includes("phet")) {
    return {
      provider: "circuitjs",
      url: buildCircuitJSUrl(),
      caption: "Circuit Simulator",
      simulationMatched: "circuitjs",
    };
  }

  // Check for YouTube.
  if (searchText.includes("video") || searchText.includes("youtube")) {
    // Extract video ID from description if present.
    const videoIdMatch = description.match(
      /(?:youtube\.com\/(?:watch\?v=|embed\/)|youtu\.be\/)([a-zA-Z0-9_-]{11})/
    );
    const videoId = videoIdMatch ? videoIdMatch[1] : "dQw4w9WgXcQ";

    return {
      provider: "youtube",
      url: buildYouTubeUrl(videoId),
      caption: "Video",
      simulationMatched: videoIdMatch ? `youtube-${videoId}` : "youtube-placeholder",
    };
  }

  // Default to PhET projectile motion as a safe fallback.
  return {
    provider: "phet",
    url: buildPhETUrl("projectile-motion"),
    caption: "PhET: Projectile Motion",
    simulationMatched: "projectile-motion",
  };
}

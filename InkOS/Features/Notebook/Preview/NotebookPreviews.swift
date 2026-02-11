//
// NotebookPreviews.swift
// InkOS
//
// Preview data for development and testing.
// Realistic tutoring scenarios demonstrating kinetic typography in context.
// Uses design tokens for consistent typography hierarchy and spacing.
// User controls pacing by tapping to advance through blocks.
//

import Foundation

// MARK: - NotebookDocument Preview Extension

extension NotebookDocument {
  // Embed block testing.
  // Embeds are for external content that can't be recreated (videos, maps, 3D models).
  // Simulations and interactive visualizations should use the graphics block instead.
  static var preview: NotebookDocument {
    NotebookDocument(
      title: "Embed Block Testing",
      blocks: [
        // Header
        Block.text(
          content: TextContent(
            segments: [
              .plain(
                text: "Embed Examples",
                style: TextStyle(size: .title, weight: .bold)
              )
            ]
          )),

        // YouTube video - external educational content
        Block.embed(
          content: EmbedContent(
            url: "https://www.youtube-nocookie.com/embed/CAkMUdeB06o",
            provider: "youtube",
            sizing: EmbedSizing(width: "100%", aspectRatio: 16.0 / 9.0),
            caption: "Video: Pythagorean Theorem"
          ))
      ]
    )
  }

  // Minimal preview for quick testing.
  static var minimal: NotebookDocument {
    NotebookDocument(
      title: "Quick Test",
      blocks: [
        Block.text(
          content: TextContent(
            segments: [
              .kinetic(
                text: "Hello! I'm Alan.",
                animation: .typewriter,
                durationMs: 1500,
                delayMs: 0,
                style: TextStyle(size: .title, weight: .medium)
              )
            ]
          ))
      ]
    )
  }
}

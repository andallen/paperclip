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
  // Combined preview testing image and embed blocks.
  static var preview: NotebookDocument {
    NotebookDocument(
      title: "Block Testing",
      blocks: [
        // IMAGE TEST - Near top for quick visual verification
        Block.image(
          content: ImageContent(
            source: .url(url: "https://picsum.photos/800/500"),
            altText: "Random landscape photo",
            caption: "A sample image from Lorem Picsum",
            attribution: ImageAttribution(source: "Lorem Picsum", license: "Free to use"),
            border: ImageBorder(enabled: true, color: "#E0E0E0", width: 1, radius: 12)
          )),

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
          )),

        // Brief intro text
        Block.text(
          content: TextContent(
            segments: [
              .kinetic(
                text: "Let's explore the Pythagorean Theorem.",
                animation: .typewriter,
                durationMs: 1500,
                delayMs: 0,
                style: TextStyle(size: .title, weight: .medium)
              )
            ]
          )),

        // Hidden checkpoint - pause point after the hook.
        Block.checkpoint(),

        // Display-mode LaTeX is centered by default.
        Block.text(
          content: TextContent(
            segments: [
              .latex(latex: "a^2 + b^2 = c^2", displayMode: true)
            ],
            alignment: .center
          )),
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

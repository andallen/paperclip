//
// NotebookPreviews.swift
// InkOS
//
// Preview data for development and testing.
// Realistic tutoring scenarios demonstrating kinetic typography in context.
// Uses design tokens for consistent typography hierarchy and spacing.
// User controls pacing by tapping to advance through blocks.
// Persistent canvas input at the bottom allows user to message Alan at any time.
//

import Foundation

// MARK: - NotebookDocument Preview Extension

extension NotebookDocument {
  // Combined preview testing image, embed, and input blocks.
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
                text: "The Pythagorean Theorem:",
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

        // Formula.
        Block.text(
          content: TextContent(
            segments: [
              .latex(latex: "a^2 + b^2 = c^2", displayMode: true)
            ],
            alignment: .center
          )),

        // Explanation text.
        Block.text(
          content: TextContent(
            segments: [
              .plain(
                text: "Use the input below to ask questions or show your work."
              )
            ]
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

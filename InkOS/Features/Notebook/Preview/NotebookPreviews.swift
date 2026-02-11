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
  // Quick preview for testing the persistent canvas input.
  static var preview: NotebookDocument {
    NotebookDocument(
      title: "Canvas Input Test",
      blocks: [
        // Brief intro.
        Block.text(
          content: TextContent(
            segments: [
              .plain(
                text: "The Pythagorean Theorem:",
                style: TextStyle(size: .title, weight: .bold)
              )
            ]
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

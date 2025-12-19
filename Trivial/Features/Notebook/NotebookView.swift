import PencilKit
import SwiftUI

// The Notebook Editor displays a single Notebook and lets the user write ink.
// It is responsible for the editing experience (drawing, scrolling, zooming, and showing ink on screen).
struct NotebookView: View {
  // The in-memory representation of the Notebook.
  let model: NotebookModel

  // The handle for safe file operations. Stored for future save/load operations.
  let documentHandle: DocumentHandle

  var body: some View {
    ZStack {
      BackgroundWhite()
        .ignoresSafeArea()
        .allowsHitTesting(false)

      VStack(spacing: 0) {
        Text(model.displayName)
          .font(.system(size: 32, weight: .semibold))
          .foregroundStyle(Color.ink)
          .padding(.top, 24)
          .padding(.bottom, 16)

        DrawingCanvas()
      }
    }
    .fontDesign(.rounded)
    .navigationBarTitleDisplayMode(.inline)
  }
}

// Drawing canvas that wraps PencilKit for ink input.
// Supports Apple Pencil and finger drawing with vertical scrolling.
private struct DrawingCanvas: View {
  var body: some View {
    // The canvas fills the available space below the title.
    PKCanvasViewRepresentable()
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(Color.white)
  }
}

// UIViewRepresentable wrapper for PKCanvasView.
// This bridges PencilKit (UIKit) to SwiftUI.
private struct PKCanvasViewRepresentable: UIViewRepresentable {
  // The height of the scrollable canvas area in points.
  // This allows the user to scroll and draw on a long vertical surface.
  private let canvasHeight: CGFloat = 5000

  func makeUIView(context: Context) -> PKCanvasView {
    let canvasView = PKCanvasView()
    canvasView.drawingPolicy = .anyInput
    canvasView.tool = PKInkingTool(.pen, color: .black, width: 5)
    canvasView.backgroundColor = .white
    canvasView.isOpaque = true
    canvasView.isUserInteractionEnabled = true
    canvasView.isScrollEnabled = true
    return canvasView
  }

  func updateUIView(_ canvasView: PKCanvasView, context: Context) {
    // Set content size for vertical scrolling once the view has a valid width.
    if canvasView.bounds.width > 0 {
      canvasView.contentSize = CGSize(width: canvasView.bounds.width, height: canvasHeight)
    }

    // Ensure the canvas can receive pencil input.
    if canvasView.window != nil, !canvasView.isFirstResponder {
      DispatchQueue.main.async { canvasView.becomeFirstResponder() }
    }
  }
}

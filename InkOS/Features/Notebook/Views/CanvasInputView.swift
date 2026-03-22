//
// CanvasView.swift
// InkOS
//
// UIViewRepresentable wrapper for PKCanvasView.
// Pencil-only drawing with finger gestures propagating to parent ScrollView.
//

import PencilKit
import SwiftUI

// MARK: - CanvasView

// UIViewRepresentable wrapper for PKCanvasView.
struct CanvasView: UIViewRepresentable {
  @Binding var drawing: PKDrawing

  // Whether the canvas accepts pencil input.
  var isInteractive: Bool = true

  // Callback when user starts drawing.
  var onDrawingBegan: (() -> Void)?

  // Callback when drawing changes (for auto-save).
  var onDrawingChanged: (() -> Void)?

  // Callback when canvas view is created (for toolbar integration).
  var onCanvasViewCreated: ((PKCanvasView) -> Void)?

  func makeUIView(context: Context) -> PKCanvasView {
    let canvas = PKCanvasView()
    canvas.drawing = drawing
    canvas.delegate = context.coordinator
    canvas.tool = PKInkingTool(.pen, color: .black, width: 2)
    canvas.backgroundColor = .clear
    canvas.isOpaque = false
    canvas.drawingPolicy = .pencilOnly
    canvas.isScrollEnabled = false
    canvas.isUserInteractionEnabled = isInteractive

    // Restrict all gesture recognizers to pencil touches only.
    // Finger touches are unclaimed and propagate to the parent ScrollView.
    let pencilType = NSNumber(value: UITouch.TouchType.pencil.rawValue)
    for gestureRecognizer in canvas.gestureRecognizers ?? [] {
      gestureRecognizer.allowedTouchTypes = [pencilType]
    }

    onCanvasViewCreated?(canvas)
    return canvas
  }

  func updateUIView(_ uiView: PKCanvasView, context: Context) {
    // Only update if drawing has changed externally (e.g., cleared).
    if uiView.drawing != drawing {
      uiView.drawing = drawing
    }
    uiView.isUserInteractionEnabled = isInteractive
  }

  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }

  class Coordinator: NSObject, PKCanvasViewDelegate {
    var parent: CanvasView
    private var wasDrawing = false

    init(_ parent: CanvasView) {
      self.parent = parent
    }

    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
      parent.drawing = canvasView.drawing
      parent.onDrawingChanged?()
    }

    func canvasViewDidBeginUsingTool(_ canvasView: PKCanvasView) {
      if !wasDrawing {
        wasDrawing = true
        parent.onDrawingBegan?()
      }
    }

    func canvasViewDidEndUsingTool(_ canvasView: PKCanvasView) {
      wasDrawing = false
    }
  }
}

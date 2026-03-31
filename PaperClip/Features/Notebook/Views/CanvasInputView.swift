//
// CanvasView.swift
// PaperClip
//
// UIViewRepresentable wrapper for PKCanvasView.
// Pencil-only drawing with finger gestures propagating to parent ScrollView.
//

import PencilKit
import SwiftUI

// MARK: - OverlayPassthroughCanvasView

// PKCanvasView subclass with a capped content size and sibling-aware hit testing.
// The drawing surface extends below the visible area up to a hard cap,
// preventing unbounded memory growth while giving plenty of vertical space.
// Hit testing probes the full view hierarchy so SwiftUI buttons layered above
// the canvas in a ZStack reliably receive finger taps instead of the canvas.
class OverlayPassthroughCanvasView: PKCanvasView {
  // Maximum drawing height in points. At scale 2.0 this produces
  // an 8000px image — the largest Claude Code accepts.
  static let maxCanvasHeight: CGFloat = 4000

  // Flag used by hitTest to temporarily exclude self from the window's
  // hit-test walk when probing for sibling views (SwiftUI buttons).
  private var isProbing = false

  // Probe the full view hierarchy for sibling views that should receive
  // this touch instead of the canvas. Temporarily excludes self so the
  // window's hit-test finds SwiftUI buttons layered above in the ZStack.
  // Without this, the PKCanvasView (UIScrollView) intercepts finger taps
  // before SwiftUI's gesture system can route them to overlay buttons.
  override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
    // Re-entrant call during probing — hide ourselves so the window
    // continues checking sibling views.
    guard !isProbing else { return nil }

    guard let window = self.window else {
      return super.hitTest(point, with: event)
    }

    // Ask the full hierarchy who claims this point while we are excluded.
    let windowPoint = convert(point, to: window)
    isProbing = true
    let sibling = window.hitTest(windowPoint, with: event)
    isProbing = false

    // If a view outside our branch of the hierarchy claims this point,
    // it is a SwiftUI button or other interactive element — defer to it.
    if let sibling = sibling,
       sibling !== window,
       !sibling.isDescendant(of: self),
       !self.isDescendant(of: sibling) {
      return nil
    }

    return super.hitTest(point, with: event)
  }

  // Enforce a capped content size so the drawing surface extends below
  // the visible area up to the maximum allowed height.
  // Runs at the UIKit level after every layout pass — no SwiftUI state
  // involved, no PencilKit delegate conflicts.
  // Also strips UIEditMenuInteraction each pass — PKCanvasView re-adds it
  // internally, so a one-time removal is not sufficient.
  override func layoutSubviews() {
    super.layoutSubviews()

    // Remove the system edit menu interaction that PKCanvasView inherits
    // from UIScrollView. Without this, finger taps on the canvas surface
    // trigger a "Select All | Insert Space" context menu because the canvas
    // is first responder. The edit menu is never useful on a pencil-only canvas.
    if interactions.contains(where: { $0 is UIEditMenuInteraction }) {
      interactions.removeAll { $0 is UIEditMenuInteraction }
    }

    guard bounds.width > 0, bounds.height > 0 else { return }

    // Determine how far down strokes extend.
    let drawingBottom = drawing.strokes.isEmpty ? 0.0 : drawing.bounds.maxY

    // Extend content to one screen below the lowest stroke,
    // at least 3 screens tall, but never beyond the hard cap.
    let uncapped = max(bounds.height * 3, drawingBottom + bounds.height)
    let targetHeight = min(uncapped, Self.maxCanvasHeight)
    if contentSize.height < targetHeight {
      contentSize.height = targetHeight
    }
    // Clamp if already over the cap (e.g. after clearing strokes).
    if contentSize.height > Self.maxCanvasHeight {
      contentSize.height = Self.maxCanvasHeight
    }

    // Lock width to exactly the view width so horizontal scroll is impossible.
    // PKCanvasView may widen contentSize when strokes extend past the right edge;
    // clamping it each layout pass prevents any horizontal scrolling.
    contentSize.width = bounds.width
  }

  // Suppress the standard iOS edit menu ("Select All | Insert Space")
  // that appears on finger taps because the canvas is first responder.
  // Drawing input comes from Apple Pencil only; the edit menu is never useful.
  override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
    return false
  }
}

// MARK: - CanvasView

// UIViewRepresentable wrapper for PKCanvasView.
// Integrates PKToolPicker (the native Apple Notes-style floating toolbar)
// for tool selection, color, and width control.
struct CanvasView: UIViewRepresentable {
  @Binding var drawing: PKDrawing

  // Whether the native PKToolPicker is visible.
  @Binding var showToolPicker: Bool

  // Whether the ruler overlay is active.
  @Binding var isRulerActive: Bool

  // Whether finger-scroll is enabled. Disabled during crop mode
  // so the SwiftUI drag gesture can capture finger input instead.
  var isScrollEnabled: Bool = true

  // Whether the canvas accepts pencil input.
  var isInteractive: Bool = true

  // Callback when user starts drawing.
  var onDrawingBegan: (() -> Void)?

  // Callback when drawing changes (for auto-save).
  var onDrawingChanged: (() -> Void)?

  // Callback when canvas view is created (for toolbar integration).
  var onCanvasViewCreated: ((PKCanvasView) -> Void)?

  // Callback with current scroll offset (for end-of-canvas indicator).
  var onScrollOffsetChanged: ((CGFloat) -> Void)?

  // Callback with actual viewport size from UIKit bounds.
  // More accurate than SwiftUI GeometryReader for safe-area-ignoring views.
  var onViewportSizeChanged: ((CGSize) -> Void)?

  func makeUIView(context: Context) -> OverlayPassthroughCanvasView {
    let canvas = OverlayPassthroughCanvasView()
    canvas.drawing = drawing
    canvas.delegate = context.coordinator
    canvas.backgroundColor = .clear
    canvas.isOpaque = false
    canvas.drawingPolicy = .pencilOnly
    canvas.isScrollEnabled = false
    canvas.isUserInteractionEnabled = isInteractive

    // Create and attach the native PKToolPicker.
    let toolPicker = PKToolPicker()
    toolPicker.addObserver(canvas)
    toolPicker.addObserver(context.coordinator)
    toolPicker.isRulerActive = isRulerActive
    toolPicker.setVisible(showToolPicker, forFirstResponder: canvas)
    context.coordinator.toolPicker = toolPicker
    context.coordinator.previousShowToolPicker = showToolPicker

    // Make canvas first responder so it receives pencil input
    // and the tool picker can appear.
    // Also report initial viewport size after the first layout pass.
    DispatchQueue.main.async {
      canvas.becomeFirstResponder()
      self.onViewportSizeChanged?(canvas.bounds.size)
    }

    onCanvasViewCreated?(canvas)
    return canvas
  }

  func updateUIView(_ uiView: OverlayPassthroughCanvasView, context: Context) {
    // Keep coordinator's parent in sync so callbacks use current closures.
    context.coordinator.parent = self

    // Sync drawing if changed externally (e.g. loading a different note).
    // Reset scroll to the top so new canvases don't inherit the previous
    // note's scroll position.
    if uiView.drawing != drawing {
      uiView.drawing = drawing
      uiView.setContentOffset(.zero, animated: false)
    }
    uiView.isUserInteractionEnabled = isInteractive
    uiView.isScrollEnabled = isScrollEnabled

    // Show or hide the tool picker based on current state.
    if let toolPicker = context.coordinator.toolPicker {
      toolPicker.setVisible(showToolPicker, forFirstResponder: uiView)

      // Only reclaim first responder when the tool picker is toggled back on,
      // not on every SwiftUI update cycle. Calling becomeFirstResponder
      // unconditionally steals focus from text fields (e.g. sidebar search).
      let wasVisible = context.coordinator.previousShowToolPicker
      context.coordinator.previousShowToolPicker = showToolPicker
      if showToolPicker, !wasVisible {
        uiView.becomeFirstResponder()
      }

      // Sync ruler state in both directions.
      if toolPicker.isRulerActive != isRulerActive {
        toolPicker.isRulerActive = isRulerActive
      }
    }
  }

  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }

  class Coordinator: NSObject, PKCanvasViewDelegate, PKToolPickerObserver {
    var parent: CanvasView

    // Reference to the PKToolPicker so it stays alive.
    var toolPicker: PKToolPicker?

    private var wasDrawing = false

    // Tracks the last showToolPicker value so becomeFirstResponder is only
    // called on a false→true transition, not on every SwiftUI update cycle.
    var previousShowToolPicker = false

    init(_ parent: CanvasView) {
      self.parent = parent
    }

    // Report scroll position and viewport size on every scroll frame.
    // bounds.size is the true visible area of the UIScrollView, which
    // is more reliable than SwiftUI GeometryReader for safe-area math.
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
      parent.onScrollOffsetChanged?(scrollView.contentOffset.y)
      parent.onViewportSizeChanged?(scrollView.bounds.size)
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

    // Sync tool picker visibility back to the binding when the picker
    // shows or hides itself (e.g. first responder changes, user dismissal).
    // Without this, the SwiftUI toggle falls out of sync and the first
    // button press appears to do nothing.
    func toolPickerVisibilityDidChange(_ toolPicker: PKToolPicker) {
      let isNowVisible = toolPicker.isVisible
      if parent.showToolPicker != isNowVisible {
        parent.showToolPicker = isNowVisible
        previousShowToolPicker = isNowVisible
      }
    }

    // Sync ruler state back to the binding when user toggles it in the picker UI.
    func toolPickerIsRulerActiveDidChange(_ toolPicker: PKToolPicker) {
      parent.isRulerActive = toolPicker.isRulerActive
    }
  }
}

//
// PencilKitToolbarView.swift
// InkOS
//
// PencilKit toolbar with liquid glass styling.
// Auto-hides when user begins drawing, shows on pencil button tap.
// Positioned above the liquid glass pill input bar.
//

import PencilKit
import SwiftUI

// MARK: - PencilKitToolbarView

// A toolbar wrapper for PKToolPicker that provides auto-hide behavior.
// Uses UIViewRepresentable to integrate PKToolPicker with SwiftUI.
struct PencilKitToolbarView: UIViewRepresentable {
  // The PKCanvasView to connect the toolbar to.
  let canvasView: PKCanvasView

  // Whether the toolbar should be visible.
  @Binding var isVisible: Bool

  func makeUIView(context: Context) -> UIView {
    let container = UIView()
    container.backgroundColor = .clear

    // Set up tool picker.
    let toolPicker = PKToolPicker()
    toolPicker.addObserver(canvasView)
    toolPicker.setVisible(isVisible, forFirstResponder: canvasView)
    context.coordinator.toolPicker = toolPicker

    // Make canvas first responder to show toolbar.
    if isVisible {
      canvasView.becomeFirstResponder()
    }

    return container
  }

  func updateUIView(_ uiView: UIView, context: Context) {
    guard let toolPicker = context.coordinator.toolPicker else { return }

    // Update visibility.
    toolPicker.setVisible(isVisible, forFirstResponder: canvasView)

    if isVisible {
      canvasView.becomeFirstResponder()
    }
  }

  func makeCoordinator() -> Coordinator {
    Coordinator()
  }

  class Coordinator {
    var toolPicker: PKToolPicker?
  }
}

// MARK: - CanvasToolbarState

// Observable state for managing toolbar visibility.
@MainActor @Observable
final class CanvasToolbarState {
  // Whether the PencilKit toolbar is currently visible.
  var isToolbarVisible = false

  // Shows the toolbar with animation.
  func showToolbar() {
    withAnimation(.easeOut(duration: 0.3)) {
      isToolbarVisible = true
    }
  }

  // Hides the toolbar with animation.
  func hideToolbar() {
    withAnimation(.easeOut(duration: 0.3)) {
      isToolbarVisible = false
    }
  }

  // Toggles toolbar visibility.
  func toggleToolbar() {
    if isToolbarVisible {
      hideToolbar()
    } else {
      showToolbar()
    }
  }
}

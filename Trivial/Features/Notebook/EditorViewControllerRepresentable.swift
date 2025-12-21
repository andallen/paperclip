import SwiftUI
import UIKit

// SwiftUI wrapper for the UIKit EditorViewController.
// Provides a thin bridge between SwiftUI state and the UIKit controller.
struct EditorViewControllerRepresentable: UIViewControllerRepresentable {
  // The worker that manages the editor state.
  @ObservedObject var editorWorker: EditorWorker

  // Trigger for the clear action from SwiftUI.
  @Binding var clearTrigger: Bool

  func makeUIViewController(context: Context) -> EditorViewController {
    let controller = EditorViewController(editorWorker: editorWorker)
    return controller
  }

  func updateUIViewController(_ uiViewController: EditorViewController, context: Context) {
    // Handle clear trigger from SwiftUI.
    if clearTrigger {
      editorWorker.clear()
      // Reset the trigger asynchronously to avoid state modification during view update.
      DispatchQueue.main.async {
        clearTrigger = false
      }
    }
  }
}

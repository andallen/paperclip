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

      VStack(spacing: 0) {
        // Display the notebook name at the top.
        Text(model.displayName)
          .font(.system(size: 32, weight: .semibold))
          .foregroundStyle(Color.ink)
          .padding(.top, 24)
          .padding(.bottom, 16)

        // Empty canvas area where ink will be drawn later.
        CanvasArea()
      }
    }
    .fontDesign(.rounded)
    .navigationBarTitleDisplayMode(.inline)
  }
}

// Empty canvas area placeholder for future ink drawing.
private struct CanvasArea: View {
  var body: some View {
    GeometryReader { geometry in
      Rectangle()
        .fill(Color.white)
        .frame(width: geometry.size.width, height: geometry.size.height)
        .overlay(
          VStack {
            Spacer()
            Text("Canvas")
              .font(.system(.body))
              .foregroundStyle(Color.inkFaint)
            Spacer()
          }
        )
    }
  }
}


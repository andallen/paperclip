import SwiftUI

// The Notebook Editor displays a single Notebook and lets the user write ink.
// It is responsible for the editing experience (drawing, scrolling, zooming, and showing ink on screen).
struct NotebookView: View {
  let notebookName: String

  var body: some View {
    ZStack {
      BackgroundWhite()
        .ignoresSafeArea()

      VStack {
        Text(notebookName)
          .font(.system(size: 48, weight: .semibold))
          .foregroundStyle(Color.ink)
      }
    }
    .fontDesign(.rounded)
    .navigationBarTitleDisplayMode(.inline)
  }
}


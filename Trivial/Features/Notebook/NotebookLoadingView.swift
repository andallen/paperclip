import SwiftUI

// Handles the async loading of a Notebook before showing the editor.
// Calls openNotebook, constructs the NotebookModel, and displays the NotebookView.
struct NotebookLoadingView: View {
  // The ID of the Notebook to open.
  let notebookID: String

  // The library used to open the Notebook.
  let library: NotebookLibrary

  // Loading state to track whether the Notebook is being loaded.
  @State private var loadingState: LoadingState = .loading

  // Possible states during notebook loading.
  private enum LoadingState {
    case loading
    case loaded(model: NotebookModel, handle: DocumentHandle)
    case failed(error: String)
  }

  var body: some View {
    ZStack {
      BackgroundWhite()
        .ignoresSafeArea()

      switch loadingState {
      case .loading:
        LoadingContent()

      case let .loaded(model, handle):
        NotebookView(model: model, documentHandle: handle)

      case let .failed(error):
        ErrorContent(message: error)
      }
    }
    .fontDesign(.rounded)
    .navigationBarTitleDisplayMode(.inline)
    .task {
      await loadNotebook()
    }
  }

  // Loads the Notebook using the library and updates the state.
  private func loadNotebook() async {
    do {
      // Open the Notebook to get the DocumentHandle.
      let handle = try await library.openNotebook(notebookID: notebookID)

      // Get the initial Manifest from the handle.
      let manifest = handle.initialManifest

      // Build the NotebookModel from the Manifest.
      let model = NotebookModel(from: manifest)

      // Update state to show the editor.
      loadingState = .loaded(model: model, handle: handle)
    } catch {
      // Update state to show the error.
      loadingState = .failed(error: error.localizedDescription)
    }
  }
}

// Shows a loading indicator while the Notebook is being opened.
private struct LoadingContent: View {
  var body: some View {
    VStack(spacing: 16) {
      ProgressView()
        .scaleEffect(1.5)

      Text("Opening notebook…")
        .font(.system(.body))
        .foregroundStyle(Color.inkSubtle)
    }
  }
}

// Shows an error message if the Notebook failed to open.
private struct ErrorContent: View {
  let message: String

  var body: some View {
    VStack(spacing: 16) {
      Image(systemName: "exclamationmark.triangle")
        .font(.system(size: 48))
        .foregroundStyle(Color.inkSubtle)

      Text("Failed to open notebook")
        .font(.system(.title3, weight: .semibold))
        .foregroundStyle(Color.ink)

      Text(message)
        .font(.system(.body))
        .foregroundStyle(Color.inkSubtle)
        .multilineTextAlignment(.center)
        .padding(.horizontal, 32)
    }
  }
}

import SwiftUI

struct NotebookView: View {
    let model: NotebookModel
    let documentHandle: DocumentHandle
    @StateObject private var editorWorker = EditorWorker()

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Text(model.displayName).font(.headline)
                Spacer()
                Button("Clear") { editorWorker.clear() }
            }.padding()

            EditorViewControllerRepresentable(editorWorker: editorWorker)
        }
        .onAppear {
            Task { await editorWorker.loadPart(from: documentHandle) }
        }
        .onDisappear { editorWorker.close() }
    }
}
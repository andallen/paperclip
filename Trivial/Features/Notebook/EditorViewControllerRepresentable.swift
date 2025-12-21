import SwiftUI

struct EditorViewControllerRepresentable: UIViewControllerRepresentable {
    @ObservedObject var editorWorker: EditorWorker

    func makeUIViewController(context: Context) -> EditorViewController {
        return EditorViewController(editorWorker: editorWorker)
    }

    func updateUIViewController(_ uiViewController: EditorViewController, context: Context) {}
}
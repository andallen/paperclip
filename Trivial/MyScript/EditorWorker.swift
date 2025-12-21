import Foundation
import Combine

@MainActor
class EditorWorker: ObservableObject {
    @Published private(set) var editor: IINKEditor?
    private var documentHandle: DocumentHandle?

    func attach(engine: IINKEngine, renderer: IINKRenderer) {
        // Create the editor synchronously.
        // Defer the @Published update to avoid publishing during view updates.
        let newEditor = engine.createEditor(renderer: renderer, toolController: nil)
        newEditor?.set(fontMetricsProvider: FontMetricsProvider())
        
        // Update @Published asynchronously to avoid publishing during view updates.
        DispatchQueue.main.async { [weak self] in
            self?.editor = newEditor
        }
    }

    func loadPart(from handle: DocumentHandle) async {
        self.documentHandle = handle
        guard let part = await handle.getPart(at: 0) else { return }
        // Set the part. Since EditorWorker is @MainActor, this is already on the main thread.
        // Use Task to defer the @Published update to avoid publishing during view updates.
        Task { @MainActor in
            self.editor?.part = part
        }
    }

    func clear() {
        try? self.editor?.clear()
    }

    func close() {
        // Defer the @Published update to avoid publishing during view updates.
        // This is called from onDisappear which might be during a view update.
        Task { @MainActor in
            self.editor?.part = nil
            self.editor = nil
        }
    }
}
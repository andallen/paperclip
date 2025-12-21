import Foundation
import Combine

@MainActor
class EditorWorker: NSObject, ObservableObject {
    @Published private(set) var editor: IINKEditor?
    private var documentHandle: DocumentHandle?

    func attach(engine: IINKEngine, renderer: IINKRenderer) {
        // Create the editor synchronously.
        // Defer the @Published update to avoid publishing during view updates.
        let newEditor = engine.createEditor(renderer: renderer, toolController: nil)
        newEditor?.set(fontMetricsProvider: FontMetricsProvider())
        
        // Assign the delegate to this instance of EditorWorker.
        // This allows the engine to notify of background errors.
        newEditor?.delegate = self
        
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

// Extension to conform to IINKEditorDelegate for error handling.
// This captures errors that happen on background threads, such as ink being rejected
// due to coordinate or configuration issues.
extension EditorWorker: IINKEditorDelegate {
    func onError(_ editor: IINKEditor, blockId: String, message: String) {
        // This captures errors that happen on background threads.
        // Critical for finding errors like INK_REJECTED_TOO_SMALL.
        print("❌ MyScript Editor Error [BlockId: \(blockId)]: \(message)")
    }
    
    func partChanged(_ editor: IINKEditor) {
        // Called when the part changes.
        // This is a required protocol method.
    }
    
    func contentChanged(_ editor: IINKEditor, blockIds: [String]) {
        // Called when content in the specified blocks changes.
        // This is a required protocol method.
    }
}
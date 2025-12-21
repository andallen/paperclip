import Combine
import Foundation

// Manages the MyScript IINKEditor and content loading.
// Annotated with @MainActor because IINKEditor is not thread-safe.
@MainActor
class EditorWorker: ObservableObject {
  // The MyScript editor instance.
  private(set) var editor: IINKEditor?

  // The currently loaded document handle.
  private var documentHandle: DocumentHandle?

  // Attaches the worker to the engine and renderer.
  // Must be called before loading any content.
  func attach(engine: IINKEngine, renderer: IINKRenderer) {
    // Create the editor using the engine. No tool controller needed for basic input.
    self.editor = engine.createEditor(renderer: renderer, toolController: nil)
    
    // Set the font metrics provider. Required before setting a part.
    self.editor?.set(fontMetricsProvider: FontMetricsProvider())
  }

  // Loads the content part from the document handle.
  func loadPart(from handle: DocumentHandle) async {
    self.documentHandle = handle

    // Get the package from the handle.
    guard await handle.getPackage() != nil else {
      return
    }

    // Get the first part. Single-part notebook for now.
    guard let part = await handle.getPart(at: 0) else {
      return
    }

    // Assign the part to the editor.
    self.editor?.part = part
  }

  // Clears the current part content.
  func clear() {
    do {
      try self.editor?.clear()
    } catch {
      // Clear failed, ignore.
    }
  }

  // Unloads the current part and detaches the editor.
  func close() {
    self.editor?.part = nil
    self.documentHandle = nil
    self.editor = nil
  }
}

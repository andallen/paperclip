import SwiftUI
import UniformTypeIdentifiers

// Handles drag-and-drop of notebooks onto folders.
// When a notebook is dropped on a folder, triggers the move operation.
struct FolderDropDelegate: DropDelegate {
  let folderID: String
  let onNotebookDropped: (String) -> Void
  // Tracks whether a dragged item is currently hovering over this folder.
  @Binding var isTargeted: Bool

  // Called when a drag enters the folder drop area.
  func dropEntered(info: DropInfo) {
    withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
      isTargeted = true
    }
  }

  // Called when a drag exits the folder drop area.
  func dropExited(info: DropInfo) {
    withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
      isTargeted = false
    }
  }

  // Validates whether the drop is allowed.
  func validateDrop(info: DropInfo) -> Bool {
    return info.hasItemsConforming(to: [.notebookID])
  }

  // Called when a drop occurs on the folder.
  func performDrop(info: DropInfo) -> Bool {
    isTargeted = false

    // Extracts the notebook ID from the drop data.
    guard let itemProvider = info.itemProviders(for: [.notebookID]).first else {
      return false
    }

    itemProvider.loadItem(forTypeIdentifier: UTType.notebookID.identifier, options: nil) { data, error in
      guard error == nil,
        let data = data as? Data,
        let notebookID = String(data: data, encoding: .utf8)
      else {
        return
      }

      // Triggers the move operation on the main thread.
      DispatchQueue.main.async {
        onNotebookDropped(notebookID)
      }
    }

    return true
  }
}

// Custom UTType for notebook drag-and-drop operations.
extension UTType {
  static let notebookID = UTType(exportedAs: "me.andy.allen.inkos.notebookID")
}

// Makes NotebookMetadata draggable by providing its ID as the transfer data.
extension NotebookMetadata: Transferable {
  static var transferRepresentation: some TransferRepresentation {
    DataRepresentation(exportedContentType: .notebookID) { notebook in
      Data(notebook.id.utf8)
    }
  }
}

// Wrapper struct for dragging notebook IDs.
// Used when we only have the ID without the full metadata.
struct NotebookIDTransfer: Transferable {
  let id: String

  static var transferRepresentation: some TransferRepresentation {
    DataRepresentation(exportedContentType: .notebookID) { transfer in
      Data(transfer.id.utf8)
    }
  }
}

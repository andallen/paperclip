import Foundation

// The Notebook Model is the in-memory representation of what is inside the Notebook.
// It is built by reading the Manifest when the Notebook is opened.
// It contains a list of ink "chunks" that exist and the basic information needed to render them.
struct NotebookModel {
  // Unique identifier for this Notebook.
  let notebookID: String

  // Display name shown to the user.
  var displayName: String

  // Version number of the Manifest format this Notebook uses.
  let version: Int

  // List of Ink Items in this Notebook.
  // Each Ink Item represents one chunk of ink content.
  // Empty initially, will be populated as ink is added.
  var inkItems: [InkItem]

  // Creates a new Notebook Model from a Manifest.
  // This is how the editor builds the in-memory representation when opening a Notebook.
  init(from manifest: Manifest) {
    self.notebookID = manifest.notebookID
    self.displayName = manifest.displayName
    self.version = manifest.version
    self.inkItems = manifest.inkItems
  }
}

import Foundation

// The Manifest is a JSON file inside the Bundle that describes what ink exists in the Notebook.
// It contains the Notebook's metadata and a list of Ink Items.
struct Manifest: Codable {
  static let currentVersion = 1
  static let supportedVersions: Set<Int> = [1]

  // Unique identifier for this Notebook.
  let notebookID: String

  // Display name shown to the user.
  var displayName: String

  let version: Int

  // List of Ink Items in this Notebook.
  // Empty initially, will be populated as ink is added.
  var inkItems: [InkItem]

  // Creates a new Manifest with the given notebook ID and display name.
  // Sets version and initializes an empty ink items array.
  init(notebookID: String, displayName: String) {
    self.notebookID = notebookID
    self.displayName = displayName
    self.version = Self.currentVersion
    self.inkItems = []
  }
}

// An Ink Item represents one chunk of ink content in the Notebook.
// For now this is a minimal structure that will be extended later.
struct InkItem: Codable {
  // Unique identifier for this Ink Item.
  let id: String
}

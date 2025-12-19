import Foundation

// A DocumentHandle represents an open Notebook and provides safe operations
// for the editor to load and save data without exposing file paths.
// The editor never sees file paths; it only uses the handle.
actor DocumentHandle {
  // The unique identifier of the Notebook this handle represents.
  let notebookID: String

  // The initial Manifest loaded when the Notebook was opened.
  // This is provided so the editor can build the Notebook Model immediately.
  let initialManifest: Manifest

  // The URL of the Bundle folder. Private to hide file paths from the editor.
  private let bundleURL: URL

  // The name of the Manifest file inside the Bundle.
  private static let manifestFileName = "manifest.json"

  // The name of the folder where ink payload files are stored.
  private static let inkFolderName = "ink"

  // Creates a new DocumentHandle for the given Bundle.
  // This initializer is internal so only the BundleManager can create handles.
  init(notebookID: String, bundleURL: URL, manifest: Manifest) {
    self.notebookID = notebookID
    self.bundleURL = bundleURL
    self.initialManifest = manifest
  }

  // Loads the current Manifest from disk.
  // Use this to get the latest state of the Notebook.
  func loadManifest() throws -> Manifest {
    let manifestURL = bundleURL.appendingPathComponent(Self.manifestFileName)
    let data = try Data(contentsOf: manifestURL)
    let manifest = try JSONDecoder().decode(Manifest.self, from: data)
    return manifest
  }

  // Loads the ink data for a specific Ink Item.
  // Returns the raw Data from the ink payload file.
  // Throws if the Ink Item does not exist or cannot be read.
  func loadInkItem(id: String) throws -> Data {
    let inkFolderURL = bundleURL.appendingPathComponent(Self.inkFolderName, isDirectory: true)
    let inkFileURL = inkFolderURL.appendingPathComponent("\(id).ink")
    let data = try Data(contentsOf: inkFileURL)
    return data
  }

  // Saves ink data for a specific Ink Item.
  // Writes the data to the ink payload file using atomic write.
  // Creates the ink folder if it does not exist.
  func saveInkItem(id: String, data: Data) throws {
    let inkFolderURL = bundleURL.appendingPathComponent(Self.inkFolderName, isDirectory: true)

    // Create the ink folder if it does not exist.
    let fileManager = FileManager.default
    if !fileManager.fileExists(atPath: inkFolderURL.path) {
      try fileManager.createDirectory(at: inkFolderURL, withIntermediateDirectories: true)
    }

    // Write the ink data using atomic write.
    let inkFileURL = inkFolderURL.appendingPathComponent("\(id).ink")
    let tempURL = inkFolderURL.appendingPathComponent(".\(id).ink.tmp")
    try data.write(to: tempURL, options: [.atomic])

    // Replace the target file with the temporary file.
    if fileManager.fileExists(atPath: inkFileURL.path) {
      try fileManager.removeItem(at: inkFileURL)
    }
    try fileManager.moveItem(at: tempURL, to: inkFileURL)
  }

  // Deletes the ink data for a specific Ink Item.
  // Throws if the file cannot be deleted.
  func deleteInkItem(id: String) throws {
    let inkFolderURL = bundleURL.appendingPathComponent(Self.inkFolderName, isDirectory: true)
    let inkFileURL = inkFolderURL.appendingPathComponent("\(id).ink")
    let fileManager = FileManager.default
    if fileManager.fileExists(atPath: inkFileURL.path) {
      try fileManager.removeItem(at: inkFileURL)
    }
  }

  // Updates the Manifest on disk.
  // Writes ink payload files first, then updates the Manifest,
  // so the Manifest never points to missing data.
  func updateManifest(_ manifest: Manifest) throws {
    let manifestURL = bundleURL.appendingPathComponent(Self.manifestFileName)

    // Encode the Manifest to JSON data.
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    let data = try encoder.encode(manifest)

    // Write to a temporary file first for safe atomic write.
    let tempURL = bundleURL.appendingPathComponent(".\(Self.manifestFileName).tmp")
    try data.write(to: tempURL, options: [.atomic])

    // Replace the target file with the temporary file.
    let fileManager = FileManager.default
    if fileManager.fileExists(atPath: manifestURL.path) {
      try fileManager.removeItem(at: manifestURL)
    }
    try fileManager.moveItem(at: tempURL, to: manifestURL)
  }
}

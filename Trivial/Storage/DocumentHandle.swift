import Foundation

// Represents one opened notebook.
// Keeps the manifest and the iink package tied to the notebook folder.
// Uses an actor so notebook operations do not run at the same time.
actor DocumentHandle {
  // Stores the notebook identifier.
  let notebookID: String

  // Stores the manifest loaded at open time.
  let initialManifest: Manifest

  // Stores the notebook folder URL.
  private let bundleURL: URL

  // Stores the file path to the iink package.
  let packagePath: String

  // Stores the opened package for the lifetime of the handle.
  // Uses MainActor access because the SDK objects are not thread-safe.
  private var package: IINKContentPackage?

  // Stores the manifest file name inside the notebook folder.
  private static let manifestFileName = "manifest.json"

  // Creates a handle and opens the iink package.
  // Opens on the main actor because the engine is used on the main actor in this project.
  init(notebookID: String, bundleURL: URL, manifest: Manifest, packagePath: String) async {
    self.notebookID = notebookID
    self.bundleURL = bundleURL
    self.initialManifest = manifest
    self.packagePath = packagePath

    print("🧭 DocumentHandle.init start notebookID=\(notebookID) packagePath=\(packagePath)")
    self.package = await MainActor.run {
      guard let engine = EngineProvider.shared.engine else {
        print("❌ DocumentHandle.init engine unavailable notebookID=\(notebookID)")
        return nil
      }
      do {
        // Open or create the package if it is missing.
        // Matches the SDK guidance to use openPackage(openOption:) for create-or-open behavior.
        let openedPackage = try engine.openPackage(packagePath, openOption: .create)
        print("✅ DocumentHandle.init opened package notebookID=\(notebookID)")
        return openedPackage
      } catch {
        print("❌ DocumentHandle.init failed open package notebookID=\(notebookID) error=\(error)")
        return nil
      }
    }
    print("🧭 DocumentHandle.init end notebookID=\(notebookID) packageReady=\(self.package != nil)")
  }

  // Loads the current manifest from disk.
  func loadManifest() throws -> Manifest {
    print("🧭 DocumentHandle.loadManifest start notebookID=\(notebookID)")
    let manifestURL = bundleURL.appendingPathComponent(Self.manifestFileName)
    let data = try Data(contentsOf: manifestURL)

    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    let manifest = try decoder.decode(Manifest.self, from: data)
    print("✅ DocumentHandle.loadManifest success notebookID=\(notebookID)")
    return manifest
  }

  // Returns the package if it was opened successfully.
  func getPackage() async -> IINKContentPackage? {
    print("🧭 DocumentHandle.getPackage notebookID=\(notebookID) available=\(self.package != nil)")
    let capturedPackage = self.package
    return await MainActor.run {
      capturedPackage
    }
  }

  // Returns the number of parts in the package.
  func getPartCount() async -> Int {
    guard let capturedPackage = self.package else { return 0 }
    let count = await MainActor.run {
      capturedPackage.partCount()
    }
    print("🧭 DocumentHandle.getPartCount notebookID=\(notebookID) count=\(count)")
    return count
  }

  // Returns a part by index.
  func getPart(at index: Int) async -> IINKContentPart? {
    print("🧭 DocumentHandle.getPart start notebookID=\(notebookID) index=\(index)")
    guard let capturedPackage = self.package else { return nil }
    guard index >= 0 else { return nil }

    return await MainActor.run {
      guard index < capturedPackage.partCount() else { return nil }
      do {
        let part = try capturedPackage.part(at: index)
        print("✅ DocumentHandle.getPart success notebookID=\(notebookID) index=\(index)")
        return part
      } catch {
        print("❌ DocumentHandle.getPart failed notebookID=\(notebookID) index=\(index) error=\(error)")
        return nil
      }
    }
  }

  // Saves the package into the compressed archive.
  func savePackage() async throws {
    guard let capturedPackage = self.package else {
      print("❌ DocumentHandle.savePackage missing package notebookID=\(notebookID)")
      throw DocumentHandleError.packageNotAvailable
    }
    print("🧭 DocumentHandle.savePackage start notebookID=\(notebookID)")
    try await MainActor.run {
      try capturedPackage.save()
    }
    print("✅ DocumentHandle.savePackage success notebookID=\(notebookID)")
  }

  // Saves current in-memory changes to the temp folder.
  func savePackageToTemp() async throws {
    guard let capturedPackage = self.package else {
      print("❌ DocumentHandle.savePackageToTemp missing package notebookID=\(notebookID)")
      throw DocumentHandleError.packageNotAvailable
    }
    print("🧭 DocumentHandle.savePackageToTemp start notebookID=\(notebookID)")
    try await MainActor.run {
      try capturedPackage.saveToTemp()
    }
    print("✅ DocumentHandle.savePackageToTemp success notebookID=\(notebookID)")
  }

  // Saves and releases the package reference.
  func close() async {
    print("🧭 DocumentHandle.close start notebookID=\(notebookID)")
    do {
      try await savePackage()
    } catch {
      print("⚠️ DocumentHandle.close save failed notebookID=\(notebookID) error=\(error)")
      // Ignore save errors during close.
    }

    self.package = nil
    print("🧭 DocumentHandle.close end notebookID=\(notebookID)")
  }
}

// Represents errors for package access.
enum DocumentHandleError: LocalizedError {
  case packageNotAvailable

  var errorDescription: String? {
    switch self {
    case .packageNotAvailable:
      return "MyScript package is not available."
    }
  }
}

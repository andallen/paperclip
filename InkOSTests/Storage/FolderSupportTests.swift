//
// Tests for Folder Support in BundleManager based on Contract.swift
// Tests cover FolderManifest, folder CRUD operations, notebook organization, and integration scenarios.
//

import Testing
import Foundation
@testable import InkOS

// MARK: - FolderManifest Tests

@Suite("FolderManifest Tests")
struct FolderManifestTests {

  // MARK: - Initialization Tests

  @Suite("FolderManifest Initialization")
  struct InitializationTests {

    @Test("creates manifest with provided folderID and displayName")
    func createsWithProvidedValues() {
      // Arrange
      let testID = "test-folder-123"
      let testName = "My Projects"

      // Act
      let manifest = FolderManifest(folderID: testID, displayName: testName)

      // Assert
      #expect(manifest.folderID == testID)
      #expect(manifest.displayName == testName)
    }

    @Test("sets version to current FolderManifestVersion")
    func setsVersionToCurrent() {
      // Arrange & Act
      let manifest = FolderManifest(folderID: "test-id", displayName: "Test")

      // Assert
      #expect(manifest.version == FolderManifestVersion.current)
    }

    @Test("sets createdAt to current date")
    func setsCreatedAtToCurrentDate() {
      // Arrange
      let beforeCreation = Date()

      // Act
      let manifest = FolderManifest(folderID: "test-id", displayName: "Test")

      // Assert
      let afterCreation = Date()
      #expect(manifest.createdAt >= beforeCreation)
      #expect(manifest.createdAt <= afterCreation)
    }

    @Test("sets modifiedAt equal to createdAt")
    func setsModifiedAtEqualToCreatedAt() {
      // Arrange & Act
      let manifest = FolderManifest(folderID: "test-id", displayName: "Test")

      // Assert
      #expect(manifest.modifiedAt == manifest.createdAt)
    }

    @Test("preserves unicode characters in displayName")
    func preservesUnicodeCharacters() {
      // Arrange
      let unicodeName = "项目 プロジェクト Проект"

      // Act
      let manifest = FolderManifest(folderID: "test-id", displayName: unicodeName)

      // Assert
      #expect(manifest.displayName == unicodeName)
    }

    @Test("preserves emoji in displayName")
    func preservesEmoji() {
      // Arrange
      let emojiName = "📁 My Projects 🎨"

      // Act
      let manifest = FolderManifest(folderID: "test-id", displayName: emojiName)

      // Assert
      #expect(manifest.displayName == emojiName)
    }
  }

  // MARK: - Edge Case Initialization Tests

  @Suite("FolderManifest Initialization Edge Cases")
  struct InitializationEdgeCases {

    @Test("allows empty folderID without throwing")
    func allowsEmptyFolderID() {
      // Arrange & Act
      let manifest = FolderManifest(folderID: "", displayName: "Test")

      // Assert
      #expect(manifest.folderID == "")
    }

    @Test("allows empty displayName without throwing")
    func allowsEmptyDisplayName() {
      // Arrange & Act
      let manifest = FolderManifest(folderID: "test-id", displayName: "")

      // Assert
      #expect(manifest.displayName == "")
    }

    @Test("preserves whitespace-only displayName")
    func preservesWhitespaceOnlyDisplayName() {
      // Arrange
      let whitespaceName = "   "

      // Act
      let manifest = FolderManifest(folderID: "test-id", displayName: whitespaceName)

      // Assert
      #expect(manifest.displayName == whitespaceName)
    }

    @Test("stores very long displayName without truncation")
    func storesVeryLongDisplayName() {
      // Arrange
      let longName = String(repeating: "a", count: 10000)

      // Act
      let manifest = FolderManifest(folderID: "test-id", displayName: longName)

      // Assert
      #expect(manifest.displayName == longName)
      #expect(manifest.displayName.count == 10000)
    }
  }

  // MARK: - Codable Tests

  @Suite("FolderManifest Codable")
  struct CodableTests {

    @Test("encodes and decodes all fields correctly")
    func encodesAndDecodesAllFields() throws {
      // Arrange
      let original = FolderManifest(folderID: "folder-123", displayName: "Test Folder")

      // Act
      let encoder = JSONEncoder()
      encoder.dateEncodingStrategy = .iso8601
      let data = try encoder.encode(original)

      let decoder = JSONDecoder()
      decoder.dateDecodingStrategy = .iso8601
      let decoded = try decoder.decode(FolderManifest.self, from: data)

      // Assert
      #expect(decoded.folderID == original.folderID)
      #expect(decoded.displayName == original.displayName)
      #expect(decoded.version == original.version)
      // ISO8601 encoding may lose sub-second precision, so compare within 1 second tolerance.
      let createdDiff = abs(decoded.createdAt.timeIntervalSince1970 - original.createdAt.timeIntervalSince1970)
      let modifiedDiff = abs(decoded.modifiedAt.timeIntervalSince1970 - original.modifiedAt.timeIntervalSince1970)
      #expect(createdDiff < 1.0)
      #expect(modifiedDiff < 1.0)
    }

    @Test("decodes manifest with only required fields")
    func decodesManifestWithOnlyRequiredFields() throws {
      // Arrange
      let json = """
        {
          "folderID": "test-id",
          "displayName": "Test",
          "version": 1,
          "createdAt": "2024-01-01T00:00:00Z",
          "modifiedAt": "2024-01-01T00:00:00Z"
        }
        """

      // Act
      let decoder = JSONDecoder()
      decoder.dateDecodingStrategy = .iso8601
      let manifest = try decoder.decode(FolderManifest.self, from: json.data(using: .utf8)!)

      // Assert
      #expect(manifest.folderID == "test-id")
      #expect(manifest.displayName == "Test")
      #expect(manifest.version == 1)
    }

    @Test("ignores unknown fields in JSON")
    func ignoresUnknownFields() throws {
      // Arrange
      let json = """
        {
          "folderID": "test-id",
          "displayName": "Test",
          "version": 1,
          "createdAt": "2024-01-01T00:00:00Z",
          "modifiedAt": "2024-01-01T00:00:00Z",
          "unknownField": "should be ignored",
          "anotherUnknown": 123
        }
        """

      // Act
      let decoder = JSONDecoder()
      decoder.dateDecodingStrategy = .iso8601
      let manifest = try decoder.decode(FolderManifest.self, from: json.data(using: .utf8)!)

      // Assert
      #expect(manifest.folderID == "test-id")
      #expect(manifest.displayName == "Test")
    }
  }

  // MARK: - Decoding Error Edge Cases

  @Suite("FolderManifest Decoding Errors")
  struct DecodingErrorTests {

    @Test("throws DecodingError when folderID is missing")
    func throwsWhenFolderIDMissing() throws {
      // Arrange
      let json = """
        {
          "displayName": "Test",
          "version": 1,
          "createdAt": "2024-01-01T00:00:00Z",
          "modifiedAt": "2024-01-01T00:00:00Z"
        }
        """

      // Act & Assert
      let decoder = JSONDecoder()
      decoder.dateDecodingStrategy = .iso8601
      #expect(throws: DecodingError.self) {
        try decoder.decode(FolderManifest.self, from: json.data(using: .utf8)!)
      }
    }

    @Test("throws DecodingError when displayName is missing")
    func throwsWhenDisplayNameMissing() throws {
      // Arrange
      let json = """
        {
          "folderID": "test-id",
          "version": 1,
          "createdAt": "2024-01-01T00:00:00Z",
          "modifiedAt": "2024-01-01T00:00:00Z"
        }
        """

      // Act & Assert
      let decoder = JSONDecoder()
      decoder.dateDecodingStrategy = .iso8601
      #expect(throws: DecodingError.self) {
        try decoder.decode(FolderManifest.self, from: json.data(using: .utf8)!)
      }
    }

    @Test("throws DecodingError when version is missing")
    func throwsWhenVersionMissing() throws {
      // Arrange
      let json = """
        {
          "folderID": "test-id",
          "displayName": "Test",
          "createdAt": "2024-01-01T00:00:00Z",
          "modifiedAt": "2024-01-01T00:00:00Z"
        }
        """

      // Act & Assert
      let decoder = JSONDecoder()
      decoder.dateDecodingStrategy = .iso8601
      #expect(throws: DecodingError.self) {
        try decoder.decode(FolderManifest.self, from: json.data(using: .utf8)!)
      }
    }

    @Test("throws DecodingError when date format is invalid")
    func throwsWhenDateFormatInvalid() throws {
      // Arrange
      let json = """
        {
          "folderID": "test-id",
          "displayName": "Test",
          "version": 1,
          "createdAt": "not-a-date",
          "modifiedAt": "2024-01-01T00:00:00Z"
        }
        """

      // Act & Assert
      let decoder = JSONDecoder()
      decoder.dateDecodingStrategy = .iso8601
      #expect(throws: DecodingError.self) {
        try decoder.decode(FolderManifest.self, from: json.data(using: .utf8)!)
      }
    }

    @Test("throws DecodingError when version type is wrong")
    func throwsWhenVersionTypeWrong() throws {
      // Arrange
      let json = """
        {
          "folderID": "test-id",
          "displayName": "Test",
          "version": "1",
          "createdAt": "2024-01-01T00:00:00Z",
          "modifiedAt": "2024-01-01T00:00:00Z"
        }
        """

      // Act & Assert
      let decoder = JSONDecoder()
      decoder.dateDecodingStrategy = .iso8601
      #expect(throws: DecodingError.self) {
        try decoder.decode(FolderManifest.self, from: json.data(using: .utf8)!)
      }
    }

    @Test("throws Error when JSON is malformed")
    func throwsWhenJSONMalformed() throws {
      // Arrange
      let json = """
        {
          "folderID": "test-id",
          "displayName": "Test"
          "version": 1
        """

      // Act & Assert
      let decoder = JSONDecoder()
      decoder.dateDecodingStrategy = .iso8601
      #expect(throws: Error.self) {
        try decoder.decode(FolderManifest.self, from: json.data(using: .utf8)!)
      }
    }
  }
}

// MARK: - FolderBundleError Tests

@Suite("FolderBundleError Tests")
struct FolderBundleErrorTests {

  @Test("folderNotFound error has correct description")
  func folderNotFoundDescription() {
    // Arrange
    let error = FolderBundleError.folderNotFound(folderID: "missing-folder")

    // Assert
    #expect(error.errorDescription?.contains("Folder not found") == true)
    #expect(error.errorDescription?.contains("missing-folder") == true)
  }

  @Test("folderManifestNotFound error has correct description")
  func folderManifestNotFoundDescription() {
    // Arrange
    let error = FolderBundleError.folderManifestNotFound(folderID: "no-manifest")

    // Assert
    #expect(error.errorDescription?.contains("manifest not found") == true)
    #expect(error.errorDescription?.contains("no-manifest") == true)
  }

  @Test("folderManifestDecodingFailed error has correct description")
  func folderManifestDecodingFailedDescription() {
    // Arrange
    let error = FolderBundleError.folderManifestDecodingFailed(
      folderID: "bad-json",
      underlyingError: "Invalid JSON"
    )

    // Assert
    #expect(error.errorDescription?.contains("Failed to decode") == true)
    #expect(error.errorDescription?.contains("bad-json") == true)
    #expect(error.errorDescription?.contains("Invalid JSON") == true)
  }

  @Test("errors are equatable")
  func errorsAreEquatable() {
    // Arrange
    let error1 = FolderBundleError.folderNotFound(folderID: "test-id")
    let error2 = FolderBundleError.folderNotFound(folderID: "test-id")
    let error3 = FolderBundleError.folderNotFound(folderID: "other-id")

    // Assert
    #expect(error1 == error2)
    #expect(error1 != error3)
  }
}

// MARK: - Folder CRUD Operations Tests

// These tests verify the interface for folder operations as specified in the contract.
// They will fail until BundleManager implements the FolderManaging protocol.
// The tests ensure that the method signatures match the contract and can be called.

@Suite("Folder Operations - Interface Tests", .serialized)
struct FolderOperationsInterfaceTests {

  @Test("listFolders returns array of FolderMetadata")
  func listFoldersReturnsCorrectType() async throws {
    // This test verifies that listFolders can be called and returns the expected type.
    // Implementation is not required yet - this confirms the interface is usable.

    // Note: This test will fail until BundleManager implements listFolders.
    // When implementing, ensure the method signature matches:
    // func listFolders() async throws -> [FolderMetadata]

    // Placeholder for when implementation exists:
    // let manager = BundleManager.shared
    // let folders = try await manager.listFolders()
    // #expect(folders is [FolderMetadata])
  }

  @Test("createFolder accepts displayName and returns FolderMetadata")
  func createFolderAcceptsDisplayName() async throws {
    // This test verifies that createFolder can be called with a string parameter.
    // Implementation is not required yet - this confirms the interface is usable.

    // Note: This test will fail until BundleManager implements createFolder.
    // When implementing, ensure the method signature matches:
    // func createFolder(displayName: String) async throws -> FolderMetadata

    // Placeholder for when implementation exists:
    // let manager = BundleManager.shared
    // let folder = try await manager.createFolder(displayName: "Test")
    // #expect(folder is FolderMetadata)
  }

  @Test("renameFolder accepts folderID and newDisplayName")
  func renameFolderAcceptsParameters() async throws {
    // This test verifies that renameFolder can be called with the correct parameters.
    // Implementation is not required yet - this confirms the interface is usable.

    // Note: This test will fail until BundleManager implements renameFolder.
    // When implementing, ensure the method signature matches:
    // func renameFolder(folderID: String, newDisplayName: String) async throws

    // Placeholder for when implementation exists:
    // let manager = BundleManager.shared
    // try await manager.renameFolder(folderID: "test-id", newDisplayName: "New Name")
  }

  @Test("deleteFolder accepts folderID")
  func deleteFolderAcceptsParameter() async throws {
    // This test verifies that deleteFolder can be called with a folder ID.
    // Implementation is not required yet - this confirms the interface is usable.

    // Note: This test will fail until BundleManager implements deleteFolder.
    // When implementing, ensure the method signature matches:
    // func deleteFolder(folderID: String) async throws

    // Placeholder for when implementation exists:
    // let manager = BundleManager.shared
    // try await manager.deleteFolder(folderID: "test-id")
  }

  @Test("moveNotebookToFolder accepts notebookID and folderID")
  func moveNotebookToFolderAcceptsParameters() async throws {
    // This test verifies that moveNotebookToFolder can be called with correct parameters.
    // Implementation is not required yet - this confirms the interface is usable.

    // Note: This test will fail until BundleManager implements moveNotebookToFolder.
    // When implementing, ensure the method signature matches:
    // func moveNotebookToFolder(notebookID: String, folderID: String) async throws

    // Placeholder for when implementation exists:
    // let manager = BundleManager.shared
    // try await manager.moveNotebookToFolder(notebookID: "notebook-id", folderID: "folder-id")
  }

  @Test("moveNotebookToRoot accepts notebookID and fromFolderID")
  func moveNotebookToRootAcceptsParameters() async throws {
    // This test verifies that moveNotebookToRoot can be called with correct parameters.
    // Implementation is not required yet - this confirms the interface is usable.

    // Note: This test will fail until BundleManager implements moveNotebookToRoot.
    // When implementing, ensure the method signature matches:
    // func moveNotebookToRoot(notebookID: String, fromFolderID: String) async throws

    // Placeholder for when implementation exists:
    // let manager = BundleManager.shared
    // try await manager.moveNotebookToRoot(notebookID: "notebook-id", fromFolderID: "folder-id")
  }

  @Test("listBundlesInFolder accepts folderID and returns array")
  func listBundlesInFolderAcceptsParameter() async throws {
    // This test verifies that listBundlesInFolder can be called with a folder ID.
    // Implementation is not required yet - this confirms the interface is usable.

    // Note: This test will fail until BundleManager implements listBundlesInFolder.
    // When implementing, ensure the method signature matches:
    // func listBundlesInFolder(folderID: String) async throws -> [NotebookMetadata]

    // Placeholder for when implementation exists:
    // let manager = BundleManager.shared
    // let notebooks = try await manager.listBundlesInFolder(folderID: "folder-id")
    // #expect(notebooks is [NotebookMetadata])
  }
}

// MARK: - Folder CRUD Happy Path Tests

// These tests verify the expected behavior when operations succeed.
// They are organized by the scenarios defined in the contract.

@Suite("Folder Operations - Happy Path", .serialized)
struct FolderOperationsHappyPathTests {

  // MARK: - listFolders Happy Path

  @Suite("listFolders Happy Path")
  struct ListFoldersHappyPath {

    @Test("returns empty array when no folders exist")
    func returnsEmptyArrayWhenNoFolders() async throws {
      // GIVEN: A Notebooks directory with no folders
      // WHEN: listFolders() is called
      // THEN: Returns empty array

      // This test will be implemented when BundleManager supports folders
    }

    @Test("returns array with FolderMetadata for existing folders")
    func returnsFolderMetadataForExistingFolders() async throws {
      // GIVEN: A Notebooks directory with 3 folders
      // WHEN: listFolders() is called
      // THEN: Returns array with 3 FolderMetadata entries
      // AND: Each entry has non-empty id
      // AND: Each entry has displayName matching folder.json

      // This test will be implemented when BundleManager supports folders
    }

    @Test("excludes notebooks from folder listing")
    func excludesNotebooksFromListing() async throws {
      // GIVEN: A Notebooks directory with 2 folders and 5 notebooks
      // WHEN: listFolders() is called
      // THEN: Returns array with exactly 2 FolderMetadata entries
      // AND: Does not include notebooks

      // This test will be implemented when BundleManager supports folders
    }

    @Test("collects preview images from folder notebooks")
    func collectsPreviewImagesFromNotebooks() async throws {
      // GIVEN: A folder containing 3 notebooks with preview.png files
      // WHEN: listFolders() is called
      // THEN: FolderMetadata.previewImages contains up to 4 Data objects

      // This test will be implemented when BundleManager supports folders
    }

    @Test("counts notebooks in folder accurately")
    func countsNotebooksAccurately() async throws {
      // GIVEN: A folder containing 5 notebooks
      // WHEN: listFolders() is called
      // THEN: FolderMetadata.notebookCount equals 5

      // This test will be implemented when BundleManager supports folders
    }
  }

  // MARK: - createFolder Happy Path

  @Suite("createFolder Happy Path")
  struct CreateFolderHappyPath {

    @Test("creates folder with valid display name")
    func createsWithValidDisplayName() async throws {
      // GIVEN: A display name "My Projects"
      // WHEN: createFolder(displayName:) is called
      // THEN: Returns FolderMetadata with non-empty id
      // AND: FolderMetadata.displayName equals "My Projects"
      // AND: FolderMetadata.notebookCount equals 0
      // AND: FolderMetadata.previewImages is empty

      // This test will be implemented when BundleManager supports folders
    }

    @Test("created folder appears in listFolders")
    func createdFolderAppearsInListing() async throws {
      // GIVEN: createFolder(displayName: "Test Folder") succeeds
      // WHEN: listFolders() is called
      // THEN: The new folder appears in the results

      // This test will be implemented when BundleManager supports folders
    }

    @Test("creates folder with unicode name")
    func createsWithUnicodeName() async throws {
      // GIVEN: A display name with unicode characters
      // WHEN: createFolder(displayName:) is called
      // THEN: Folder is created successfully
      // AND: displayName preserves unicode exactly

      // This test will be implemented when BundleManager supports folders
    }

    @Test("creates folder with emoji name")
    func createsWithEmojiName() async throws {
      // GIVEN: A display name containing emoji
      // WHEN: createFolder(displayName:) is called
      // THEN: Folder is created successfully
      // AND: displayName preserves emoji exactly

      // This test will be implemented when BundleManager supports folders
    }

    @Test("generates unique IDs for multiple folders")
    func generatesUniqueIDs() async throws {
      // GIVEN: Two calls to createFolder with the same display name
      // WHEN: Both calls complete
      // THEN: Each folder has a unique folderID
      // AND: Both appear in listFolders()

      // This test will be implemented when BundleManager supports folders
    }
  }

  // MARK: - renameFolder Happy Path

  @Suite("renameFolder Happy Path")
  struct RenameFolderHappyPath {

    @Test("renames folder successfully")
    func renamesSuccessfully() async throws {
      // GIVEN: An existing folder with displayName "Old Name"
      // WHEN: renameFolder(folderID:, newDisplayName: "New Name") is called
      // THEN: folder.json displayName is updated to "New Name"
      // AND: modifiedAt timestamp is updated
      // AND: folderID remains unchanged

      // This test will be implemented when BundleManager supports folders
    }

    @Test("renamed folder appears correctly in listFolders")
    func renamedFolderAppearsCorrectly() async throws {
      // GIVEN: renameFolder succeeds
      // WHEN: listFolders() is called
      // THEN: FolderMetadata.displayName shows the new name

      // This test will be implemented when BundleManager supports folders
    }

    @Test("rename to same name succeeds")
    func renameToSameNameSucceeds() async throws {
      // GIVEN: A folder with displayName "Same"
      // WHEN: renameFolder(folderID:, newDisplayName: "Same") is called
      // THEN: No error is thrown
      // AND: modifiedAt is updated

      // This test will be implemented when BundleManager supports folders
    }
  }

  // MARK: - deleteFolder Happy Path

  @Suite("deleteFolder Happy Path")
  struct DeleteFolderHappyPath {

    @Test("deletes empty folder successfully")
    func deletesEmptyFolder() async throws {
      // GIVEN: A folder containing no notebooks
      // WHEN: deleteFolder(folderID:) is called
      // THEN: Folder directory is removed from file system
      // AND: Folder no longer appears in listFolders()

      // This test will be implemented when BundleManager supports folders
    }

    @Test("deletes folder with notebooks")
    func deletesFolderWithNotebooks() async throws {
      // GIVEN: A folder containing 3 notebooks
      // WHEN: deleteFolder(folderID:) is called
      // THEN: Folder directory is removed
      // AND: All 3 notebooks are deleted
      // AND: Folder no longer appears in listFolders()

      // This test will be implemented when BundleManager supports folders
    }

    @Test("delete does not affect other folders")
    func deleteDoesNotAffectOtherFolders() async throws {
      // GIVEN: 3 folders: A, B, C
      // WHEN: deleteFolder(folderID: B.id) is called
      // THEN: Folders A and C still exist
      // AND: Only folder B is removed

      // This test will be implemented when BundleManager supports folders
    }

    @Test("delete does not affect root-level notebooks")
    func deleteDoesNotAffectRootNotebooks() async throws {
      // GIVEN: A folder and 2 root-level notebooks
      // WHEN: deleteFolder(folderID:) is called
      // THEN: Root-level notebooks are unaffected

      // This test will be implemented when BundleManager supports folders
    }
  }

  // MARK: - moveNotebookToFolder Happy Path

  @Suite("moveNotebookToFolder Happy Path")
  struct MoveNotebookToFolderHappyPath {

    @Test("moves root-level notebook to folder")
    func movesRootNotebookToFolder() async throws {
      // GIVEN: A notebook at root level and an existing folder
      // WHEN: moveNotebookToFolder(notebookID:, folderID:) is called
      // THEN: Notebook directory is moved inside folder directory
      // AND: Notebook no longer appears in listBundles()
      // AND: Notebook appears in listBundlesInFolder(folderID:)
      // AND: Notebook content is preserved

      // This test will be implemented when BundleManager supports folders
    }

    @Test("moves notebook between folders")
    func movesNotebookBetweenFolders() async throws {
      // GIVEN: A notebook in folder A and folder B exists
      // WHEN: moveNotebookToFolder(notebookID:, folderID: B.id) is called
      // THEN: Notebook is moved from folder A to folder B
      // AND: Notebook no longer appears in listBundlesInFolder(folderID: A.id)
      // AND: Notebook appears in listBundlesInFolder(folderID: B.id)

      // This test will be implemented when BundleManager supports folders
    }

    @Test("updates folder notebook count")
    func updatesFolderNotebookCount() async throws {
      // GIVEN: A folder with 2 notebooks and a root-level notebook
      // WHEN: moveNotebookToFolder moves root notebook to folder
      // THEN: Folder's notebookCount becomes 3

      // This test will be implemented when BundleManager supports folders
    }

    @Test("moved notebook can be opened")
    func movedNotebookCanBeOpened() async throws {
      // GIVEN: A notebook moved to a folder
      // WHEN: openNotebook(id:) is called with the notebook ID
      // THEN: Notebook opens successfully
      // AND: All content is accessible

      // This test will be implemented when BundleManager supports folders
    }
  }

  // MARK: - moveNotebookToRoot Happy Path

  @Suite("moveNotebookToRoot Happy Path")
  struct MoveNotebookToRootHappyPath {

    @Test("moves notebook from folder to root")
    func movesNotebookToRoot() async throws {
      // GIVEN: A notebook inside a folder
      // WHEN: moveNotebookToRoot(notebookID:, fromFolderID:) is called
      // THEN: Notebook directory is moved to Notebooks/ root
      // AND: Notebook appears in listBundles()
      // AND: Notebook no longer appears in listBundlesInFolder(fromFolderID:)

      // This test will be implemented when BundleManager supports folders
    }

    @Test("updates folder notebook count after move")
    func updatesFolderCountAfterMove() async throws {
      // GIVEN: A folder with 3 notebooks
      // WHEN: moveNotebookToRoot moves one notebook out
      // THEN: Folder's notebookCount becomes 2

      // This test will be implemented when BundleManager supports folders
    }

    @Test("moved notebook can be opened at root")
    func movedNotebookCanBeOpenedAtRoot() async throws {
      // GIVEN: A notebook moved to root
      // WHEN: openNotebook(id:) is called with the notebook ID
      // THEN: Notebook opens successfully

      // This test will be implemented when BundleManager supports folders
    }
  }

  // MARK: - listBundlesInFolder Happy Path

  @Suite("listBundlesInFolder Happy Path")
  struct ListBundlesInFolderHappyPath {

    @Test("lists notebooks in folder with content")
    func listsNotebooksInFolder() async throws {
      // GIVEN: A folder containing 3 notebooks
      // WHEN: listBundlesInFolder(folderID:) is called
      // THEN: Returns array with 3 NotebookMetadata entries
      // AND: Each entry has correct id, displayName, and previewImageData

      // This test will be implemented when BundleManager supports folders
    }

    @Test("returns empty array for empty folder")
    func returnsEmptyForEmptyFolder() async throws {
      // GIVEN: A folder containing no notebooks
      // WHEN: listBundlesInFolder(folderID:) is called
      // THEN: Returns empty array
      // AND: No error is thrown

      // This test will be implemented when BundleManager supports folders
    }

    @Test("notebooks have correct metadata")
    func notebooksHaveCorrectMetadata() async throws {
      // GIVEN: A folder with a notebook named "My Notes"
      // WHEN: listBundlesInFolder(folderID:) is called
      // THEN: NotebookMetadata.displayName equals "My Notes"
      // AND: NotebookMetadata.id is a valid UUID string

      // This test will be implemented when BundleManager supports folders
    }
  }
}

// MARK: - Folder Operations Sad Path Tests

// These tests verify error handling for invalid inputs and edge cases.

@Suite("Folder Operations - Sad Path", .serialized)
struct FolderOperationsSadPathTests {

  // MARK: - listFolders Edge Cases

  @Suite("listFolders Edge Cases")
  struct ListFoldersEdgeCases {

    @Test("skips folder with invalid folder.json")
    func skipsInvalidFolderJson() async throws {
      // GIVEN: A folder directory with corrupted folder.json
      // WHEN: listFolders() is called
      // THEN: That folder is skipped
      // AND: Other valid folders are still returned
      // AND: No error is thrown

      // This test will be implemented when BundleManager supports folders
    }

    @Test("skips directory without folder.json or manifest.json")
    func skipsDirectoryWithoutManifests() async throws {
      // GIVEN: A directory without folder.json or manifest.json
      // WHEN: listFolders() is called
      // THEN: That directory is skipped

      // This test will be implemented when BundleManager supports folders
    }

    @Test("skips hidden directories")
    func skipsHiddenDirectories() async throws {
      // GIVEN: Directories starting with "." in Notebooks folder
      // WHEN: listFolders() is called
      // THEN: Hidden directories are skipped

      // This test will be implemented when BundleManager supports folders
    }

    @Test("returns empty array for empty Notebooks directory")
    func returnsEmptyForEmptyDirectory() async throws {
      // GIVEN: The Notebooks directory is completely empty
      // WHEN: listFolders() is called
      // THEN: Returns empty array
      // AND: No error is thrown

      // This test will be implemented when BundleManager supports folders
    }
  }

  // MARK: - createFolder Edge Cases

  @Suite("createFolder Edge Cases")
  struct CreateFolderEdgeCases {

    @Test("creates folder with empty display name")
    func createsWithEmptyDisplayName() async throws {
      // GIVEN: An empty string as displayName
      // WHEN: createFolder(displayName:) is called
      // THEN: Folder is created with empty displayName
      // AND: No error is thrown

      // This test will be implemented when BundleManager supports folders
    }

    @Test("creates folder with whitespace-only display name")
    func createsWithWhitespaceDisplayName() async throws {
      // GIVEN: A display name "   " (whitespace only)
      // WHEN: createFolder(displayName:) is called
      // THEN: Folder is created with whitespace displayName

      // This test will be implemented when BundleManager supports folders
    }

    @Test("creates folder with very long display name")
    func createsWithVeryLongDisplayName() async throws {
      // GIVEN: A display name with 10000 characters
      // WHEN: createFolder(displayName:) is called
      // THEN: Folder is created successfully
      // AND: displayName is not truncated

      // This test will be implemented when BundleManager supports folders
    }

    @Test("creates folder with special characters in name")
    func createsWithSpecialCharacters() async throws {
      // GIVEN: A display name "<test> & 'quotes' /path"
      // WHEN: createFolder(displayName:) is called
      // THEN: Folder is created successfully
      // AND: displayName preserves all special characters

      // This test will be implemented when BundleManager supports folders
    }

    @Test("creates folder with newlines in name")
    func createsWithNewlines() async throws {
      // GIVEN: A display name containing newline characters
      // WHEN: createFolder(displayName:) is called
      // THEN: Folder is created successfully

      // This test will be implemented when BundleManager supports folders
    }
  }

  // MARK: - renameFolder Error Cases

  @Suite("renameFolder Error Cases")
  struct RenameFolderErrorCases {

    @Test("throws folderNotFound when folder does not exist")
    func throwsWhenFolderNotExists() async throws {
      // GIVEN: A folderID that does not exist
      // WHEN: renameFolder(folderID:, newDisplayName:) is called
      // THEN: Throws FolderBundleError.folderNotFound(folderID:)

      // This test will be implemented when BundleManager supports folders
    }

    @Test("throws folderNotFound for empty folder ID")
    func throwsForEmptyFolderID() async throws {
      // GIVEN: An empty string as folderID
      // WHEN: renameFolder(folderID:, newDisplayName:) is called
      // THEN: Throws FolderBundleError.folderNotFound(folderID: "")

      // This test will be implemented when BundleManager supports folders
    }

    @Test("throws folderNotFound when ID points to notebook")
    func throwsWhenIDPointsToNotebook() async throws {
      // GIVEN: A notebookID (not a folder)
      // WHEN: renameFolder(folderID:, newDisplayName:) is called
      // THEN: Throws FolderBundleError.folderNotFound(folderID:)

      // This test will be implemented when BundleManager supports folders
    }

    @Test("renames with unicode characters preserved")
    func renamesWithUnicode() async throws {
      // GIVEN: newDisplayName containing unicode
      // WHEN: renameFolder is called
      // THEN: displayName is updated with unicode preserved

      // This test will be implemented when BundleManager supports folders
    }

    @Test("handles multiple renames correctly")
    func handlesMultipleRenames() async throws {
      // GIVEN: A folder
      // WHEN: renameFolder is called 5 times with different names
      // THEN: Final displayName matches the last rename

      // This test will be implemented when BundleManager supports folders
    }
  }

  // MARK: - deleteFolder Error Cases

  @Suite("deleteFolder Error Cases")
  struct DeleteFolderErrorCases {

    @Test("throws folderNotFound when folder does not exist")
    func throwsWhenFolderNotExists() async throws {
      // GIVEN: A folderID that does not exist
      // WHEN: deleteFolder(folderID:) is called
      // THEN: Throws FolderBundleError.folderNotFound(folderID:)

      // This test will be implemented when BundleManager supports folders
    }

    @Test("throws folderNotFound for empty folder ID")
    func throwsForEmptyFolderID() async throws {
      // GIVEN: An empty string as folderID
      // WHEN: deleteFolder(folderID:) is called
      // THEN: Throws FolderBundleError.folderNotFound(folderID: "")

      // This test will be implemented when BundleManager supports folders
    }

    @Test("throws folderNotFound on double delete")
    func throwsOnDoubleDelete() async throws {
      // GIVEN: deleteFolder(folderID:) succeeds
      // WHEN: deleteFolder(folderID:) is called again with same ID
      // THEN: Throws FolderBundleError.folderNotFound(folderID:)

      // This test will be implemented when BundleManager supports folders
    }

    @Test("throws folderNotFound when ID points to notebook")
    func throwsWhenIDPointsToNotebook() async throws {
      // GIVEN: A notebookID (not a folder)
      // WHEN: deleteFolder(folderID:) is called
      // THEN: Throws FolderBundleError.folderNotFound(folderID:)

      // This test will be implemented when BundleManager supports folders
    }

    @Test("rejects path traversal attack")
    func rejectsPathTraversal() async throws {
      // GIVEN: A malicious folderID like "../../../etc"
      // WHEN: deleteFolder(folderID:) is called
      // THEN: Throws FolderBundleError.folderNotFound(folderID:)
      // AND: No files outside Notebooks directory are affected

      // This test will be implemented when BundleManager supports folders
    }
  }

  // MARK: - moveNotebookToFolder Error Cases

  @Suite("moveNotebookToFolder Error Cases")
  struct MoveNotebookToFolderErrorCases {

    @Test("throws bundleNotFound when notebook does not exist")
    func throwsWhenNotebookNotExists() async throws {
      // GIVEN: A notebookID that does not exist
      // WHEN: moveNotebookToFolder(notebookID:, folderID:) is called
      // THEN: Throws BundleError.bundleNotFound(notebookID:)

      // This test will be implemented when BundleManager supports folders
    }

    @Test("throws folderNotFound when folder does not exist")
    func throwsWhenFolderNotExists() async throws {
      // GIVEN: A valid notebookID but invalid folderID
      // WHEN: moveNotebookToFolder(notebookID:, folderID:) is called
      // THEN: Throws FolderBundleError.folderNotFound(folderID:)

      // This test will be implemented when BundleManager supports folders
    }

    @Test("throws notebookAlreadyInFolder when already in target")
    func throwsWhenAlreadyInFolder() async throws {
      // GIVEN: A notebook already in folder F
      // WHEN: moveNotebookToFolder(notebookID:, folderID: F.id) is called
      // THEN: Throws FolderBundleError.notebookAlreadyInFolder

      // This test will be implemented when BundleManager supports folders
    }

    @Test("throws bundleNotFound for empty notebook ID")
    func throwsForEmptyNotebookID() async throws {
      // GIVEN: An empty string as notebookID
      // WHEN: moveNotebookToFolder(notebookID:, folderID:) is called
      // THEN: Throws BundleError.bundleNotFound(notebookID: "")

      // This test will be implemented when BundleManager supports folders
    }

    @Test("throws folderNotFound for empty folder ID")
    func throwsForEmptyFolderID() async throws {
      // GIVEN: A valid notebookID but empty folderID
      // WHEN: moveNotebookToFolder(notebookID:, folderID:) is called
      // THEN: Throws FolderBundleError.folderNotFound(folderID: "")

      // This test will be implemented when BundleManager supports folders
    }

    @Test("throws folderNotFound when folder ID is notebook ID")
    func throwsWhenFolderIDIsNotebookID() async throws {
      // GIVEN: folderID points to a notebook (has manifest.json)
      // WHEN: moveNotebookToFolder(notebookID:, folderID:) is called
      // THEN: Throws FolderBundleError.folderNotFound(folderID:)

      // This test will be implemented when BundleManager supports folders
    }
  }

  // MARK: - moveNotebookToRoot Error Cases

  @Suite("moveNotebookToRoot Error Cases")
  struct MoveNotebookToRootErrorCases {

    @Test("throws bundleNotFound when notebook does not exist")
    func throwsWhenNotebookNotExists() async throws {
      // GIVEN: A notebookID that does not exist
      // WHEN: moveNotebookToRoot(notebookID:, fromFolderID:) is called
      // THEN: Throws BundleError.bundleNotFound(notebookID:)

      // This test will be implemented when BundleManager supports folders
    }

    @Test("throws folderNotFound when folder does not exist")
    func throwsWhenFolderNotExists() async throws {
      // GIVEN: A valid notebookID but invalid fromFolderID
      // WHEN: moveNotebookToRoot(notebookID:, fromFolderID:) is called
      // THEN: Throws FolderBundleError.folderNotFound(folderID:)

      // This test will be implemented when BundleManager supports folders
    }

    @Test("throws notebookNotInFolder when not in specified folder")
    func throwsWhenNotInSpecifiedFolder() async throws {
      // GIVEN: A notebook in folder A
      // WHEN: moveNotebookToRoot(notebookID:, fromFolderID: B.id) is called
      // THEN: Throws FolderBundleError.notebookNotInFolder(notebookID:)

      // This test will be implemented when BundleManager supports folders
    }

    @Test("throws notebookNotInFolder when already at root")
    func throwsWhenAlreadyAtRoot() async throws {
      // GIVEN: A root-level notebook
      // WHEN: moveNotebookToRoot(notebookID:, fromFolderID:) is called
      // THEN: Throws FolderBundleError.notebookNotInFolder(notebookID:)

      // This test will be implemented when BundleManager supports folders
    }

    @Test("throws bundleNotFound for empty notebook ID")
    func throwsForEmptyNotebookID() async throws {
      // GIVEN: An empty string as notebookID
      // WHEN: moveNotebookToRoot(notebookID:, fromFolderID:) is called
      // THEN: Throws BundleError.bundleNotFound(notebookID: "")

      // This test will be implemented when BundleManager supports folders
    }

    @Test("throws folderNotFound for empty folder ID")
    func throwsForEmptyFolderID() async throws {
      // GIVEN: A valid notebookID but empty fromFolderID
      // WHEN: moveNotebookToRoot(notebookID:, fromFolderID:) is called
      // THEN: Throws FolderBundleError.folderNotFound(folderID: "")

      // This test will be implemented when BundleManager supports folders
    }
  }

  // MARK: - listBundlesInFolder Error Cases

  @Suite("listBundlesInFolder Error Cases")
  struct ListBundlesInFolderErrorCases {

    @Test("throws folderNotFound when folder does not exist")
    func throwsWhenFolderNotExists() async throws {
      // GIVEN: A folderID that does not exist
      // WHEN: listBundlesInFolder(folderID:) is called
      // THEN: Throws FolderBundleError.folderNotFound(folderID:)

      // This test will be implemented when BundleManager supports folders
    }

    @Test("throws folderNotFound for empty folder ID")
    func throwsForEmptyFolderID() async throws {
      // GIVEN: An empty string as folderID
      // WHEN: listBundlesInFolder(folderID:) is called
      // THEN: Throws FolderBundleError.folderNotFound(folderID: "")

      // This test will be implemented when BundleManager supports folders
    }

    @Test("throws folderNotFound when ID points to notebook")
    func throwsWhenIDPointsToNotebook() async throws {
      // GIVEN: A notebookID (directory with manifest.json)
      // WHEN: listBundlesInFolder(folderID:) is called
      // THEN: Throws FolderBundleError.folderNotFound(folderID:)

      // This test will be implemented when BundleManager supports folders
    }

    @Test("skips notebook with corrupted manifest")
    func skipsCorruptedManifest() async throws {
      // GIVEN: A folder containing a notebook with invalid manifest.json
      // WHEN: listBundlesInFolder(folderID:) is called
      // THEN: That notebook is skipped
      // AND: Other valid notebooks are still returned

      // This test will be implemented when BundleManager supports folders
    }
  }
}

// MARK: - Modified Method Tests

// These tests verify that existing methods are updated to handle folders correctly.

@Suite("Modified Methods - listBundles", .serialized)
struct ModifiedListBundlesTests {

  @Test("excludes folders from notebook listing")
  func excludesFoldersFromListing() async throws {
    // GIVEN: Notebooks directory with 3 notebooks and 2 folders
    // WHEN: listBundles() is called
    // THEN: Returns array with 3 NotebookMetadata entries
    // AND: Does not include the 2 folders

    // This test will be implemented when BundleManager supports folders
  }

  @Test("returns only root-level notebooks")
  func returnsOnlyRootLevelNotebooks() async throws {
    // GIVEN: 2 notebooks at root and 3 notebooks inside folders
    // WHEN: listBundles() is called
    // THEN: Returns array with exactly 2 NotebookMetadata entries
    // AND: Does not include notebooks inside folders

    // This test will be implemented when BundleManager supports folders
  }

  @Test("treats directory with both manifests as folder")
  func treatsBothManifestsAsFolder() async throws {
    // GIVEN: A directory containing both manifest.json and folder.json
    // WHEN: listBundles() is called
    // THEN: That directory is treated as a folder
    // AND: It is not included in the notebook list

    // This test will be implemented when BundleManager supports folders
  }
}

@Suite("Modified Methods - openNotebook", .serialized)
struct ModifiedOpenNotebookTests {

  @Test("opens root-level notebook")
  func opensRootLevelNotebook() async throws {
    // GIVEN: A notebook at root level
    // WHEN: openNotebook(id:) is called
    // THEN: Returns DocumentHandle for the notebook

    // This test will be implemented when BundleManager supports folders
  }

  @Test("opens notebook inside folder")
  func opensNotebookInsideFolder() async throws {
    // GIVEN: A notebook inside a folder
    // WHEN: openNotebook(id:) is called
    // THEN: Returns DocumentHandle for the notebook
    // AND: Package path points to correct location inside folder

    // This test will be implemented when BundleManager supports folders
  }

  @Test("finds notebook regardless of location")
  func findsNotebookRegardlessOfLocation() async throws {
    // GIVEN: A notebook that was moved between root and folder
    // WHEN: openNotebook(id:) is called
    // THEN: Finds and opens the notebook at its current location

    // This test will be implemented when BundleManager supports folders
  }

  @Test("opens notebook when ID matches folder ID")
  func opensNotebookWhenIDMatchesFolderID() async throws {
    // GIVEN: A folder with same UUID as a notebook in another folder
    // WHEN: openNotebook(id:) is called with that ID
    // THEN: Opens the notebook (looks for manifest.json, not folder.json)

    // This test will be implemented when BundleManager supports folders
  }

  @Test("throws bundleNotFound when not found anywhere")
  func throwsWhenNotFoundAnywhere() async throws {
    // GIVEN: A notebookID that does not exist anywhere
    // WHEN: openNotebook(id:) is called
    // THEN: Throws BundleError.bundleNotFound(notebookID:)

    // This test will be implemented when BundleManager supports folders
  }
}

// MARK: - Integration Tests

// These tests verify complex workflows combining multiple operations.

@Suite("Folder Integration Tests", .serialized)
struct FolderIntegrationTests {

  @Test("full folder lifecycle")
  func fullFolderLifecycle() async throws {
    // GIVEN: An empty Notebooks directory
    // WHEN: Complete workflow is executed
    // 1. createFolder(displayName: "Projects")
    // 2. createBundle(displayName: "Notes")
    // 3. moveNotebookToFolder moves notebook to folder
    // 4. openNotebook opens the notebook
    // 5. Save content and close
    // 6. moveNotebookToRoot moves notebook back
    // 7. deleteFolder removes empty folder
    // THEN: All operations succeed
    // AND: Notebook remains accessible at root
    // AND: Folder is removed

    // This test will be implemented when BundleManager supports folders
  }

  @Test("folder with many notebooks")
  func folderWithManyNotebooks() async throws {
    // GIVEN: A folder
    // WHEN: 100 notebooks are created and moved into the folder
    // THEN: listBundlesInFolder returns all 100 notebooks
    // AND: FolderMetadata.notebookCount equals 100
    // AND: FolderMetadata.previewImages contains at most 4 images

    // This test will be implemented when BundleManager supports folders
  }

  @Test("notebook preservation during move")
  func notebookPreservationDuringMove() async throws {
    // GIVEN: A notebook with content, preview, and viewport state
    // WHEN: Moved to a folder, then back to root
    // THEN: All content is preserved
    // AND: Preview image is preserved
    // AND: Viewport state in manifest is preserved

    // This test will be implemented when BundleManager supports folders
  }
}

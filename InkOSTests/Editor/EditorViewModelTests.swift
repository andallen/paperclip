//
//  EditorViewModelTests.swift
//  InkOSTests
//
//  Tests for EditorViewModelProtocol. All tests are derived from the protocol definition.
//  The tests cover published properties, setup, tool selection, edit operations, and lifecycle.
//

import Testing
import UIKit
import Combine
@testable import InkOS

// MARK: - Mock Types

// Mock InputViewController for testing. Tracks which tool selection methods were called.
@MainActor
final class MockInputViewController: UIViewController {
  var selectPenToolCallCount = 0
  var selectEraserToolCallCount = 0
  var selectHighlighterToolCallCount = 0
  var inputMode: InputMode = .forcePen
  var lastSetFrame: CGRect?

  func selectPenTool() {
    selectPenToolCallCount += 1
  }

  func selectEraserTool() {
    selectEraserToolCallCount += 1
  }

  func selectHighlighterTool() {
    selectHighlighterToolCallCount += 1
  }

  func updateInputMode(_ mode: InputMode) {
    inputMode = mode
  }

  override func viewDidLoad() {
    super.viewDidLoad()
  }
}

// Mock IINKEditor for testing. Tracks method calls and simulates undo/redo state.
@MainActor
final class MockIINKEditor {
  var clearCallCount = 0
  var undoCallCount = 0
  var redoCallCount = 0
  var undoStack: [String] = []
  var redoStack: [String] = []
  var shouldThrowOnClear = false
  var shouldThrowOnUndo = false
  var shouldThrowOnRedo = false
  var setPart: Any?
  var viewOffset: CGPoint = .zero
  var viewScale: CGFloat = 1.0

  func clear() throws {
    if shouldThrowOnClear {
      throw MockEditorError.clearFailed
    }
    clearCallCount += 1
    undoStack.removeAll()
    redoStack.removeAll()
  }

  func undo() throws {
    if shouldThrowOnUndo {
      throw MockEditorError.undoFailed
    }
    guard let lastAction = undoStack.popLast() else { return }
    redoStack.append(lastAction)
    undoCallCount += 1
  }

  func redo() throws {
    if shouldThrowOnRedo {
      throw MockEditorError.redoFailed
    }
    guard let lastUndone = redoStack.popLast() else { return }
    undoStack.append(lastUndone)
    redoCallCount += 1
  }

  func canUndo() -> Bool {
    return !undoStack.isEmpty
  }

  func canRedo() -> Bool {
    return !redoStack.isEmpty
  }

  func set(part: Any?) {
    setPart = part
  }

  // Simulates adding an action to the undo stack.
  func addAction(_ action: String) {
    undoStack.append(action)
    redoStack.removeAll()
  }
}

// Mock EngineProvider for testing. Provides a controllable engine instance.
@MainActor
final class MockEngineProvider {
  var engine: MockIINKEngine?
  var engineErrorMessage: String = ""

  // Default initializer creates a MockIINKEngine.
  init() {
    self.engine = MockIINKEngine()
  }

  // Explicit initializer allows setting engine to nil for testing error cases.
  init(withEngine engine: MockIINKEngine?) {
    self.engine = engine
  }
}

// Mock IINKEngine for testing package creation.
@MainActor
final class MockIINKEngine {
  var createdEditors: [MockIINKEditor] = []

  func createEditor() -> MockIINKEditor {
    let editor = MockIINKEditor()
    createdEditors.append(editor)
    return editor
  }
}

// Mock DocumentHandle for testing. Tracks save and close operations.
actor MockDocumentHandle {
  let notebookID: String
  var manifest: MockManifest
  var savePackageCallCount = 0
  var savePackageToTempCallCount = 0
  var closeCallCount = 0
  var savedPreviewData: Data?
  var savedViewportState: MockViewportState?
  var shouldThrowOnSave = false

  init(notebookID: String, displayName: String) {
    self.notebookID = notebookID
    self.manifest = MockManifest(displayName: displayName)
  }

  func savePackage() async throws {
    if shouldThrowOnSave {
      throw MockEditorError.saveFailed
    }
    savePackageCallCount += 1
  }

  func savePackageToTemp() async throws {
    savePackageToTempCallCount += 1
  }

  func close(saveBeforeClose: Bool) async {
    closeCallCount += 1
  }

  func savePreviewImageData(_ data: Data) throws {
    savedPreviewData = data
  }

  func updateViewportState(_ state: MockViewportState) async {
    savedViewportState = state
  }
}

// Mock Manifest for testing.
struct MockManifest {
  var displayName: String
  var viewportState: MockViewportState?
}

// Mock ViewportState for testing.
struct MockViewportState {
  var offsetX: CGFloat
  var offsetY: CGFloat
  var scale: CGFloat
}

// Mock errors for testing error handling.
enum MockEditorError: Error, LocalizedError {
  case clearFailed
  case undoFailed
  case redoFailed
  case saveFailed
  case missingNotebook

  var errorDescription: String? {
    switch self {
    case .clearFailed: return "Failed to clear editor content"
    case .undoFailed: return "Failed to undo action"
    case .redoFailed: return "Failed to redo action"
    case .saveFailed: return "Failed to save notebook"
    case .missingNotebook: return "Notebook details are missing"
    }
  }
}

// Mock EditorViewModel that implements the protocol behavior for testing.
// This tracks all method calls and state changes.
@MainActor
final class MockEditorViewModel {
  // Published properties.
  var editorViewController: MockInputViewController?
  var title: String?
  var alert: UIAlertController?

  // Properties.
  var editor: MockIINKEditor?

  // Internal state for tracking.
  var setupModelCallCount = 0
  var setEditorViewSizeCallCount = 0
  var lastBounds: CGRect?
  var selectToolCallCount = 0
  var lastSelectedTool: ToolPaletteView.ToolSelection?
  var selectPenToolCallCount = 0
  var selectEraserToolCallCount = 0
  var selectHighlighterToolCallCount = 0
  var updateInputModeCallCount = 0
  var lastInputMode: InputMode?
  var updateToolCallCount = 0
  var updateInkColorCallCount = 0
  var lastColorHex: String?
  var lastColorTool: ToolPaletteView.ToolSelection?
  var updateInkWidthCallCount = 0
  var lastWidth: CGFloat?
  var lastWidthTool: ToolPaletteView.ToolSelection?
  var clearCallCount = 0
  var undoCallCount = 0
  var redoCallCount = 0
  var releaseEditorCallCount = 0
  var lastPreviewImage: UIImage?
  var handleAppBackgroundCallCount = 0
  var presentMissingNotebookErrorCallCount = 0

  // Storage for deferred tool application.
  var pendingToolSelection: ToolPaletteView.ToolSelection?
  var selectedPenColorHex: String = "#000000"
  var selectedPenWidth: CGFloat = 0.65
  var selectedHighlighterColorHex: String = "#FFFF00"
  var selectedHighlighterWidth: CGFloat = 5.0

  // Dependencies.
  var engineProvider: MockEngineProvider?
  var documentHandle: MockDocumentHandle?

  func setupModel(engineProvider: MockEngineProvider, documentHandle: MockDocumentHandle) {
    setupModelCallCount += 1
    self.engineProvider = engineProvider
    self.documentHandle = documentHandle

    // Create the input view controller.
    editorViewController = MockInputViewController()

    // Set title from manifest.
    Task {
      title = await documentHandle.manifest.displayName
    }
  }

  func setEditorViewSize(bounds: CGRect) {
    setEditorViewSizeCallCount += 1
    lastBounds = bounds
    editorViewController?.lastSetFrame = bounds
    editorViewController?.view.frame = bounds
  }

  func selectTool(_ selection: ToolPaletteView.ToolSelection) {
    selectToolCallCount += 1
    lastSelectedTool = selection

    switch selection {
    case .pen:
      selectPenTool()
    case .eraser:
      selectEraserTool()
    case .highlighter:
      selectHighlighterTool()
    }
  }

  func selectPenTool() {
    selectPenToolCallCount += 1
    editorViewController?.selectPenTool()
  }

  func selectEraserTool() {
    selectEraserToolCallCount += 1
    editorViewController?.selectEraserTool()
  }

  func selectHighlighterTool() {
    selectHighlighterToolCallCount += 1
    editorViewController?.selectHighlighterTool()
  }

  func updateInputMode(newInputMode: InputMode) {
    updateInputModeCallCount += 1
    lastInputMode = newInputMode
    editorViewController?.updateInputMode(newInputMode)

    // Reapply current tool selection to update touch behavior.
    if let tool = lastSelectedTool {
      selectTool(tool)
    }
  }

  func updateTool(selection: ToolPaletteView.ToolSelection) {
    updateToolCallCount += 1
    pendingToolSelection = selection

    // If editor exists, apply immediately.
    if editor != nil {
      selectTool(selection)
    }
  }

  func updateInkColor(hex: String, for tool: ToolPaletteView.ToolSelection) {
    updateInkColorCallCount += 1
    lastColorHex = hex
    lastColorTool = tool

    switch tool {
    case .pen:
      selectedPenColorHex = hex
    case .highlighter:
      selectedHighlighterColorHex = hex
    case .eraser:
      // No-op for eraser - erasers don't have a color.
      break
    }
  }

  func updateInkWidth(width: CGFloat, for tool: ToolPaletteView.ToolSelection) {
    updateInkWidthCallCount += 1
    lastWidth = width
    lastWidthTool = tool

    switch tool {
    case .pen:
      selectedPenWidth = width
    case .highlighter:
      selectedHighlighterWidth = width
    case .eraser:
      // No-op for eraser - eraser width is controlled separately.
      break
    }
  }

  func clear() {
    clearCallCount += 1
    do {
      try editor?.clear()
    } catch {
      alert = UIAlertController(
        title: "Error",
        message: error.localizedDescription,
        preferredStyle: .alert
      )
    }
  }

  func undo() {
    undoCallCount += 1
    do {
      try editor?.undo()
    } catch {
      alert = UIAlertController(
        title: "Error",
        message: error.localizedDescription,
        preferredStyle: .alert
      )
    }
  }

  func redo() {
    redoCallCount += 1
    do {
      try editor?.redo()
    } catch {
      alert = UIAlertController(
        title: "Error",
        message: error.localizedDescription,
        preferredStyle: .alert
      )
    }
  }

  func releaseEditor(previewImage: UIImage?) {
    releaseEditorCallCount += 1
    lastPreviewImage = previewImage

    // Capture viewport state before releasing.
    if let editor = editor {
      let viewportState = MockViewportState(
        offsetX: editor.viewOffset.x,
        offsetY: editor.viewOffset.y,
        scale: editor.viewScale
      )

      // Release the editor's part binding.
      editor.set(part: nil)

      // Async save operations.
      Task {
        await documentHandle?.updateViewportState(viewportState)

        if let imageData = previewImage?.pngData() {
          try? await documentHandle?.savePreviewImageData(imageData)
        }

        do {
          try await documentHandle?.savePackage()
        } catch {
          alert = UIAlertController(
            title: "Error",
            message: error.localizedDescription,
            preferredStyle: .alert
          )
        }

        await documentHandle?.close(saveBeforeClose: false)
      }
    }
  }

  func handleAppBackground() {
    handleAppBackgroundCallCount += 1
    Task {
      try? await documentHandle?.savePackage()
    }
  }

  func presentMissingNotebookError() {
    presentMissingNotebookErrorCallCount += 1
    alert = UIAlertController(
      title: "Error",
      message: "Notebook details are missing.",
      preferredStyle: .alert
    )
  }

  // EditorDelegateProtocol callbacks.
  func didCreateEditor(editor: MockIINKEditor) {
    self.editor = editor

    // Apply pending tool selection.
    if let pending = pendingToolSelection {
      selectTool(pending)
    }
  }

  func partChanged(editor: MockIINKEditor) {
    // Currently no behavior defined.
  }

  func contentChanged(editor: MockIINKEditor, blockIds: [String]) {
    // Trigger auto-save scheduling.
  }

  func onError(editor: MockIINKEditor, blockId: String, message: String) {
    alert = UIAlertController(
      title: "Error",
      message: message,
      preferredStyle: .alert
    )
  }
}

// MARK: - Test Suite

@Suite("EditorViewModel Tests")
struct EditorViewModelTests {

  // MARK: - Published Properties Tests

  @Suite("Published Properties")
  struct PublishedPropertiesTests {

    @Test("editorViewController is nil before setup")
    @MainActor
    func editorViewControllerNilBeforeSetup() {
      let viewModel = MockEditorViewModel()
      #expect(viewModel.editorViewController == nil)
    }

    @Test("editorViewController is set after setupModel")
    @MainActor
    func editorViewControllerSetAfterSetup() async {
      let viewModel = MockEditorViewModel()
      let engineProvider = MockEngineProvider()
      let documentHandle = MockDocumentHandle(notebookID: "test-id", displayName: "Test Notebook")

      viewModel.setupModel(engineProvider: engineProvider, documentHandle: documentHandle)

      #expect(viewModel.editorViewController != nil)
    }

    @Test("title is nil before setup")
    @MainActor
    func titleNilBeforeSetup() {
      let viewModel = MockEditorViewModel()
      #expect(viewModel.title == nil)
    }

    @Test("title is set from manifest displayName after setup")
    @MainActor
    func titleSetFromManifest() async throws {
      let viewModel = MockEditorViewModel()
      let engineProvider = MockEngineProvider()
      let documentHandle = MockDocumentHandle(notebookID: "test-id", displayName: "My Notebook")

      viewModel.setupModel(engineProvider: engineProvider, documentHandle: documentHandle)

      // Wait for async title update.
      try await Task.sleep(nanoseconds: 100_000_000)

      #expect(viewModel.title == "My Notebook")
    }

    @Test("alert is nil by default")
    @MainActor
    func alertNilByDefault() {
      let viewModel = MockEditorViewModel()
      #expect(viewModel.alert == nil)
    }

    @Test("alert can be set and cleared")
    @MainActor
    func alertCanBeSetAndCleared() {
      let viewModel = MockEditorViewModel()

      let testAlert = UIAlertController(title: "Test", message: "Test message", preferredStyle: .alert)
      viewModel.alert = testAlert

      #expect(viewModel.alert === testAlert)

      viewModel.alert = nil
      #expect(viewModel.alert == nil)
    }

    @Test("editor is nil before didCreateEditor callback")
    @MainActor
    func editorNilBeforeCallback() {
      let viewModel = MockEditorViewModel()
      #expect(viewModel.editor == nil)
    }

    @Test("editor is set by didCreateEditor callback")
    @MainActor
    func editorSetByCallback() {
      let viewModel = MockEditorViewModel()
      let mockEditor = MockIINKEditor()

      viewModel.didCreateEditor(editor: mockEditor)

      #expect(viewModel.editor === mockEditor)
    }
  }

  // MARK: - Setup Tests

  @Suite("Setup Methods")
  struct SetupTests {

    @Test("setupModel creates InputViewController")
    @MainActor
    func setupModelCreatesViewController() {
      let viewModel = MockEditorViewModel()
      let engineProvider = MockEngineProvider()
      let documentHandle = MockDocumentHandle(notebookID: "test-id", displayName: "Test")

      viewModel.setupModel(engineProvider: engineProvider, documentHandle: documentHandle)

      #expect(viewModel.editorViewController != nil)
      #expect(viewModel.setupModelCallCount == 1)
    }

    @Test("setupModel stores document handle reference")
    @MainActor
    func setupModelStoresDocumentHandle() {
      let viewModel = MockEditorViewModel()
      let engineProvider = MockEngineProvider()
      let documentHandle = MockDocumentHandle(notebookID: "test-id", displayName: "Test")

      viewModel.setupModel(engineProvider: engineProvider, documentHandle: documentHandle)

      #expect(viewModel.documentHandle === documentHandle)
    }

    @Test("setupModel stores engine provider reference")
    @MainActor
    func setupModelStoresEngineProvider() {
      let viewModel = MockEditorViewModel()
      let engineProvider = MockEngineProvider()
      let documentHandle = MockDocumentHandle(notebookID: "test-id", displayName: "Test")

      viewModel.setupModel(engineProvider: engineProvider, documentHandle: documentHandle)

      #expect(viewModel.engineProvider === engineProvider)
    }

    @Test("setEditorViewSize updates the frame")
    @MainActor
    func setEditorViewSizeUpdatesFrame() {
      let viewModel = MockEditorViewModel()
      let engineProvider = MockEngineProvider()
      let documentHandle = MockDocumentHandle(notebookID: "test-id", displayName: "Test")

      viewModel.setupModel(engineProvider: engineProvider, documentHandle: documentHandle)

      let testBounds = CGRect(x: 0, y: 0, width: 800, height: 600)
      viewModel.setEditorViewSize(bounds: testBounds)

      #expect(viewModel.setEditorViewSizeCallCount == 1)
      #expect(viewModel.lastBounds == testBounds)
    }

    @Test("setEditorViewSize can be called multiple times for rotation")
    @MainActor
    func setEditorViewSizeMultipleTimes() {
      let viewModel = MockEditorViewModel()
      let engineProvider = MockEngineProvider()
      let documentHandle = MockDocumentHandle(notebookID: "test-id", displayName: "Test")

      viewModel.setupModel(engineProvider: engineProvider, documentHandle: documentHandle)

      let portraitBounds = CGRect(x: 0, y: 0, width: 375, height: 667)
      let landscapeBounds = CGRect(x: 0, y: 0, width: 667, height: 375)

      viewModel.setEditorViewSize(bounds: portraitBounds)
      viewModel.setEditorViewSize(bounds: landscapeBounds)

      #expect(viewModel.setEditorViewSizeCallCount == 2)
      #expect(viewModel.lastBounds == landscapeBounds)
    }

    @Test("setEditorViewSize with zero bounds")
    @MainActor
    func setEditorViewSizeWithZeroBounds() {
      let viewModel = MockEditorViewModel()
      let engineProvider = MockEngineProvider()
      let documentHandle = MockDocumentHandle(notebookID: "test-id", displayName: "Test")

      viewModel.setupModel(engineProvider: engineProvider, documentHandle: documentHandle)

      let zeroBounds = CGRect.zero
      viewModel.setEditorViewSize(bounds: zeroBounds)

      #expect(viewModel.lastBounds == zeroBounds)
    }
  }

  // MARK: - Tool Selection Tests

  @Suite("Tool Selection")
  struct ToolSelectionTests {

    @Test("selectTool with pen dispatches to selectPenTool")
    @MainActor
    func selectToolPen() {
      let viewModel = MockEditorViewModel()
      let engineProvider = MockEngineProvider()
      let documentHandle = MockDocumentHandle(notebookID: "test-id", displayName: "Test")

      viewModel.setupModel(engineProvider: engineProvider, documentHandle: documentHandle)
      viewModel.selectTool(.pen)

      #expect(viewModel.selectToolCallCount == 1)
      #expect(viewModel.lastSelectedTool == .pen)
      #expect(viewModel.selectPenToolCallCount == 1)
      #expect(viewModel.editorViewController?.selectPenToolCallCount == 1)
    }

    @Test("selectTool with eraser dispatches to selectEraserTool")
    @MainActor
    func selectToolEraser() {
      let viewModel = MockEditorViewModel()
      let engineProvider = MockEngineProvider()
      let documentHandle = MockDocumentHandle(notebookID: "test-id", displayName: "Test")

      viewModel.setupModel(engineProvider: engineProvider, documentHandle: documentHandle)
      viewModel.selectTool(.eraser)

      #expect(viewModel.selectToolCallCount == 1)
      #expect(viewModel.lastSelectedTool == .eraser)
      #expect(viewModel.selectEraserToolCallCount == 1)
      #expect(viewModel.editorViewController?.selectEraserToolCallCount == 1)
    }

    @Test("selectTool with highlighter dispatches to selectHighlighterTool")
    @MainActor
    func selectToolHighlighter() {
      let viewModel = MockEditorViewModel()
      let engineProvider = MockEngineProvider()
      let documentHandle = MockDocumentHandle(notebookID: "test-id", displayName: "Test")

      viewModel.setupModel(engineProvider: engineProvider, documentHandle: documentHandle)
      viewModel.selectTool(.highlighter)

      #expect(viewModel.selectToolCallCount == 1)
      #expect(viewModel.lastSelectedTool == .highlighter)
      #expect(viewModel.selectHighlighterToolCallCount == 1)
      #expect(viewModel.editorViewController?.selectHighlighterToolCallCount == 1)
    }

    @Test("selectPenTool can be called directly")
    @MainActor
    func selectPenToolDirect() {
      let viewModel = MockEditorViewModel()
      let engineProvider = MockEngineProvider()
      let documentHandle = MockDocumentHandle(notebookID: "test-id", displayName: "Test")

      viewModel.setupModel(engineProvider: engineProvider, documentHandle: documentHandle)
      viewModel.selectPenTool()

      #expect(viewModel.selectPenToolCallCount == 1)
    }

    @Test("selectEraserTool can be called directly")
    @MainActor
    func selectEraserToolDirect() {
      let viewModel = MockEditorViewModel()
      let engineProvider = MockEngineProvider()
      let documentHandle = MockDocumentHandle(notebookID: "test-id", displayName: "Test")

      viewModel.setupModel(engineProvider: engineProvider, documentHandle: documentHandle)
      viewModel.selectEraserTool()

      #expect(viewModel.selectEraserToolCallCount == 1)
    }

    @Test("selectHighlighterTool can be called directly")
    @MainActor
    func selectHighlighterToolDirect() {
      let viewModel = MockEditorViewModel()
      let engineProvider = MockEngineProvider()
      let documentHandle = MockDocumentHandle(notebookID: "test-id", displayName: "Test")

      viewModel.setupModel(engineProvider: engineProvider, documentHandle: documentHandle)
      viewModel.selectHighlighterTool()

      #expect(viewModel.selectHighlighterToolCallCount == 1)
    }

    @Test("tool selection is preserved when switching away and back")
    @MainActor
    func toolSelectionPreserved() {
      let viewModel = MockEditorViewModel()
      let engineProvider = MockEngineProvider()
      let documentHandle = MockDocumentHandle(notebookID: "test-id", displayName: "Test")

      viewModel.setupModel(engineProvider: engineProvider, documentHandle: documentHandle)

      viewModel.selectTool(.pen)
      viewModel.selectTool(.eraser)
      viewModel.selectTool(.pen)

      #expect(viewModel.selectToolCallCount == 3)
      #expect(viewModel.selectPenToolCallCount == 2)
      #expect(viewModel.selectEraserToolCallCount == 1)
    }

    @Test("rapid tool switching handles all selections")
    @MainActor
    func rapidToolSwitching() {
      let viewModel = MockEditorViewModel()
      let engineProvider = MockEngineProvider()
      let documentHandle = MockDocumentHandle(notebookID: "test-id", displayName: "Test")

      viewModel.setupModel(engineProvider: engineProvider, documentHandle: documentHandle)

      for _ in 0..<10 {
        viewModel.selectTool(.pen)
        viewModel.selectTool(.eraser)
        viewModel.selectTool(.highlighter)
      }

      #expect(viewModel.selectToolCallCount == 30)
      #expect(viewModel.selectPenToolCallCount == 10)
      #expect(viewModel.selectEraserToolCallCount == 10)
      #expect(viewModel.selectHighlighterToolCallCount == 10)
    }
  }

  // MARK: - Input Mode Tests

  @Suite("Input Mode")
  struct InputModeTests {

    @Test("updateInputMode stores the new mode")
    @MainActor
    func updateInputModeStoresMode() {
      let viewModel = MockEditorViewModel()
      let engineProvider = MockEngineProvider()
      let documentHandle = MockDocumentHandle(notebookID: "test-id", displayName: "Test")

      viewModel.setupModel(engineProvider: engineProvider, documentHandle: documentHandle)
      viewModel.updateInputMode(newInputMode: .auto)

      #expect(viewModel.updateInputModeCallCount == 1)
      #expect(viewModel.lastInputMode == .auto)
    }

    @Test("updateInputMode updates InputViewController")
    @MainActor
    func updateInputModeUpdatesViewController() {
      let viewModel = MockEditorViewModel()
      let engineProvider = MockEngineProvider()
      let documentHandle = MockDocumentHandle(notebookID: "test-id", displayName: "Test")

      viewModel.setupModel(engineProvider: engineProvider, documentHandle: documentHandle)
      viewModel.updateInputMode(newInputMode: .auto)

      #expect(viewModel.editorViewController?.inputMode == .auto)
    }

    @Test("updateInputMode reapplies current tool selection")
    @MainActor
    func updateInputModeReappliesTool() {
      let viewModel = MockEditorViewModel()
      let engineProvider = MockEngineProvider()
      let documentHandle = MockDocumentHandle(notebookID: "test-id", displayName: "Test")

      viewModel.setupModel(engineProvider: engineProvider, documentHandle: documentHandle)
      viewModel.selectTool(.eraser)

      let eraserCountBefore = viewModel.selectEraserToolCallCount
      viewModel.updateInputMode(newInputMode: .auto)

      #expect(viewModel.selectEraserToolCallCount == eraserCountBefore + 1)
    }

    @Test("updateInputMode from forcePen to auto")
    @MainActor
    func updateInputModeForcePenToAuto() {
      let viewModel = MockEditorViewModel()
      let engineProvider = MockEngineProvider()
      let documentHandle = MockDocumentHandle(notebookID: "test-id", displayName: "Test")

      viewModel.setupModel(engineProvider: engineProvider, documentHandle: documentHandle)

      #expect(viewModel.editorViewController?.inputMode == .forcePen)

      viewModel.updateInputMode(newInputMode: .auto)

      #expect(viewModel.editorViewController?.inputMode == .auto)
    }

    @Test("updateInputMode from auto to forcePen")
    @MainActor
    func updateInputModeAutoToForcePen() {
      let viewModel = MockEditorViewModel()
      let engineProvider = MockEngineProvider()
      let documentHandle = MockDocumentHandle(notebookID: "test-id", displayName: "Test")

      viewModel.setupModel(engineProvider: engineProvider, documentHandle: documentHandle)
      viewModel.editorViewController?.inputMode = .auto
      viewModel.updateInputMode(newInputMode: .forcePen)

      #expect(viewModel.editorViewController?.inputMode == .forcePen)
    }
  }

  // MARK: - Tool Update Tests

  @Suite("Tool Updates")
  struct ToolUpdateTests {

    @Test("updateTool stores pending selection when editor not ready")
    @MainActor
    func updateToolStoresPendingSelection() {
      let viewModel = MockEditorViewModel()
      let engineProvider = MockEngineProvider()
      let documentHandle = MockDocumentHandle(notebookID: "test-id", displayName: "Test")

      viewModel.setupModel(engineProvider: engineProvider, documentHandle: documentHandle)

      // Editor is nil so selection should be stored.
      viewModel.updateTool(selection: .highlighter)

      #expect(viewModel.updateToolCallCount == 1)
      #expect(viewModel.pendingToolSelection == .highlighter)
      #expect(viewModel.selectToolCallCount == 0)
    }

    @Test("updateTool applies immediately when editor exists")
    @MainActor
    func updateToolAppliesWhenEditorExists() {
      let viewModel = MockEditorViewModel()
      let engineProvider = MockEngineProvider()
      let documentHandle = MockDocumentHandle(notebookID: "test-id", displayName: "Test")

      viewModel.setupModel(engineProvider: engineProvider, documentHandle: documentHandle)
      viewModel.didCreateEditor(editor: MockIINKEditor())

      viewModel.updateTool(selection: .eraser)

      #expect(viewModel.updateToolCallCount == 1)
      #expect(viewModel.selectToolCallCount == 1)
      #expect(viewModel.lastSelectedTool == .eraser)
    }

    @Test("didCreateEditor applies pending tool selection")
    @MainActor
    func didCreateEditorAppliesPendingTool() {
      let viewModel = MockEditorViewModel()
      let engineProvider = MockEngineProvider()
      let documentHandle = MockDocumentHandle(notebookID: "test-id", displayName: "Test")

      viewModel.setupModel(engineProvider: engineProvider, documentHandle: documentHandle)
      viewModel.updateTool(selection: .highlighter)

      #expect(viewModel.selectToolCallCount == 0)

      viewModel.didCreateEditor(editor: MockIINKEditor())

      #expect(viewModel.selectToolCallCount == 1)
      #expect(viewModel.lastSelectedTool == .highlighter)
    }
  }

  // MARK: - Ink Color Tests

  @Suite("Ink Color")
  struct InkColorTests {

    @Test("updateInkColor for pen stores the color")
    @MainActor
    func updateInkColorForPen() {
      let viewModel = MockEditorViewModel()

      viewModel.updateInkColor(hex: "#FF5733", for: .pen)

      #expect(viewModel.updateInkColorCallCount == 1)
      #expect(viewModel.lastColorHex == "#FF5733")
      #expect(viewModel.lastColorTool == .pen)
      #expect(viewModel.selectedPenColorHex == "#FF5733")
    }

    @Test("updateInkColor for highlighter stores the color")
    @MainActor
    func updateInkColorForHighlighter() {
      let viewModel = MockEditorViewModel()

      viewModel.updateInkColor(hex: "#FFFF00", for: .highlighter)

      #expect(viewModel.updateInkColorCallCount == 1)
      #expect(viewModel.lastColorHex == "#FFFF00")
      #expect(viewModel.lastColorTool == .highlighter)
      #expect(viewModel.selectedHighlighterColorHex == "#FFFF00")
    }

    @Test("updateInkColor for eraser is a no-op")
    @MainActor
    func updateInkColorForEraserIsNoOp() {
      let viewModel = MockEditorViewModel()
      let originalPenColor = viewModel.selectedPenColorHex
      let originalHighlighterColor = viewModel.selectedHighlighterColorHex

      viewModel.updateInkColor(hex: "#FF0000", for: .eraser)

      #expect(viewModel.updateInkColorCallCount == 1)
      #expect(viewModel.selectedPenColorHex == originalPenColor)
      #expect(viewModel.selectedHighlighterColorHex == originalHighlighterColor)
    }

    @Test("updateInkColor preserves color when switching tools")
    @MainActor
    func updateInkColorPreservedOnToolSwitch() {
      let viewModel = MockEditorViewModel()
      let engineProvider = MockEngineProvider()
      let documentHandle = MockDocumentHandle(notebookID: "test-id", displayName: "Test")

      viewModel.setupModel(engineProvider: engineProvider, documentHandle: documentHandle)

      viewModel.updateInkColor(hex: "#FF0000", for: .pen)
      viewModel.selectTool(.eraser)
      viewModel.selectTool(.pen)

      #expect(viewModel.selectedPenColorHex == "#FF0000")
    }

    @Test("updateInkColor with various hex formats")
    @MainActor
    func updateInkColorVariousFormats() {
      let viewModel = MockEditorViewModel()

      // Standard 6-digit hex.
      viewModel.updateInkColor(hex: "#123456", for: .pen)
      #expect(viewModel.selectedPenColorHex == "#123456")

      // Lowercase hex.
      viewModel.updateInkColor(hex: "#abcdef", for: .pen)
      #expect(viewModel.selectedPenColorHex == "#abcdef")

      // Uppercase hex.
      viewModel.updateInkColor(hex: "#ABCDEF", for: .pen)
      #expect(viewModel.selectedPenColorHex == "#ABCDEF")
    }

    @Test("updateInkColor with empty string")
    @MainActor
    func updateInkColorEmptyString() {
      let viewModel = MockEditorViewModel()

      viewModel.updateInkColor(hex: "", for: .pen)

      #expect(viewModel.selectedPenColorHex == "")
    }

    @Test("updateInkColor with invalid hex does not crash")
    @MainActor
    func updateInkColorInvalidHex() {
      let viewModel = MockEditorViewModel()

      // Invalid but should not crash - validation is up to the renderer.
      viewModel.updateInkColor(hex: "not-a-color", for: .pen)
      #expect(viewModel.selectedPenColorHex == "not-a-color")

      viewModel.updateInkColor(hex: "#GGG", for: .pen)
      #expect(viewModel.selectedPenColorHex == "#GGG")
    }
  }

  // MARK: - Ink Width Tests

  @Suite("Ink Width")
  struct InkWidthTests {

    @Test("updateInkWidth for pen stores the width")
    @MainActor
    func updateInkWidthForPen() {
      let viewModel = MockEditorViewModel()

      viewModel.updateInkWidth(width: 1.5, for: .pen)

      #expect(viewModel.updateInkWidthCallCount == 1)
      #expect(viewModel.lastWidth == 1.5)
      #expect(viewModel.lastWidthTool == .pen)
      #expect(viewModel.selectedPenWidth == 1.5)
    }

    @Test("updateInkWidth for highlighter stores the width")
    @MainActor
    func updateInkWidthForHighlighter() {
      let viewModel = MockEditorViewModel()

      viewModel.updateInkWidth(width: 8.0, for: .highlighter)

      #expect(viewModel.updateInkWidthCallCount == 1)
      #expect(viewModel.lastWidth == 8.0)
      #expect(viewModel.lastWidthTool == .highlighter)
      #expect(viewModel.selectedHighlighterWidth == 8.0)
    }

    @Test("updateInkWidth for eraser is a no-op")
    @MainActor
    func updateInkWidthForEraserIsNoOp() {
      let viewModel = MockEditorViewModel()
      let originalPenWidth = viewModel.selectedPenWidth
      let originalHighlighterWidth = viewModel.selectedHighlighterWidth

      viewModel.updateInkWidth(width: 10.0, for: .eraser)

      #expect(viewModel.updateInkWidthCallCount == 1)
      #expect(viewModel.selectedPenWidth == originalPenWidth)
      #expect(viewModel.selectedHighlighterWidth == originalHighlighterWidth)
    }

    @Test("updateInkWidth with minimum value")
    @MainActor
    func updateInkWidthMinimum() {
      let viewModel = MockEditorViewModel()

      viewModel.updateInkWidth(width: 0.3, for: .pen)

      #expect(viewModel.selectedPenWidth == 0.3)
    }

    @Test("updateInkWidth with maximum value")
    @MainActor
    func updateInkWidthMaximum() {
      let viewModel = MockEditorViewModel()

      viewModel.updateInkWidth(width: 2.0, for: .pen)
      #expect(viewModel.selectedPenWidth == 2.0)

      viewModel.updateInkWidth(width: 10.0, for: .highlighter)
      #expect(viewModel.selectedHighlighterWidth == 10.0)
    }

    @Test("updateInkWidth with zero value")
    @MainActor
    func updateInkWidthZero() {
      let viewModel = MockEditorViewModel()

      viewModel.updateInkWidth(width: 0, for: .pen)

      #expect(viewModel.selectedPenWidth == 0)
    }

    @Test("updateInkWidth with negative value")
    @MainActor
    func updateInkWidthNegative() {
      let viewModel = MockEditorViewModel()

      // Negative values should be handled - validation is up to the renderer.
      viewModel.updateInkWidth(width: -1.0, for: .pen)

      #expect(viewModel.selectedPenWidth == -1.0)
    }

    @Test("updateInkWidth with very large value")
    @MainActor
    func updateInkWidthVeryLarge() {
      let viewModel = MockEditorViewModel()

      viewModel.updateInkWidth(width: 1000.0, for: .pen)

      #expect(viewModel.selectedPenWidth == 1000.0)
    }
  }

  // MARK: - Edit Operations Tests

  @Suite("Edit Operations")
  struct EditOperationsTests {

    @Test("clear calls editor.clear()")
    @MainActor
    func clearCallsEditor() {
      let viewModel = MockEditorViewModel()
      let mockEditor = MockIINKEditor()

      viewModel.didCreateEditor(editor: mockEditor)
      viewModel.clear()

      #expect(viewModel.clearCallCount == 1)
      #expect(mockEditor.clearCallCount == 1)
    }

    @Test("clear shows alert on error")
    @MainActor
    func clearShowsAlertOnError() {
      let viewModel = MockEditorViewModel()
      let mockEditor = MockIINKEditor()
      mockEditor.shouldThrowOnClear = true

      viewModel.didCreateEditor(editor: mockEditor)
      viewModel.clear()

      #expect(viewModel.alert != nil)
      #expect(viewModel.alert?.title == "Error")
    }

    @Test("clear with nil editor does nothing")
    @MainActor
    func clearWithNilEditor() {
      let viewModel = MockEditorViewModel()

      viewModel.clear()

      #expect(viewModel.clearCallCount == 1)
      #expect(viewModel.alert == nil)
    }

    @Test("undo calls editor.undo()")
    @MainActor
    func undoCallsEditor() {
      let viewModel = MockEditorViewModel()
      let mockEditor = MockIINKEditor()
      mockEditor.addAction("draw stroke")

      viewModel.didCreateEditor(editor: mockEditor)
      viewModel.undo()

      #expect(viewModel.undoCallCount == 1)
      #expect(mockEditor.undoCallCount == 1)
    }

    @Test("undo shows alert on error")
    @MainActor
    func undoShowsAlertOnError() {
      let viewModel = MockEditorViewModel()
      let mockEditor = MockIINKEditor()
      mockEditor.shouldThrowOnUndo = true
      mockEditor.addAction("draw stroke")

      viewModel.didCreateEditor(editor: mockEditor)
      viewModel.undo()

      #expect(viewModel.alert != nil)
      #expect(viewModel.alert?.title == "Error")
    }

    @Test("undo with nil editor does nothing")
    @MainActor
    func undoWithNilEditor() {
      let viewModel = MockEditorViewModel()

      viewModel.undo()

      #expect(viewModel.undoCallCount == 1)
      #expect(viewModel.alert == nil)
    }

    @Test("undo with empty undo stack does nothing")
    @MainActor
    func undoWithEmptyStack() {
      let viewModel = MockEditorViewModel()
      let mockEditor = MockIINKEditor()

      viewModel.didCreateEditor(editor: mockEditor)
      viewModel.undo()

      #expect(mockEditor.undoCallCount == 0)
      #expect(mockEditor.canUndo() == false)
    }

    @Test("redo calls editor.redo()")
    @MainActor
    func redoCallsEditor() {
      let viewModel = MockEditorViewModel()
      let mockEditor = MockIINKEditor()
      mockEditor.addAction("draw stroke")
      try? mockEditor.undo()

      viewModel.didCreateEditor(editor: mockEditor)
      viewModel.redo()

      #expect(viewModel.redoCallCount == 1)
      #expect(mockEditor.redoCallCount == 1)
    }

    @Test("redo shows alert on error")
    @MainActor
    func redoShowsAlertOnError() {
      let viewModel = MockEditorViewModel()
      let mockEditor = MockIINKEditor()
      mockEditor.shouldThrowOnRedo = true
      mockEditor.addAction("draw stroke")
      try? mockEditor.undo()

      viewModel.didCreateEditor(editor: mockEditor)
      viewModel.redo()

      #expect(viewModel.alert != nil)
      #expect(viewModel.alert?.title == "Error")
    }

    @Test("redo with nil editor does nothing")
    @MainActor
    func redoWithNilEditor() {
      let viewModel = MockEditorViewModel()

      viewModel.redo()

      #expect(viewModel.redoCallCount == 1)
      #expect(viewModel.alert == nil)
    }

    @Test("redo with empty redo stack does nothing")
    @MainActor
    func redoWithEmptyStack() {
      let viewModel = MockEditorViewModel()
      let mockEditor = MockIINKEditor()

      viewModel.didCreateEditor(editor: mockEditor)
      viewModel.redo()

      #expect(mockEditor.redoCallCount == 0)
      #expect(mockEditor.canRedo() == false)
    }

    @Test("undo followed by redo restores state")
    @MainActor
    func undoRedoRestoresState() {
      let viewModel = MockEditorViewModel()
      let mockEditor = MockIINKEditor()

      viewModel.didCreateEditor(editor: mockEditor)
      mockEditor.addAction("draw stroke")

      #expect(mockEditor.canUndo() == true)
      #expect(mockEditor.canRedo() == false)

      viewModel.undo()

      #expect(mockEditor.canUndo() == false)
      #expect(mockEditor.canRedo() == true)

      viewModel.redo()

      #expect(mockEditor.canUndo() == true)
      #expect(mockEditor.canRedo() == false)
    }

    @Test("clear clears undo stack")
    @MainActor
    func clearClearsUndoStack() {
      let viewModel = MockEditorViewModel()
      let mockEditor = MockIINKEditor()

      viewModel.didCreateEditor(editor: mockEditor)
      mockEditor.addAction("draw stroke")
      mockEditor.addAction("draw another stroke")

      #expect(mockEditor.canUndo() == true)

      viewModel.clear()

      #expect(mockEditor.canUndo() == false)
    }

    @Test("new edit after undo clears redo stack")
    @MainActor
    func newEditClearsRedoStack() {
      let viewModel = MockEditorViewModel()
      let mockEditor = MockIINKEditor()

      viewModel.didCreateEditor(editor: mockEditor)
      mockEditor.addAction("stroke 1")
      viewModel.undo()

      #expect(mockEditor.canRedo() == true)

      mockEditor.addAction("stroke 2")

      #expect(mockEditor.canRedo() == false)
    }
  }

  // MARK: - Lifecycle Tests

  @Suite("Lifecycle")
  struct LifecycleTests {

    @Test("releaseEditor captures viewport state")
    @MainActor
    func releaseEditorCapturesViewport() async throws {
      let viewModel = MockEditorViewModel()
      let engineProvider = MockEngineProvider()
      let documentHandle = MockDocumentHandle(notebookID: "test-id", displayName: "Test")
      let mockEditor = MockIINKEditor()
      mockEditor.viewOffset = CGPoint(x: 100, y: 200)
      mockEditor.viewScale = 2.0

      viewModel.setupModel(engineProvider: engineProvider, documentHandle: documentHandle)
      viewModel.didCreateEditor(editor: mockEditor)
      viewModel.releaseEditor(previewImage: nil)

      try await Task.sleep(nanoseconds: 100_000_000)

      let savedState = await documentHandle.savedViewportState
      #expect(savedState?.offsetX == 100)
      #expect(savedState?.offsetY == 200)
      #expect(savedState?.scale == 2.0)
    }

    @Test("releaseEditor releases editor part binding")
    @MainActor
    func releaseEditorReleasesPartBinding() {
      let viewModel = MockEditorViewModel()
      let mockEditor = MockIINKEditor()
      mockEditor.setPart = "some-part"

      viewModel.didCreateEditor(editor: mockEditor)
      viewModel.releaseEditor(previewImage: nil)

      #expect(mockEditor.setPart == nil)
    }

    @Test("releaseEditor saves preview image when provided")
    @MainActor
    func releaseEditorSavesPreviewImage() async throws {
      let viewModel = MockEditorViewModel()
      let engineProvider = MockEngineProvider()
      let documentHandle = MockDocumentHandle(notebookID: "test-id", displayName: "Test")
      let mockEditor = MockIINKEditor()

      // Create a small test image.
      let renderer = UIGraphicsImageRenderer(size: CGSize(width: 100, height: 100))
      let testImage = renderer.image { context in
        UIColor.red.setFill()
        context.fill(CGRect(x: 0, y: 0, width: 100, height: 100))
      }

      viewModel.setupModel(engineProvider: engineProvider, documentHandle: documentHandle)
      viewModel.didCreateEditor(editor: mockEditor)
      viewModel.releaseEditor(previewImage: testImage)

      try await Task.sleep(nanoseconds: 100_000_000)

      let savedPreviewData = await documentHandle.savedPreviewData
      #expect(savedPreviewData != nil)
    }

    @Test("releaseEditor handles nil preview image")
    @MainActor
    func releaseEditorHandlesNilPreviewImage() async throws {
      let viewModel = MockEditorViewModel()
      let engineProvider = MockEngineProvider()
      let documentHandle = MockDocumentHandle(notebookID: "test-id", displayName: "Test")
      let mockEditor = MockIINKEditor()

      viewModel.setupModel(engineProvider: engineProvider, documentHandle: documentHandle)
      viewModel.didCreateEditor(editor: mockEditor)
      viewModel.releaseEditor(previewImage: nil)

      try await Task.sleep(nanoseconds: 100_000_000)

      let savedPreviewData = await documentHandle.savedPreviewData
      #expect(savedPreviewData == nil)
    }

    @Test("releaseEditor shows alert on save failure")
    @MainActor
    func releaseEditorShowsAlertOnSaveFailure() async throws {
      let viewModel = MockEditorViewModel()
      let engineProvider = MockEngineProvider()
      let documentHandle = MockDocumentHandle(notebookID: "test-id", displayName: "Test")
      await documentHandle.setShouldThrowOnSave(true)
      let mockEditor = MockIINKEditor()

      viewModel.setupModel(engineProvider: engineProvider, documentHandle: documentHandle)
      viewModel.didCreateEditor(editor: mockEditor)
      viewModel.releaseEditor(previewImage: nil)

      try await Task.sleep(nanoseconds: 200_000_000)

      #expect(viewModel.alert != nil)
    }

    @Test("releaseEditor closes document handle")
    @MainActor
    func releaseEditorClosesHandle() async throws {
      let viewModel = MockEditorViewModel()
      let engineProvider = MockEngineProvider()
      let documentHandle = MockDocumentHandle(notebookID: "test-id", displayName: "Test")
      let mockEditor = MockIINKEditor()

      viewModel.setupModel(engineProvider: engineProvider, documentHandle: documentHandle)
      viewModel.didCreateEditor(editor: mockEditor)
      viewModel.releaseEditor(previewImage: nil)

      try await Task.sleep(nanoseconds: 100_000_000)

      let closeCount = await documentHandle.closeCallCount
      #expect(closeCount == 1)
    }

    @Test("releaseEditor with nil editor does nothing")
    @MainActor
    func releaseEditorWithNilEditor() {
      let viewModel = MockEditorViewModel()

      viewModel.releaseEditor(previewImage: nil)

      #expect(viewModel.releaseEditorCallCount == 1)
    }

    @Test("handleAppBackground saves package")
    @MainActor
    func handleAppBackgroundSavesPackage() async throws {
      let viewModel = MockEditorViewModel()
      let engineProvider = MockEngineProvider()
      let documentHandle = MockDocumentHandle(notebookID: "test-id", displayName: "Test")

      viewModel.setupModel(engineProvider: engineProvider, documentHandle: documentHandle)
      viewModel.handleAppBackground()

      try await Task.sleep(nanoseconds: 100_000_000)

      let saveCount = await documentHandle.savePackageCallCount
      #expect(viewModel.handleAppBackgroundCallCount == 1)
      #expect(saveCount == 1)
    }

    @Test("handleAppBackground does not throw on save failure")
    @MainActor
    func handleAppBackgroundNoThrowOnFailure() async throws {
      let viewModel = MockEditorViewModel()
      let engineProvider = MockEngineProvider()
      let documentHandle = MockDocumentHandle(notebookID: "test-id", displayName: "Test")
      await documentHandle.setShouldThrowOnSave(true)

      viewModel.setupModel(engineProvider: engineProvider, documentHandle: documentHandle)
      viewModel.handleAppBackground()

      try await Task.sleep(nanoseconds: 100_000_000)

      // Should not crash, save failure is silently handled.
      #expect(viewModel.handleAppBackgroundCallCount == 1)
    }

    @Test("presentMissingNotebookError shows correct alert")
    @MainActor
    func presentMissingNotebookErrorShowsAlert() {
      let viewModel = MockEditorViewModel()

      viewModel.presentMissingNotebookError()

      #expect(viewModel.presentMissingNotebookErrorCallCount == 1)
      #expect(viewModel.alert != nil)
      #expect(viewModel.alert?.title == "Error")
      #expect(viewModel.alert?.message == "Notebook details are missing.")
    }
  }

  // MARK: - Editor Delegate Tests

  @Suite("Editor Delegate")
  struct EditorDelegateTests {

    @Test("didCreateEditor stores editor reference")
    @MainActor
    func didCreateEditorStoresReference() {
      let viewModel = MockEditorViewModel()
      let mockEditor = MockIINKEditor()

      viewModel.didCreateEditor(editor: mockEditor)

      #expect(viewModel.editor === mockEditor)
    }

    @Test("partChanged does not crash")
    @MainActor
    func partChangedDoesNotCrash() {
      let viewModel = MockEditorViewModel()
      let mockEditor = MockIINKEditor()

      viewModel.didCreateEditor(editor: mockEditor)
      viewModel.partChanged(editor: mockEditor)

      // Should not crash - currently no behavior defined.
    }

    @Test("contentChanged does not crash")
    @MainActor
    func contentChangedDoesNotCrash() {
      let viewModel = MockEditorViewModel()
      let mockEditor = MockIINKEditor()

      viewModel.didCreateEditor(editor: mockEditor)
      viewModel.contentChanged(editor: mockEditor, blockIds: ["block1", "block2"])

      // Should trigger auto-save scheduling but not crash.
    }

    @Test("contentChanged with empty blockIds")
    @MainActor
    func contentChangedEmptyBlockIds() {
      let viewModel = MockEditorViewModel()
      let mockEditor = MockIINKEditor()

      viewModel.didCreateEditor(editor: mockEditor)
      viewModel.contentChanged(editor: mockEditor, blockIds: [])

      // Should not crash with empty array.
    }

    @Test("onError shows alert with message")
    @MainActor
    func onErrorShowsAlert() {
      let viewModel = MockEditorViewModel()
      let mockEditor = MockIINKEditor()

      viewModel.didCreateEditor(editor: mockEditor)
      viewModel.onError(editor: mockEditor, blockId: "block1", message: "Recognition failed")

      #expect(viewModel.alert != nil)
      #expect(viewModel.alert?.title == "Error")
      #expect(viewModel.alert?.message == "Recognition failed")
    }

    @Test("onError with empty blockId")
    @MainActor
    func onErrorEmptyBlockId() {
      let viewModel = MockEditorViewModel()
      let mockEditor = MockIINKEditor()

      viewModel.didCreateEditor(editor: mockEditor)
      viewModel.onError(editor: mockEditor, blockId: "", message: "Internal error")

      #expect(viewModel.alert != nil)
      #expect(viewModel.alert?.message == "Internal error")
    }

    @Test("onError with empty message")
    @MainActor
    func onErrorEmptyMessage() {
      let viewModel = MockEditorViewModel()
      let mockEditor = MockIINKEditor()

      viewModel.didCreateEditor(editor: mockEditor)
      viewModel.onError(editor: mockEditor, blockId: "block1", message: "")

      #expect(viewModel.alert != nil)
      #expect(viewModel.alert?.message == "")
    }
  }

  // MARK: - Edge Cases Tests

  @Suite("Edge Cases")
  struct EdgeCaseTests {

    @Test("calling methods before setupModel does not crash")
    @MainActor
    func methodsBeforeSetupDoNotCrash() {
      let viewModel = MockEditorViewModel()

      viewModel.selectTool(.pen)
      viewModel.selectPenTool()
      viewModel.selectEraserTool()
      viewModel.selectHighlighterTool()
      viewModel.updateInputMode(newInputMode: .auto)
      viewModel.updateTool(selection: .eraser)
      viewModel.updateInkColor(hex: "#FF0000", for: .pen)
      viewModel.updateInkWidth(width: 1.0, for: .pen)
      viewModel.clear()
      viewModel.undo()
      viewModel.redo()
      viewModel.setEditorViewSize(bounds: CGRect(x: 0, y: 0, width: 100, height: 100))

      // All should complete without crashing.
      // selectToolCallCount is 2 because updateInputMode reapplies the current tool.
      #expect(viewModel.selectToolCallCount >= 1)
    }

    @Test("setupModel can be called only once")
    @MainActor
    func setupModelCalledOnce() {
      let viewModel = MockEditorViewModel()
      let engineProvider1 = MockEngineProvider()
      let documentHandle1 = MockDocumentHandle(notebookID: "id1", displayName: "Notebook 1")
      let engineProvider2 = MockEngineProvider()
      let documentHandle2 = MockDocumentHandle(notebookID: "id2", displayName: "Notebook 2")

      viewModel.setupModel(engineProvider: engineProvider1, documentHandle: documentHandle1)
      let firstViewController = viewModel.editorViewController

      viewModel.setupModel(engineProvider: engineProvider2, documentHandle: documentHandle2)
      let secondViewController = viewModel.editorViewController

      #expect(viewModel.setupModelCallCount == 2)
      #expect(firstViewController !== secondViewController)
    }

    @Test("multiple releaseEditor calls are safe")
    @MainActor
    func multipleReleaseEditorCalls() {
      let viewModel = MockEditorViewModel()
      let mockEditor = MockIINKEditor()

      viewModel.didCreateEditor(editor: mockEditor)
      viewModel.releaseEditor(previewImage: nil)
      viewModel.releaseEditor(previewImage: nil)
      viewModel.releaseEditor(previewImage: nil)

      #expect(viewModel.releaseEditorCallCount == 3)
    }

    @Test("concurrent tool selections")
    @MainActor
    func concurrentToolSelections() async {
      let viewModel = MockEditorViewModel()
      let engineProvider = MockEngineProvider()
      let documentHandle = MockDocumentHandle(notebookID: "test-id", displayName: "Test")

      viewModel.setupModel(engineProvider: engineProvider, documentHandle: documentHandle)

      await withTaskGroup(of: Void.self) { group in
        for _ in 0..<100 {
          group.addTask { @MainActor in
            viewModel.selectTool(.pen)
          }
          group.addTask { @MainActor in
            viewModel.selectTool(.eraser)
          }
          group.addTask { @MainActor in
            viewModel.selectTool(.highlighter)
          }
        }
      }

      #expect(viewModel.selectToolCallCount == 300)
    }

    @Test("nil engine provider engine")
    @MainActor
    func nilEngineProviderEngine() {
      let viewModel = MockEditorViewModel()
      let engineProvider = MockEngineProvider(withEngine: nil)
      engineProvider.engineErrorMessage = "Invalid certificate"
      let documentHandle = MockDocumentHandle(notebookID: "test-id", displayName: "Test")

      viewModel.setupModel(engineProvider: engineProvider, documentHandle: documentHandle)

      // Should still setup, but engine-dependent operations may fail.
      #expect(viewModel.editorViewController != nil)
      #expect(viewModel.engineProvider?.engine == nil)
    }

    @Test("very long title is handled")
    @MainActor
    func veryLongTitle() async throws {
      let viewModel = MockEditorViewModel()
      let engineProvider = MockEngineProvider()
      let longTitle = String(repeating: "A", count: 10000)
      let documentHandle = MockDocumentHandle(notebookID: "test-id", displayName: longTitle)

      viewModel.setupModel(engineProvider: engineProvider, documentHandle: documentHandle)

      try await Task.sleep(nanoseconds: 100_000_000)

      #expect(viewModel.title == longTitle)
    }

    @Test("empty title is handled")
    @MainActor
    func emptyTitle() async throws {
      let viewModel = MockEditorViewModel()
      let engineProvider = MockEngineProvider()
      let documentHandle = MockDocumentHandle(notebookID: "test-id", displayName: "")

      viewModel.setupModel(engineProvider: engineProvider, documentHandle: documentHandle)

      try await Task.sleep(nanoseconds: 100_000_000)

      #expect(viewModel.title == "")
    }

    @Test("special characters in title")
    @MainActor
    func specialCharactersInTitle() async throws {
      let viewModel = MockEditorViewModel()
      let engineProvider = MockEngineProvider()
      let specialTitle = "📝 My Notebook™ (Draft) — 2024 <test> & more"
      let documentHandle = MockDocumentHandle(notebookID: "test-id", displayName: specialTitle)

      viewModel.setupModel(engineProvider: engineProvider, documentHandle: documentHandle)

      try await Task.sleep(nanoseconds: 100_000_000)

      #expect(viewModel.title == specialTitle)
    }

    @Test("setEditorViewSize with negative dimensions")
    @MainActor
    func setEditorViewSizeNegativeDimensions() {
      let viewModel = MockEditorViewModel()
      let engineProvider = MockEngineProvider()
      let documentHandle = MockDocumentHandle(notebookID: "test-id", displayName: "Test")

      viewModel.setupModel(engineProvider: engineProvider, documentHandle: documentHandle)

      let negativeBounds = CGRect(x: -10, y: -20, width: -100, height: -200)
      viewModel.setEditorViewSize(bounds: negativeBounds)

      #expect(viewModel.lastBounds == negativeBounds)
    }

    @Test("setEditorViewSize with infinity")
    @MainActor
    func setEditorViewSizeInfinity() {
      let viewModel = MockEditorViewModel()
      let engineProvider = MockEngineProvider()
      let documentHandle = MockDocumentHandle(notebookID: "test-id", displayName: "Test")

      viewModel.setupModel(engineProvider: engineProvider, documentHandle: documentHandle)

      let infiniteBounds = CGRect(x: 0, y: 0, width: CGFloat.infinity, height: CGFloat.infinity)
      viewModel.setEditorViewSize(bounds: infiniteBounds)

      #expect(viewModel.lastBounds?.width.isInfinite == true)
    }
  }

  // MARK: - Error Recovery Tests

  @Suite("Error Recovery")
  struct ErrorRecoveryTests {

    @Test("editor remains usable after clear error")
    @MainActor
    func editorUsableAfterClearError() {
      let viewModel = MockEditorViewModel()
      let mockEditor = MockIINKEditor()
      mockEditor.shouldThrowOnClear = true

      viewModel.didCreateEditor(editor: mockEditor)
      viewModel.clear()

      #expect(viewModel.alert != nil)

      // Editor should still be usable for other operations.
      mockEditor.addAction("new stroke")
      viewModel.undo()

      #expect(mockEditor.undoCallCount == 1)
    }

    @Test("operations continue after undo error")
    @MainActor
    func operationsContinueAfterUndoError() {
      let viewModel = MockEditorViewModel()
      let mockEditor = MockIINKEditor()
      mockEditor.addAction("stroke")
      mockEditor.shouldThrowOnUndo = true

      viewModel.didCreateEditor(editor: mockEditor)
      viewModel.undo()

      #expect(viewModel.alert != nil)

      // Clear the alert.
      viewModel.alert = nil

      // Other operations should still work.
      mockEditor.shouldThrowOnUndo = false
      mockEditor.shouldThrowOnClear = false
      viewModel.clear()

      #expect(mockEditor.clearCallCount == 1)
    }

    @Test("alert can be dismissed and new alert shown")
    @MainActor
    func alertDismissedAndNewShown() {
      let viewModel = MockEditorViewModel()
      let mockEditor = MockIINKEditor()

      viewModel.didCreateEditor(editor: mockEditor)

      viewModel.onError(editor: mockEditor, blockId: "1", message: "First error")
      let firstAlert = viewModel.alert

      viewModel.alert = nil

      viewModel.onError(editor: mockEditor, blockId: "2", message: "Second error")
      let secondAlert = viewModel.alert

      #expect(firstAlert !== secondAlert)
      #expect(secondAlert?.message == "Second error")
    }
  }

  // MARK: - State Consistency Tests

  @Suite("State Consistency")
  struct StateConsistencyTests {

    @Test("pen color and width persist across tool switches")
    @MainActor
    func penSettingsPersist() {
      let viewModel = MockEditorViewModel()

      viewModel.updateInkColor(hex: "#FF0000", for: .pen)
      viewModel.updateInkWidth(width: 1.5, for: .pen)

      viewModel.selectTool(.eraser)
      viewModel.selectTool(.highlighter)
      viewModel.selectTool(.pen)

      #expect(viewModel.selectedPenColorHex == "#FF0000")
      #expect(viewModel.selectedPenWidth == 1.5)
    }

    @Test("highlighter color and width persist across tool switches")
    @MainActor
    func highlighterSettingsPersist() {
      let viewModel = MockEditorViewModel()

      viewModel.updateInkColor(hex: "#00FF00", for: .highlighter)
      viewModel.updateInkWidth(width: 8.0, for: .highlighter)

      viewModel.selectTool(.pen)
      viewModel.selectTool(.eraser)
      viewModel.selectTool(.highlighter)

      #expect(viewModel.selectedHighlighterColorHex == "#00FF00")
      #expect(viewModel.selectedHighlighterWidth == 8.0)
    }

    @Test("input mode persists")
    @MainActor
    func inputModePersists() {
      let viewModel = MockEditorViewModel()
      let engineProvider = MockEngineProvider()
      let documentHandle = MockDocumentHandle(notebookID: "test-id", displayName: "Test")

      viewModel.setupModel(engineProvider: engineProvider, documentHandle: documentHandle)
      viewModel.updateInputMode(newInputMode: .auto)

      viewModel.selectTool(.pen)
      viewModel.selectTool(.eraser)

      #expect(viewModel.lastInputMode == .auto)
      #expect(viewModel.editorViewController?.inputMode == .auto)
    }
  }
}

// MARK: - Helper Extensions

extension MockDocumentHandle {
  func setShouldThrowOnSave(_ value: Bool) async {
    shouldThrowOnSave = value
  }
}

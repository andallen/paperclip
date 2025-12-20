import Combine
import PencilKit
import SwiftUI

// Controller that manages ink persistence operations.
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////?/// Implements a commit policy: working ink stays in memory while drawing,
// then commits as a new InkItem after a brief pause.
@MainActor
class InkPersistenceController: ObservableObject {
  // The combined drawing to display on the canvas (committed + working ink).
  // This is bound to PKCanvasView and updated when the user draws.
  @Published var drawing: PKDrawing = PKDrawing()

  // True while a save operation is in progress.
  @Published var isSaving: Bool = false

  // The document handle used for file operations.
  private let documentHandle: DocumentHandle

  // The notebook model with ink item metadata.
  private let model: NotebookModel

  // Number of strokes that have been committed (saved to disk).
  // Used to track which strokes in the current drawing are "working" vs "committed".
  private var committedStrokeCount: Int = 0

  // Task used to detect pause and commit working ink.
  private var commitTask: Task<Void, Never>?

  // Delay before committing working ink after the last drawing change.
  private let commitDebounceDelay: TimeInterval = 0.5

  init(documentHandle: DocumentHandle, model: NotebookModel) {
    self.documentHandle = documentHandle
    self.model = model
  }

  // Loads all ink items from disk and combines them into the drawing.
  func loadInk() async {
    // Load all ink items from the manifest.
    let itemIDs = model.inkItems.map { $0.id }
    guard !itemIDs.isEmpty else {
      // No items to load, start with empty drawing.
      drawing = PKDrawing()
      committedStrokeCount = 0
      // print("📂 LOADING: No ink items found, starting with empty canvas")
      return
    }

    // print("📂 LOADING: Loading \(itemIDs.count) InkItem file(s) from disk...")

    // Load all payloads on a background thread.
    let payloads = await Task.detached { [documentHandle] in
      await documentHandle.loadInkPayloads(for: itemIDs)
    }.value

    // Combine all loaded drawings into one drawing.
    var combined = PKDrawing()
    for payload in payloads {
      do {
        let loadedDrawing = try PKDrawing(data: payload.payload)
        // Append all strokes from this drawing to the combined drawing.
        for stroke in loadedDrawing.strokes {
          combined.strokes.append(stroke)
        }
      } catch {
        // Skip items that cannot be decoded. Continue loading others.
        continue
      }
    }

    drawing = combined
    committedStrokeCount = combined.strokes.count
    // print("✅ LOADED: Combined \(payloads.count) file(s) into \(combined.strokes.count) total stroke(s)")
  }

  // Called when the drawing changes. Schedules commit of working ink after pause.
  func drawingDidChange(_ newDrawing: PKDrawing) {
    // Update the drawing to reflect the current state.
    drawing = newDrawing

    // Cancel any pending commit task.
    commitTask?.cancel()

    // Schedule a commit after the debounce delay.
    commitTask = Task { [weak self] in
      guard let self = self else { return }

      // Wait for the debounce delay.
      try? await Task.sleep(nanoseconds: UInt64(commitDebounceDelay * 1_000_000_000))

      // Check if this task was cancelled during the delay.
      if Task.isCancelled { return }

      // Commit the working ink as a new item.
      await self.commitWorkingInk()
    }
  }

  // Commits the current working ink as a new InkItem.
  // Working ink is determined by strokes added since the last commit.
  // Writes the payload file and atomically updates the manifest.
  private func commitWorkingInk() async {
    // Capture the current state atomically to avoid races with ongoing drawing.
    let snapshotCommittedCount = committedStrokeCount
    let snapshotCurrentCount = drawing.strokes.count
    let workingStrokeCount = snapshotCurrentCount - snapshotCommittedCount

    // Skip committing if there's no new working ink.
    guard workingStrokeCount > 0 else { return }

    // print("💾 COMMITTING: Saving \(workingStrokeCount) new stroke(s) as a new InkItem...")

    isSaving = true
    defer { isSaving = false }

    // Extract the working ink (strokes added since last commit).
    // We capture the strokes at commit time, even if more strokes are added during save.
    var workingDrawing = PKDrawing()
    let workingStrokes = Array(drawing.strokes[snapshotCommittedCount..<snapshotCurrentCount])
    for stroke in workingStrokes {
      workingDrawing.strokes.append(stroke)
    }

    // Skip committing empty drawings.
    guard !workingDrawing.strokes.isEmpty else { return }

    // Generate a unique ID for this new ink item.
    let itemID = UUID().uuidString

    // Serialize the working drawing to data.
    let drawingData = workingDrawing.dataRepresentation()

    // Compute the bounding rectangle for the working ink.
    let bounds = workingDrawing.bounds
    let rectangle = InkRectangle(from: bounds)

    // Create the save request.
    let saveRequest = InkItemSaveRequest(
      id: itemID,
      rectangle: rectangle,
      payload: drawingData
    )

    // Perform the save on a background thread through the actor.
    do {
      try await Task.detached { [documentHandle, saveRequest] in
        try await documentHandle.saveInkItems([saveRequest])
      }.value

      // After successful save, update committed stroke count to the snapshot value.
      // Any strokes added during the commit will be committed on the next pause.
      committedStrokeCount = snapshotCurrentCount
      // print("✅ COMMIT SUCCESS: InkItem saved! Total committed strokes: \(committedStrokeCount)")
    } catch {
      // Save failed. Keep working ink in memory so user doesn't lose it.
      // The commit will be retried on the next pause or on saveImmediately.
      // print("❌ COMMIT FAILED: \(error.localizedDescription)")
    }
  }

  // Forces an immediate commit of any working ink. Called when the view is about to disappear.
  func saveImmediately() async {
    // Cancel any pending commit task.
    commitTask?.cancel()

    // Commit immediately if there is working ink.
    await commitWorkingInk()
  }
}


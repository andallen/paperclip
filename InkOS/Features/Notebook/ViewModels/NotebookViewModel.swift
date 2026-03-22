//
// NoteViewModel.swift
// InkOS
//
// State management for a single note canvas.
// Handles drawing state, auto-save, and clipboard send.
//

import PencilKit
import SwiftUI

// MARK: - NoteViewModel

// Observable state for the note canvas.
@MainActor @Observable
final class NoteViewModel {
  // Current PencilKit drawing.
  var drawing = PKDrawing()

  // Current note data (nil if no note loaded).
  var noteData: NoteData?

  // Whether a send-to-clipboard operation just succeeded.
  var showSentToast = false

  // Error message for display.
  var errorMessage: String?

  // Reference to persistence service.
  private var noteService: NoteService?

  // Auto-save debounce task.
  private var saveTask: Task<Void, Never>?

  init() {}

  // MARK: - Note Lifecycle

  // Loads a note from saved data.
  func loadNote(_ data: NoteData, service: NoteService) {
    noteService = service
    noteData = data

    // Deserialize drawing from saved data.
    if !data.drawingData.isEmpty,
       let restored = try? PKDrawing(data: data.drawingData) {
      drawing = restored
    } else {
      drawing = PKDrawing()
    }
  }

  // Creates a fresh empty note.
  func loadEmpty(service: NoteService) {
    noteService = service
    noteData = nil
    drawing = PKDrawing()
  }

  // Called when the drawing changes (from the canvas delegate).
  func drawingDidChange() {
    scheduleSave()
  }

  // Clears the canvas.
  func clearCanvas() {
    drawing = PKDrawing()
    scheduleSave()
  }

  // MARK: - Auto-save

  // Debounced save: waits 2 seconds after last change.
  private func scheduleSave() {
    saveTask?.cancel()
    saveTask = Task { [weak self] in
      try? await Task.sleep(for: .seconds(2))
      guard !Task.isCancelled else { return }
      await self?.saveNow()
    }
  }

  // Saves the current drawing to disk immediately.
  func saveNow() {
    guard var note = noteData, let service = noteService else { return }

    // Serialize drawing.
    note.drawingData = drawing.dataRepresentation()
    note.metadata.updatedAt = Date()

    // Generate thumbnail.
    if !drawing.strokes.isEmpty {
      let bounds = drawing.bounds
      let image = drawing.image(from: bounds, scale: 1.0)
      note.thumbnailData = image.pngData()
    } else {
      note.thumbnailData = nil
    }

    noteData = note
    service.saveNote(note)
  }
}

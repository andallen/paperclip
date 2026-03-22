//
// NoteModel.swift
// InkOS
//
// Data model for a single note (drawing page).
// Each note stores a PencilKit drawing as binary data
// and an optional thumbnail for sidebar display.
//

import Foundation

// MARK: - NoteMetadata

// Lightweight note info for sidebar display.
struct NoteMetadata: Identifiable, Codable, Sendable {
  let id: String
  var title: String
  var updatedAt: Date
  let createdAt: Date

  init(
    id: String = UUID().uuidString,
    title: String,
    updatedAt: Date = Date(),
    createdAt: Date = Date()
  ) {
    self.id = id
    self.title = title
    self.updatedAt = updatedAt
    self.createdAt = createdAt
  }
}

// MARK: - NoteData

// Full note data including the PencilKit drawing serialized as binary.
struct NoteData: Codable, Sendable {
  var metadata: NoteMetadata

  // PKDrawing.dataRepresentation() stored as base64 in JSON.
  var drawingData: Data

  // Small PNG thumbnail for sidebar preview.
  var thumbnailData: Data?

  init(
    metadata: NoteMetadata,
    drawingData: Data = Data(),
    thumbnailData: Data? = nil
  ) {
    self.metadata = metadata
    self.drawingData = drawingData
    self.thumbnailData = thumbnailData
  }
}

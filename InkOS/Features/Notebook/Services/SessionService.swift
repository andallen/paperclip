//
// NoteService.swift
// InkOS
//
// Manages note lifecycle: create, list, load, save, delete.
// Notes are persisted locally using JSON files in the app's documents directory.
//

import Foundation

// MARK: - NoteService

// Manages note persistence using local JSON files.
@MainActor
@Observable
final class NoteService {
  // All note metadata for sidebar display.
  var notes: [NoteMetadata] = []

  // Directory for note storage.
  private let storageDirectory: URL

  private let encoder: JSONEncoder = {
    let e = JSONEncoder()
    e.dateEncodingStrategy = .iso8601
    e.outputFormatting = [.prettyPrinted]
    return e
  }()

  private let decoder: JSONDecoder = {
    let d = JSONDecoder()
    d.dateDecodingStrategy = .iso8601
    return d
  }()

  init() {
    let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    storageDirectory = docs.appendingPathComponent("notes", isDirectory: true)

    // Create directory if needed.
    try? FileManager.default.createDirectory(at: storageDirectory, withIntermediateDirectories: true)

    // Load notes on init.
    loadNoteList()
  }

  // MARK: - Note CRUD

  // Creates a new empty note and returns its data.
  func createNote(title: String) -> NoteData {
    let metadata = NoteMetadata(title: title)
    let noteData = NoteData(metadata: metadata)

    // Save to disk.
    saveNote(noteData)

    // Update list.
    notes.insert(metadata, at: 0)

    return noteData
  }

  // Loads full note data for a given note ID.
  func loadNote(id: String) -> NoteData? {
    let fileURL = storageDirectory.appendingPathComponent("\(id).json")
    guard let data = try? Data(contentsOf: fileURL) else { return nil }
    return try? decoder.decode(NoteData.self, from: data)
  }

  // Saves note data to disk and updates the note list.
  func saveNote(_ note: NoteData) {
    let fileURL = storageDirectory.appendingPathComponent("\(note.metadata.id).json")
    guard let data = try? encoder.encode(note) else { return }
    try? data.write(to: fileURL)

    // Update metadata in list.
    if let index = notes.firstIndex(where: { $0.id == note.metadata.id }) {
      notes[index] = note.metadata
    }
  }

  // Renames a note.
  func renameNote(id: String, newTitle: String) {
    guard var noteData = loadNote(id: id) else { return }
    noteData.metadata.title = newTitle
    saveNote(noteData)
  }

  // Deletes a note.
  func deleteNote(id: String) {
    let fileURL = storageDirectory.appendingPathComponent("\(id).json")
    try? FileManager.default.removeItem(at: fileURL)
    notes.removeAll { $0.id == id }
  }

  // MARK: - Note List

  // Loads the note list from disk.
  private func loadNoteList() {
    guard let files = try? FileManager.default.contentsOfDirectory(
      at: storageDirectory,
      includingPropertiesForKeys: [.contentModificationDateKey],
      options: [.skipsHiddenFiles]
    ) else { return }

    var loaded: [NoteMetadata] = []
    for file in files where file.pathExtension == "json" {
      guard let data = try? Data(contentsOf: file),
            let note = try? decoder.decode(NoteData.self, from: data) else { continue }
      loaded.append(note.metadata)
    }

    // Sort by most recently updated.
    notes = loaded.sorted { $0.updatedAt > $1.updatedAt }
  }

  // Refreshes the note list from disk.
  func refreshNotes() {
    loadNoteList()
  }
}

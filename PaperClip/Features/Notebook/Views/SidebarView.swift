//
// SidebarView.swift
// PaperClip
//
// Floating sidebar for note management.
// Shows note list with search, compose button, and hamburger close.
// Long-press on notes for rename/delete context menu.
//

import SwiftUI

// MARK: - SidebarView

// Sidebar overlay for browsing and managing notes.
struct SidebarView: View {
  @Bindable var noteService: NoteService
  @Binding var isPresented: Bool
  var activeNoteId: String?

  // Callbacks.
  var onSelectNote: ((NoteData) -> Void)?
  var onNewNote: (() -> Void)?

  @State private var searchText = ""
  @FocusState private var searchFocused: Bool

  // Rename state for context menu.
  @State private var renamingNote: NoteMetadata?
  @State private var renameText = ""

  // Delete confirmation state.
  @State private var deletingNote: NoteMetadata?

  // Notes filtered by search query.
  private var filteredNotes: [NoteMetadata] {
    if searchText.isEmpty {
      return noteService.notes
    }
    let query = searchText.lowercased()
    return noteService.notes.filter {
      $0.title.lowercased().contains(query)
    }
  }

  var body: some View {
    VStack(spacing: 0) {
      // Top row: search, compose, and hamburger close.
      topBar

      // Note list.
      ScrollView {
        LazyVStack(spacing: 2) {
          ForEach(filteredNotes) { note in
            noteRow(note)
          }
        }
        .padding(.horizontal, 8)
      }

      Spacer(minLength: 0)
    }
    .frame(maxHeight: .infinity)
    .accessibilityIdentifier("sidebar_view")
    .onChange(of: isPresented) { _, newValue in
      if !newValue { searchFocused = false }
    }
    .alert("Rename Note", isPresented: .init(
      get: { renamingNote != nil },
      set: { if !$0 { renamingNote = nil } }
    )) {
      TextField("Note name", text: $renameText)
      Button("Cancel", role: .cancel) { renamingNote = nil }
      Button("Rename") {
        if let note = renamingNote, !renameText.isEmpty {
          noteService.renameNote(id: note.id, newTitle: renameText)
        }
        renamingNote = nil
      }
    } message: {
      Text("Enter a new name for this note.")
    }
    .alert("Delete Note", isPresented: .init(
      get: { deletingNote != nil },
      set: { if !$0 { deletingNote = nil } }
    )) {
      Button("Cancel", role: .cancel) { deletingNote = nil }
      Button("Delete", role: .destructive) {
        if let note = deletingNote {
          noteService.deleteNote(id: note.id)
        }
        deletingNote = nil
      }
    } message: {
      Text("Are you sure you want to delete this note? This cannot be undone.")
    }
  }

  // MARK: - Top Bar

  private var topBar: some View {
    HStack(spacing: 10) {
      searchField

      // New note.
      Button(action: {
        searchFocused = false
        onNewNote?()
      }) {
        Image(systemName: "square.and.pencil")
          .font(.system(size: 18, weight: .medium))
          .foregroundColor(NotebookPalette.ink)
          .frame(width: 32, height: 32)
      }
      .accessibilityIdentifier("sidebar_new_note_button")

      // Close sidebar.
      Button(action: {
        searchFocused = false
        withAnimation(.easeInOut(duration: 0.25)) { isPresented = false }
      }) {
        VStack(alignment: .leading, spacing: 5) {
          RoundedRectangle(cornerRadius: 1.5)
            .fill(NotebookPalette.ink)
            .frame(width: 22, height: 2.5)
          RoundedRectangle(cornerRadius: 1.5)
            .fill(NotebookPalette.ink)
            .frame(width: 16, height: 2.5)
        }
        .frame(width: 32, height: 32)
      }
      .accessibilityIdentifier("sidebar_hamburger_close")
    }
    .padding(.horizontal, 14)
    .padding(.top, 14)
    .padding(.bottom, 10)
  }

  // MARK: - Search Field

  private var searchField: some View {
    HStack(spacing: 8) {
      Image(systemName: "magnifyingglass")
        .font(.system(size: 14))
        .foregroundColor(NotebookPalette.inkFaint)

      TextField("Search", text: $searchText)
        .font(NotebookTypography.body)
        .foregroundColor(NotebookPalette.ink)
        .focused($searchFocused)
        .accessibilityIdentifier("sidebar_search_field")
    }
    .padding(.horizontal, 12)
    .padding(.vertical, 8)
    .background(
      Capsule()
        .fill(Color.gray.opacity(0.06))
    )
    .overlay(
      Capsule()
        .stroke(NotebookPalette.inkFaint.opacity(0.2), lineWidth: 1)
    )
  }

  // MARK: - Note Row

  private func noteRow(_ note: NoteMetadata) -> some View {
    HStack {
      Text(note.title)
        .font(NotebookTypography.body)
        .foregroundColor(NotebookPalette.ink)
        .lineLimit(1)

      Spacer()
    }
    .padding(.horizontal, 12)
    .padding(.vertical, 10)
    .contentShape(Rectangle())
    .background(
      RoundedRectangle(cornerRadius: 8)
        .fill(
          activeNoteId == note.id
            ? NotebookPalette.ink.opacity(0.06)
            : Color.clear
        )
    )
    .onTapGesture {
      // Tap to select and open the note.
      searchFocused = false
      if let data = noteService.loadNote(id: note.id) {
        onSelectNote?(data)
      }
    }
    .accessibilityIdentifier("sidebar_note_row_\(note.id)")
    .contextMenu {
      // Long-press context menu for rename and delete.
      Button {
        renameText = note.title
        renamingNote = note
      } label: {
        Label("Rename", systemImage: "pencil")
      }
      Button(role: .destructive) {
        deletingNote = note
      } label: {
        Label("Delete", systemImage: "trash")
      }
    }
  }

}

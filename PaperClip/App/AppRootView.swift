//
// AppRootView.swift
// PaperClip
//
// Root view that owns shared services and presents the main canvas.
// Manages sidebar visibility and note switching.
//

import SwiftUI

struct AppRootView: View {
  @State private var noteService = NoteService()
  @State private var viewModel = NoteViewModel()
  @State private var transferService = TransferService()
  @State private var showSidebar = false

  // Whether the PencilKit tool picker is visible.
  @State private var showToolPicker = true

  // Whether the clear canvas confirmation alert is showing.
  @State private var showClearConfirmation = false

  // Sidebar width.
  private let sidebarWidth: CGFloat = 340

  var body: some View {
    ZStack(alignment: .topLeading) {
      // Full-screen paper background covering all safe areas and any layout gaps.
      NotebookPalette.paper
        .ignoresSafeArea()

      // Main canvas (ignores container safe area for edge-to-edge paper).
      NoteCanvasView(viewModel: viewModel, showToolPicker: $showToolPicker, transferService: transferService)
        .ignoresSafeArea(.container)

      // Hamburger menu button (top-left).
      hamburgerButton
        .padding(.top, 20)
        .padding(.leading, 20)
        .offset(x: showSidebar ? -80 : 0)
        .animation(.easeInOut(duration: 0.25), value: showSidebar)

      // Tools pill (top-right), aligned with hamburger button.
      toolsPill
        .padding(.top, 20)
        .padding(.trailing, 20)
        .frame(maxWidth: .infinity, alignment: .trailing)

      // Invisible dismiss layer (only when sidebar is open).
      if showSidebar {
        Color.clear
          .contentShape(Rectangle())
          .ignoresSafeArea()
          .onTapGesture {
            UIApplication.shared.sendAction(
              #selector(UIResponder.resignFirstResponder),
              to: nil, from: nil, for: nil
            )
            withAnimation(.easeInOut(duration: 0.25)) { showSidebar = false }
          }
      }

      // Sidebar panel.
      sidebarPanel
    }
    .onAppear {
      loadOrCreateNote()
      transferService.start()
    }
    .alert("Clear Canvas", isPresented: $showClearConfirmation) {
      Button("Clear", role: .destructive) { viewModel.clearCanvas() }
      Button("Cancel", role: .cancel) { }
    } message: {
      Text("Are you sure you want to clear the canvas? This cannot be undone.")
    }
  }

  // MARK: - Hamburger Button

  private var hamburgerButton: some View {
    Button {
      withAnimation(.easeInOut(duration: 0.25)) { showSidebar = true }
    } label: {
      VStack(alignment: .leading, spacing: 5) {
        RoundedRectangle(cornerRadius: 1.5)
          .fill(NotebookPalette.ink)
          .frame(width: 20, height: 2.5)
        RoundedRectangle(cornerRadius: 1.5)
          .fill(NotebookPalette.ink)
          .frame(width: 14, height: 2.5)
      }
      .frame(width: 44, height: 44)
    }
    .glassEffect(.regular.interactive(), in: .circle)
    .accessibilityLabel("Open sidebar")
    .accessibilityIdentifier("hamburger_open_button")
  }

  // MARK: - Tools Pill

  // Floating pill in the top-right with pencil toggle and clear buttons.
  private var toolsPill: some View {
    HStack(spacing: 0) {
      // Toggle native PKToolPicker visibility.
      Button(action: {
        showToolPicker.toggle()
      }) {
        Image(systemName: showToolPicker ? "pencil.tip.crop.circle.fill" : "pencil.tip.crop.circle")
          .font(.system(size: 20, weight: .medium))
          .foregroundColor(NotebookPalette.ink)
          .frame(width: 44, height: 44)
          .contentShape(Rectangle())
      }
      .accessibilityIdentifier("pencil_tool_button")

      // Clear canvas (with confirmation).
      Button(action: { showClearConfirmation = true }) {
        Image(systemName: "trash")
          .font(.system(size: 18, weight: .medium))
          .foregroundColor(NotebookPalette.ink)
          .frame(width: 44, height: 44)
          .contentShape(Rectangle())
      }
      .accessibilityIdentifier("clear_canvas_button")
    }
    .liquidGlassBackground(cornerRadius: 22)
  }

  // MARK: - Sidebar Panel

  private var sidebarPanel: some View {
    SidebarView(
      noteService: noteService,
      isPresented: $showSidebar,
      activeNoteId: viewModel.noteData?.metadata.id,
      onSelectNote: { noteData in
        switchToNote(noteData)
        withAnimation(.easeInOut(duration: 0.25)) { showSidebar = false }
      },
      onNewNote: {
        createNewNote()
        withAnimation(.easeInOut(duration: 0.25)) { showSidebar = false }
      },
    )
    .frame(width: sidebarWidth)
    .frame(maxHeight: .infinity)
    .background(
      RoundedRectangle(cornerRadius: 16)
        .fill(NotebookPalette.paper)
    )
    .clipShape(RoundedRectangle(cornerRadius: 16))
    .shadow(color: .black.opacity(0.15), radius: 12, x: 4, y: 0)
    .padding(.top, 12)
    .padding(.bottom, 12)
    .padding(.leading, 12)
    .offset(x: showSidebar ? 0 : -(sidebarWidth + 24))
    .animation(.easeInOut(duration: 0.25), value: showSidebar)
  }

  // MARK: - Note Management

  // Loads the most recent note or creates a new one.
  private func loadOrCreateNote() {
    if let first = noteService.notes.first,
       let data = noteService.loadNote(id: first.id) {
      viewModel.loadNote(data, service: noteService)
    } else {
      createNewNote()
    }
  }

  // Creates a new note with a default "Untitled" title.
  // If "Untitled" already exists, appends a number (e.g. "Untitled 2").
  private func createNewNote() {
    let existingTitles = Set(noteService.notes.map(\.title))
    var title = "Untitled"
    var counter = 2
    while existingTitles.contains(title) {
      title = "Untitled \(counter)"
      counter += 1
    }
    let note = noteService.createNote(title: title)
    viewModel.loadNote(note, service: noteService)
  }

  // Switches to an existing note.
  private func switchToNote(_ noteData: NoteData) {
    // Save current note before switching.
    viewModel.saveNow()
    viewModel.loadNote(noteData, service: noteService)
  }
}

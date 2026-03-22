//
// AppRootView.swift
// InkOS
//
// Root view that owns shared services and presents the main canvas.
// Manages sidebar visibility and note switching.
//

import SwiftUI

struct AppRootView: View {
  @State private var noteService = NoteService()
  @State private var viewModel = NoteViewModel()
  @State private var showSidebar = false
  @State private var showSettings = false

  // Sidebar width.
  private let sidebarWidth: CGFloat = 340

  var body: some View {
    ZStack(alignment: .topLeading) {
      // Main canvas (ignores container safe area for edge-to-edge paper).
      NoteCanvasView(viewModel: viewModel)
        .ignoresSafeArea(.container)

      // Hamburger menu button (top-left).
      hamburgerButton
        .padding(.top, 20)
        .padding(.leading, 20)
        .offset(x: showSidebar ? -80 : 0)
        .animation(.easeInOut(duration: 0.25), value: showSidebar)

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
    .onAppear { loadOrCreateNote() }
    .sheet(isPresented: $showSettings) {
      SettingsView()
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
      onOpenSettings: {
        withAnimation(.easeInOut(duration: 0.25)) { showSidebar = false }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
          showSettings = true
        }
      }
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

  // Creates a new note with today's date as the title.
  private func createNewNote() {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    let title = formatter.string(from: Date())
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

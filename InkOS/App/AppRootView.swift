import SwiftUI

// Root view that owns shared services and presents the main notebook UI.
// Manages sidebar visibility and session switching.
struct AppRootView: View {
  @State private var sessionService = SessionService()
  @State private var viewModel: NotebookViewModel
  @State private var showSidebar = false

  init() {
    let sessionService = SessionService()

    // Start with a fresh session. Existing sessions are accessible via the sidebar.
    let session = sessionService.createSession(title: "New Chat")
    _sessionService = State(initialValue: sessionService)
    _viewModel = State(initialValue: NotebookViewModel(
      document: session.document,
      sessionData: session,
      sessionService: sessionService
    ))
  }

  // Sidebar width.
  private let sidebarWidth: CGFloat = 340

  var body: some View {
    ZStack(alignment: .topLeading) {
      // Main notebook canvas (ignores safe area for edge-to-edge paper).
      NotebookCanvasView(viewModel: viewModel)
        .ignoresSafeArea()

      // Hamburger menu button (top-left, respects safe area).
      if !showSidebar {
        hamburgerButton
          .padding(.top, 20)
          .padding(.leading, 20)
      }

      // Invisible dismiss layer (only when sidebar is open).
      // Dismisses keyboard and closes sidebar on tap.
      if showSidebar {
        Color.clear
          .contentShape(Rectangle())
          .ignoresSafeArea()
          .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            withAnimation(.easeInOut(duration: 0.25)) { showSidebar = false }
          }
      }

      // Sidebar panel (always in hierarchy, offset to slide in/out).
      sidebarPanel
    }
  }

  // MARK: - Hamburger Button

  // Custom two-line hamburger icon: top line longer than bottom.
  private var hamburgerButton: some View {
    Button {
      withAnimation(.easeInOut(duration: 0.25)) { showSidebar = true }
    } label: {
      VStack(alignment: .leading, spacing: 5) {
        RoundedRectangle(cornerRadius: 1.5)
          .fill(NotebookPalette.ink)
          .frame(width: 22, height: 2.5)
        RoundedRectangle(cornerRadius: 1.5)
          .fill(NotebookPalette.ink)
          .frame(width: 16, height: 2.5)
      }
      .frame(width: 44, height: 44)
    }
    .accessibilityLabel("Open sidebar")
    .accessibilityIdentifier("hamburger_open_button")
  }

  // MARK: - Sidebar Panel

  // Floating sidebar card that slides in/out via offset.
  // Inset from screen edges with rounded corners and drop shadow.
  // Always in the view hierarchy so offset animation works reliably.
  private var sidebarPanel: some View {
    SidebarView(
      sessionService: sessionService,
      isPresented: $showSidebar,
      activeSessionId: viewModel.document.id.rawValue,
      onSelectSession: { sessionData in
        switchToSession(sessionData)
        withAnimation(.easeInOut(duration: 0.25)) { showSidebar = false }
      },
      onNewSession: {
        let session = sessionService.createSession(title: "New Chat")
        switchToSession(session)
        withAnimation(.easeInOut(duration: 0.25)) { showSidebar = false }
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
    // Offset the entire styled panel (width + leading padding) off-screen when hidden.
    .offset(x: showSidebar ? 0 : -(sidebarWidth + 24))
    .animation(.easeInOut(duration: 0.25), value: showSidebar)
  }

  // Switches the active session by creating a new view model.
  private func switchToSession(_ session: SessionData) {
    viewModel = NotebookViewModel(
      document: session.document,
      sessionData: session,
      sessionService: sessionService
    )
  }
}

#if DEBUG
struct AppRootView_Previews: PreviewProvider {
  static var previews: some View {
    AppRootView()
  }
}
#endif

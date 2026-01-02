import SwiftUI
import UIKit

// MARK: - Notebook Session

// Represents an open notebook editing session.
struct NotebookSession: Identifiable {
  let id: String
  let handle: DocumentHandle
}

// MARK: - Notebook Card Button

// Interactive container for a notebook card with tactile press effects.
// The card portion has drag behavior; the title is a sibling
// that animates together but stays outside the context menu highlight.
struct NotebookCardButton: View {
  let notebook: NotebookMetadata
  let action: () -> Void
  // Context menu actions passed in from the parent view.
  let onRename: () -> Void
  let onMoveToFolder: (() -> Void)?
  let onMoveOutOfFolder: (() -> Void)?
  let onDelete: () -> Void
  // Long press callback for custom context menu. Passes the card frame and card height.
  let onLongPress: ((CGRect, CGFloat) -> Void)?

  // Convenience initializer for dashboard use (move to folder).
  init(
    notebook: NotebookMetadata,
    action: @escaping () -> Void,
    onRename: @escaping () -> Void,
    onMoveToFolder: (() -> Void)?,
    onDelete: @escaping () -> Void,
    onLongPress: ((CGRect, CGFloat) -> Void)? = nil
  ) {
    self.notebook = notebook
    self.action = action
    self.onRename = onRename
    self.onMoveToFolder = onMoveToFolder
    self.onMoveOutOfFolder = nil
    self.onDelete = onDelete
    self.onLongPress = onLongPress
  }

  // Convenience initializer for folder overlay use (move out of folder).
  init(
    notebook: NotebookMetadata,
    action: @escaping () -> Void,
    onRename: @escaping () -> Void,
    onMoveOutOfFolder: @escaping () -> Void,
    onDelete: @escaping () -> Void,
    onLongPress: ((CGRect, CGFloat) -> Void)? = nil
  ) {
    self.notebook = notebook
    self.action = action
    self.onRename = onRename
    self.onMoveToFolder = nil
    self.onMoveOutOfFolder = onMoveOutOfFolder
    self.onDelete = onDelete
    self.onLongPress = onLongPress
  }

  // Tracks press state via gesture. Automatically resets when gesture ends or cancels.
  @GestureState private var isPressed = false
  // Controls the darkening overlay opacity on the card.
  @State private var dimOpacity: Double = 0
  // Drives a highlight flash on long press.
  @State private var showHighlight = false
  // Moves a bright sweep across the card on long press.
  @State private var sweepOffset: CGFloat = -1.2
  // Tracks the pending sweep animation work item so it can be cancelled on tap.
  @State private var sweepWorkItem: DispatchWorkItem?
  // Tracks the card's global frame for context menu positioning.
  @State private var cardFrame: CGRect = .zero
  // Tracks whether the context menu was triggered to prevent button action on release.
  @State private var didTriggerContextMenu = false

  private let cardCornerRadius: CGFloat = 10
  private let titleAreaHeight: CGFloat = 36
  // Keeps a paper-like portrait ratio for the overall container.
  private let cardAspectRatio: CGFloat = 0.72

  var body: some View {
    GeometryReader { proxy in
      let totalWidth = proxy.size.width
      let totalHeight = proxy.size.height
      // Card height is reduced to make room for the title below.
      let cardHeight = totalHeight - titleAreaHeight

      VStack(alignment: .leading, spacing: 4) {
        // The card portion wrapped in a button.
        cardButton(width: totalWidth, height: cardHeight)

        // Title and date below the card.
        NotebookCardTitle(notebook: notebook)
      }
      // Capture global frame for context menu positioning.
      .background(
        GeometryReader { geometry in
          Color.clear
            .onAppear {
              cardFrame = geometry.frame(in: .global)
            }
            .onChange(of: geometry.frame(in: .global)) { _, newFrame in
              cardFrame = newFrame
            }
        }
      )
    }
    .aspectRatio(cardAspectRatio, contentMode: .fit)
    // Scale animation applies to both card and title together.
    .scaleEffect(isPressed ? 1.04 : 1.0)
    .animation(.spring(response: 0.15, dampingFraction: 0.75), value: isPressed)
    // Detects touch down/up for scale, dim, and sweep animations.
    .simultaneousGesture(
      DragGesture(minimumDistance: 0)
        .updating($isPressed) { _, state, _ in
          state = true
        }
    )
    // Responds to press state changes to animate dim and schedule sweep.
    .onChange(of: isPressed) { _, pressed in
      handlePressChange(pressed)
    }
  }

  // Builds the card with tap gesture and drag support.
  // Uses onTapGesture instead of Button to avoid conflicts with draggable modifier.
  @ViewBuilder
  private func cardButton(width: CGFloat, height: CGFloat) -> some View {
    let shape = RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous)

    NotebookCardPreview(notebook: notebook, dimOpacity: dimOpacity)
      .frame(width: width, height: height)
      .background(Color.white)
      .clipShape(shape)
      .shadow(color: Color.black.opacity(0.14), radius: 7, x: 0, y: 4)
      .overlay(
        sweepOverlay(width: width, height: height)
      )
      .contentShape(shape)
      .onTapGesture {
        // Only execute action if context menu wasn't triggered by long press.
        guard !didTriggerContextMenu else { return }
        action()
      }
      .draggable(notebook)
  }

  // Builds the sweep highlight overlay that plays on long press.
  @ViewBuilder
  private func sweepOverlay(width: CGFloat, height: CGFloat) -> some View {
    let sweepDistance = width * 1.2
    ZStack {
      RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous)
        .fill(Color.white.opacity(showHighlight ? 0.7 : 0.0))
        .blendMode(.screen)
        .animation(.easeOut(duration: 0.28), value: showHighlight)

      RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous)
        .fill(
          LinearGradient(
            stops: [
              .init(color: Color.white.opacity(0.0), location: 0.0),
              .init(color: Color.white.opacity(0.45), location: 0.45),
              .init(color: Color.white.opacity(0.75), location: 0.55),
              .init(color: Color.white.opacity(0.0), location: 1.0)
            ],
            startPoint: .leading,
            endPoint: .trailing
          )
        )
        .blendMode(.screen)
        .offset(x: sweepOffset * sweepDistance)
        .opacity(showHighlight ? 1.0 : 0.0)
    }
    .frame(width: width, height: height)
    .clipShape(RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous))
    .allowsHitTesting(false)
  }

  // Handles press state changes to animate dim and schedule sweep/context menu.
  private func handlePressChange(_ pressed: Bool) {
    if pressed {
      // Reset context menu flag at start of new press to ensure taps work after menu dismissal.
      didTriggerContextMenu = false

      // Dim immediately on touch down.
      withAnimation(.easeOut(duration: 0.06)) {
        dimOpacity = 0.12
      }
      // Schedule context menu and sweep animation after a delay.
      // If gesture ends before the delay (a tap or cancel), the work item is cancelled.
      let currentFrame = cardFrame
      let cardHeight = currentFrame.height - titleAreaHeight
      let workItem = DispatchWorkItem { [onLongPress] in
        // Mark that context menu was triggered to prevent button action on release.
        didTriggerContextMenu = true

        // Fade out the dim overlay now that context menu is triggering.
        withAnimation(.easeOut(duration: 0.2)) {
          dimOpacity = 0
        }

        // Trigger custom context menu if callback is provided.
        if let onLongPress {
          onLongPress(currentFrame, cardHeight)
        }

        // Continue with sweep animation.
        guard !showHighlight else { return }
        showHighlight = true
        sweepOffset = -1.2
        withAnimation(.easeOut(duration: 0.5)) {
          sweepOffset = 1.2
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
          showHighlight = false
        }
      }
      sweepWorkItem = workItem
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: workItem)
    } else {
      // Fade out dim slowly on release or cancel.
      withAnimation(.easeOut(duration: 0.25)) {
        dimOpacity = 0
      }
      // Cancel pending sweep if it hasn't fired yet.
      sweepWorkItem?.cancel()
      sweepWorkItem = nil
      // Reset context menu flag after a brief delay to allow button action check.
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        didTriggerContextMenu = false
      }
    }
  }
}

// MARK: - Notebook Card Preview

// Displays only the notebook preview image. No title, no shadow.
// Shadow is applied at the button level to work correctly with iOS context menu transitions.
struct NotebookCardPreview: View {
  let notebook: NotebookMetadata
  // Opacity of darkening overlay. Animated externally for press effects.
  var dimOpacity: Double = 0

  // Inset to crop out the thin black line on the right edge of the canvas capture.
  private let previewEdgeInset: CGFloat = 2

  var body: some View {
    let previewImage = notebook.previewImageData.flatMap { UIImage(data: $0) }

    GeometryReader { proxy in
      let width = proxy.size.width
      let height = proxy.size.height

      ZStack {
        // Draws the preview or placeholder cover.
        // Uses topLeading alignment to anchor the image consistently,
        // preventing vertical shift during context menu transitions.
        if let previewImage {
          Image(uiImage: previewImage)
            .resizable()
            .scaledToFill()
            .frame(width: width + previewEdgeInset, height: height)
            .frame(width: width, height: height, alignment: .topLeading)
            .clipped()
        }

        // Darkening overlay for press feedback.
        Color.black.opacity(dimOpacity)
          .allowsHitTesting(false)
      }
    }
  }
}

// MARK: - Notebook Card Title

// Displays the notebook title and last accessed date.
// Rendered as a sibling to the card preview, outside the context menu scope.
struct NotebookCardTitle: View {
  let notebook: NotebookMetadata

  var body: some View {
    VStack(alignment: .leading, spacing: 1) {
      Text(notebook.displayName)
        .font(.system(size: 12, weight: .semibold))
        .foregroundStyle(Color.ink)
        .lineLimit(1)
        .truncationMode(.tail)

      if let subtitle = formattedAccessDate {
        Text(subtitle)
          .font(.system(size: 10, weight: .medium))
          .foregroundStyle(Color.inkSubtle)
          .lineLimit(1)
          .truncationMode(.tail)
      }
    }
    .padding(.horizontal, 2)
  }

  // Formats a short date string for the last access label.
  private var formattedAccessDate: String? {
    guard let lastAccessedAt = notebook.lastAccessedAt else {
      return nil
    }
    return Self.dateFormatter.string(from: lastAccessedAt)
  }

  // Reuses a single formatter for performance.
  private static let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.dateFormat = "h:mm a  MM/dd/yy"
    return formatter
  }()
}

// MARK: - Notebook Card Context Menu Preview

// Standalone preview view for context menus that shows only the card without title.
// Used with .contextMenu(menuItems:preview:) as the lifted preview.
struct NotebookCardContextMenuPreview: View {
  let notebook: NotebookMetadata

  // Inset to crop out the thin black line on the right edge of the canvas capture.
  private let previewEdgeInset: CGFloat = 2

  var body: some View {
    let previewImage = notebook.previewImageData.flatMap { UIImage(data: $0) }
    let cardCornerRadius: CGFloat = 10
    let previewWidth: CGFloat = 160
    let previewHeight: CGFloat = 200

    ZStack {
      Color.white
      if let previewImage {
        Image(uiImage: previewImage)
          .resizable()
          .scaledToFill()
          .frame(width: previewWidth + previewEdgeInset, height: previewHeight)
          .frame(width: previewWidth, height: previewHeight, alignment: .leading)
          .clipped()
      }
    }
    .frame(width: previewWidth, height: previewHeight)
    .clipShape(RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous))
    // Matches the shadow on the actual card for smooth context menu dismiss transition.
    .shadow(color: Color.black.opacity(0.14), radius: 7, x: 0, y: 4)
  }
}

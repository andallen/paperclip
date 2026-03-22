//
// CanvasInputView.swift
// InkOS
//
// Freeform canvas input with a single PKCanvasView drawing surface
// and floating text boxes layered on top.
// Pencil mode draws on the canvas. Keyboard mode lets the user tap
// to place draggable text boxes.
//
// The input system consists of three visual layers:
// 1. User Input Zone - ZStack of drawing canvas + floating text boxes
// 2. Attachment Previews - Thumbnails of attached files
// 3. Liquid Glass Pill - Mode buttons and send action
//

import PencilKit
import PhotosUI
import SwiftUI
import UIKit

// MARK: - InputMode

// The current input mode for the canvas input.
enum InputMode: Equatable {
  // PencilKit canvas for handwriting.
  case pencil
  // System keyboard for typing via floating text boxes.
  case keyboard
}

// MARK: - CanvasInputViewModel

// Observable state for the freeform canvas input system.
// Manages a single drawing surface with floating text boxes on top.
@MainActor @Observable
final class CanvasInputViewModel {
  // Current input mode (pencil or keyboard).
  var mode: InputMode = .pencil

  // Single drawing surface for the entire canvas.
  var drawing = PKDrawing()

  // Floating text boxes positioned on the canvas.
  var textBoxes: [CanvasTextBox] = []

  // Which text box currently has keyboard focus.
  var focusedTextBoxID: UUID?

  // Which text box is being dragged.
  var draggingTextBoxID: UUID?

  // Canvas height, auto-expands as the user draws near the bottom.
  var canvasHeight: CGFloat = 200

  // Attachments added by user.
  var attachments: [InputAttachment] = []

  // Whether the PencilKit toolbar is visible.
  var isToolbarVisible = false

  // Current error to display (cleared after showing).
  var currentError: AttachmentError?

  // Whether the attachment menu is showing above the toolbar.
  var showingAttachmentMenu = false


  // Whether there's an active submission in progress (for debouncing).
  var isSubmitting = false

  // Viewport size for positioning centered text boxes. Updated by the view.
  var viewportSize: CGSize = .zero

  // Screen position of the finger during a text box drag (global coordinates).
  var dragScreenPosition: CGPoint = .zero
  // Frame of the trash zone in global coordinates, set by TrashZoneView.
  var trashZoneFrame: CGRect = .zero
  // Whether the dragged text box is hovering over the trash zone.
  var isOverTrashZone = false

  // Whether a text box is currently being dragged.
  var isDraggingTextBox: Bool { draggingTextBoxID != nil }

  // Updates the trash hover state based on the dragged text box's boundaries
  // overlapping the trash zone (not the finger position alone).
  func updateTrashHoverState() {
    guard let boxID = draggingTextBoxID,
      let box = textBoxes.first(where: { $0.id == boxID })
    else {
      if isOverTrashZone {
        withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
          isOverTrashZone = false
        }
      }
      return
    }

    // Expand the trash zone by half the text box dimensions so that
    // overlap triggers when the box edge reaches the trash icon, not
    // just the finger.
    let expandedZone = trashZoneFrame.insetBy(
      dx: -(box.size.width / 2 + 20),
      dy: -(box.size.height / 2 + 20)
    )
    let hovering = !trashZoneFrame.isEmpty && expandedZone.contains(dragScreenPosition)

    if hovering != isOverTrashZone {
      withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
        isOverTrashZone = hovering
      }
    }
  }

  // Whether the canvas has any drawing strokes.
  var hasDrawing: Bool {
    !drawing.strokes.isEmpty
  }

  // Whether any text box has non-empty text.
  var hasText: Bool {
    textBoxes.contains { !$0.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
  }

  // Whether there's any content to submit.
  var canSubmit: Bool {
    !isSubmitting && (hasDrawing || hasText || !attachments.isEmpty)
  }

  // Total size of all current attachments.
  var totalAttachmentSize: Int {
    attachments.reduce(0) { $0 + $1.data.count }
  }

  // MARK: - Mode Switching

  // Switches to pencil mode. Dismisses keyboard focus and shows toolbar.
  func switchToPencilMode() {
    mode = .pencil
    isToolbarVisible = true
    focusedTextBoxID = nil
  }

  // Switches to keyboard mode and creates a text box at the center of the visible viewport.
  func switchToKeyboardMode() {
    mode = .keyboard
    isToolbarVisible = false
    // Create a centered text box.
    let centerX = max(0, viewportSize.width / 2 - 140)
    let centerY = max(50, viewportSize.height * 0.35)
    createTextBox(at: CGPoint(x: centerX, y: centerY))
  }

  // MARK: - Text Box Management

  // Creates a new text box at the given canvas position and focuses it.
  func createTextBox(at position: CGPoint) {
    let box = CanvasTextBox.new(at: position)
    textBoxes.append(box)
    focusedTextBoxID = box.id
  }

  // Clears text box focus, dismissing the keyboard.
  func defocusTextBox() {
    focusedTextBoxID = nil
  }

  // Moves a text box to a new position.
  func moveTextBox(id: UUID, to newPosition: CGPoint) {
    guard let index = textBoxes.firstIndex(where: { $0.id == id }) else { return }
    textBoxes[index].position = newPosition
  }

  // Deletes a text box by ID (e.g., dragged to trash).
  func deleteTextBox(id: UUID) {
    textBoxes.removeAll { $0.id == id }
    if focusedTextBoxID == id { focusedTextBoxID = nil }
    if draggingTextBoxID == id { draggingTextBoxID = nil }
  }

  // Removes text boxes with empty text. Called on submit.
  func removeEmptyTextBoxes() {
    textBoxes.removeAll { $0.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
  }

  // MARK: - Drawing Updates

  // Called when the canvas drawing changes. Updates stored drawing and auto-expands height.
  func onDrawingChanged(_ newDrawing: PKDrawing) {
    drawing = newDrawing
    let drawingMaxY = newDrawing.bounds.maxY
    let margin: CGFloat = 300
    if drawingMaxY + margin > canvasHeight {
      canvasHeight = drawingMaxY + margin + 500
    }
  }

  // MARK: - Toolbar Management

  // Shows the toolbar.
  func showToolbar() {
    withAnimation(.easeOut(duration: 0.3)) {
      isToolbarVisible = true
    }
  }

  // Hides the toolbar.
  func hideToolbar() {
    withAnimation(.easeOut(duration: 0.3)) {
      isToolbarVisible = false
    }
  }

  // Called when user starts drawing.
  func onDrawingBegan() {
    hideToolbar()
  }

  // MARK: - Attachment Management

  // Attachment data structure representing file data and metadata.
  struct AttachmentData {
    let data: Data
    let filename: String
    let mimeType: String
  }

  // Validates and adds attachments, returning any error that occurred.
  func addAttachments(_ newAttachments: [AttachmentData]) -> AttachmentError? {
    let totalCount = attachments.count + newAttachments.count
    if totalCount > AttachmentLimits.maxFileCount {
      return .tooManyFiles(count: totalCount)
    }

    for attachment in newAttachments {
      let sizeMB = Double(attachment.data.count) / (1024 * 1024)
      let maxSize = AttachmentLimits.maxSizeForMimeType(attachment.mimeType)
      if attachment.data.count > maxSize {
        return .fileTooLarge(filename: attachment.filename, sizeMB: sizeMB)
      }

      let newTotal = totalAttachmentSize + attachment.data.count
      let totalMB = Double(newTotal) / (1024 * 1024)
      if newTotal > AttachmentLimits.maxTotalSizeBytes {
        return .totalTooLarge(sizeMB: totalMB)
      }

      let inputAttachment = InputAttachment(
        id: UUID().uuidString,
        filename: attachment.filename,
        mimeType: attachment.mimeType,
        data: attachment.data
      )
      attachments.append(inputAttachment)
    }

    return nil
  }

  // Removes an attachment by ID.
  func removeAttachment(_ attachment: InputAttachment) {
    attachments.removeAll { $0.id == attachment.id }
  }

  // MARK: - Submission

  // Builds the input response using 4-case logic:
  // 1. All text, no drawing -> text only
  // 2. All drawing, no text -> single image
  // 3. Mixed, non-interleaved -> structured segments
  // 4. Mixed, interleaved -> composite image + text
  func buildResponse() -> InputResponse {
    removeEmptyTextBoxes()

    let textPresent = hasText
    let drawingPresent = hasDrawing

    // Case 1: text only.
    if textPresent && !drawingPresent {
      let allText = sortedTextBoxText()
      return InputResponse(
        text: allText,
        attachments: attachments.isEmpty ? nil : attachments
      )
    }

    // Case 2: drawing only.
    if drawingPresent && !textPresent {
      let bounds = drawing.bounds
      let image = drawing.image(from: bounds, scale: 2.0)
      let pngData = image.pngData()
      return InputResponse(
        handwritingImageData: pngData,
        attachments: attachments.isEmpty ? nil : attachments
      )
    }

    // Cases 3 and 4: mixed text + drawing.
    if textPresent && drawingPresent {
      if isInterleaved() {
        return buildCompositeResponse()
      } else {
        return buildStructuredResponse()
      }
    }

    // No content (only attachments).
    return InputResponse(attachments: attachments.isEmpty ? nil : attachments)
  }

  // Sorts text boxes by vertical position and concatenates their text.
  private func sortedTextBoxText() -> String {
    textBoxes
      .sorted { $0.position.y < $1.position.y }
      .map { $0.text.trimmingCharacters(in: .whitespacesAndNewlines) }
      .filter { !$0.isEmpty }
      .joined(separator: "\n")
  }

  // Checks if any drawing stroke overlaps a text box's horizontal band.
  private func isInterleaved() -> Bool {
    for box in textBoxes where !box.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
      let bandTop = box.position.y
      let bandBottom = box.position.y + box.size.height
      for stroke in drawing.strokes {
        let strokeBounds = stroke.renderBounds
        // Overlap when stroke bottom > band top and stroke top < band bottom.
        if strokeBounds.maxY > bandTop && strokeBounds.minY < bandBottom {
          return true
        }
      }
    }
    return false
  }

  // Case 3: builds ordered segments by sorting text boxes and drawing regions by Y.
  private func buildStructuredResponse() -> InputResponse {
    let sortedBoxes = textBoxes
      .filter { !$0.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
      .sorted { $0.position.y < $1.position.y }

    var segments: [InputSegment] = []
    let canvasBounds = drawing.bounds

    // Track vertical position as we walk down the canvas.
    var currentY = min(canvasBounds.minY, sortedBoxes.first?.position.y ?? canvasBounds.minY)

    for box in sortedBoxes {
      // Capture drawing region above this text box.
      let regionTop = currentY
      let regionBottom = box.position.y
      if regionBottom > regionTop {
        let cropRect = CGRect(
          x: canvasBounds.minX,
          y: regionTop,
          width: canvasBounds.width,
          height: regionBottom - regionTop
        )
        // Only add if there are strokes in this region.
        if hasStrokesIn(rect: cropRect) {
          let image = drawing.image(from: cropRect, scale: 2.0)
          if let pngData = image.pngData() {
            segments.append(.drawing(pngData))
          }
        }
      }

      // Add text segment.
      let trimmedText = box.text.trimmingCharacters(in: .whitespacesAndNewlines)
      if !trimmedText.isEmpty {
        segments.append(.text(trimmedText))
      }

      currentY = box.position.y + box.size.height
    }

    // Capture any drawing region below the last text box.
    if currentY < canvasBounds.maxY {
      let cropRect = CGRect(
        x: canvasBounds.minX,
        y: currentY,
        width: canvasBounds.width,
        height: canvasBounds.maxY - currentY
      )
      if hasStrokesIn(rect: cropRect) {
        let image = drawing.image(from: cropRect, scale: 2.0)
        if let pngData = image.pngData() {
          segments.append(.drawing(pngData))
        }
      }
    }

    // Build text from text segments for the main text field.
    let allText = sortedTextBoxText()

    return InputResponse(
      text: allText.isEmpty ? nil : allText,
      segments: segments.isEmpty ? nil : segments,
      attachments: attachments.isEmpty ? nil : attachments
    )
  }

  // Case 4: composites drawing + text into a single image, plus concatenated text.
  private func buildCompositeResponse() -> InputResponse {
    let allText = sortedTextBoxText()

    // Determine composite bounds covering both drawing and text boxes.
    var compositeRect = drawing.bounds
    for box in textBoxes where !box.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
      let boxRect = CGRect(origin: box.position, size: box.size)
      compositeRect = compositeRect.union(boxRect)
    }

    // Add some padding.
    compositeRect = compositeRect.insetBy(dx: -20, dy: -20)

    let renderer = UIGraphicsImageRenderer(size: compositeRect.size)
    let compositeImage = renderer.image { context in
      // Draw the PencilKit content, offset so compositeRect.origin maps to (0,0).
      let drawingImage = drawing.image(from: compositeRect, scale: 2.0)
      drawingImage.draw(in: CGRect(origin: .zero, size: compositeRect.size))

      // Overlay text boxes.
      let font = NotebookTypography.bodyUIFont
      let textAttributes: [NSAttributedString.Key: Any] = [
        .font: font,
        .foregroundColor: UIColor.black,
      ]
      for box in textBoxes
      where !box.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
        let offsetX = box.position.x - compositeRect.origin.x
        let offsetY = box.position.y - compositeRect.origin.y
        let textRect = CGRect(x: offsetX, y: offsetY, width: box.size.width, height: box.size.height)
        (box.text as NSString).draw(in: textRect, withAttributes: textAttributes)
      }
    }

    let pngData = compositeImage.pngData()
    return InputResponse(
      text: allText.isEmpty ? nil : allText,
      handwritingImageData: pngData,
      attachments: attachments.isEmpty ? nil : attachments
    )
  }

  // Whether any stroke's bounding rect intersects the given rect.
  private func hasStrokesIn(rect: CGRect) -> Bool {
    drawing.strokes.contains { $0.renderBounds.intersects(rect) }
  }

  // Clears all input state after submission.
  func clearAllInput() {
    drawing = PKDrawing()
    textBoxes = []
    focusedTextBoxID = nil
    draggingTextBoxID = nil
    dragScreenPosition = .zero
    isOverTrashZone = false
    attachments = []
    mode = .pencil
    canvasHeight = 200
    isToolbarVisible = false
    isSubmitting = false
  }
}

// MARK: - FloatingTextBoxView

// A draggable text box that floats on the freeform canvas.
// Always draggable with finger or pencil in any mode.
// Editable (shows keyboard on tap) only in keyboard mode.
// Reports drag position in global coordinates for trash-zone hit testing.
struct FloatingTextBoxView: View {
  @Binding var box: CanvasTextBox
  // Whether the text field is editable (keyboard mode).
  var isEditable: Bool
  // Whether this box is currently focused.
  var isFocused: Bool
  // Called when the box is tapped in non-editable (pencil) mode.
  var onTapped: (() -> Void)?
  // Called during drag with the finger's global screen position.
  var onDragChanged: ((CGPoint) -> Void)?
  // Called when drag ends with screen position and computed new canvas position.
  var onDragEnded: ((CGPoint, CGPoint) -> Void)?

  // Tracks drag offset during gesture. Using @State so we control reset timing.
  @State private var dragOffset: CGSize = .zero

  var body: some View {
    textContent
      .padding(.horizontal, 8)
      .padding(.vertical, 4)
      .frame(width: box.size.width)
      .background(
        GeometryReader { geo in
          Color.clear
            .onChange(of: geo.size.height) { _, newHeight in
              // Only update when delta > 1pt to avoid layout cycles.
              if abs(newHeight - box.size.height) > 1 {
                box.size.height = newHeight
              }
            }
        }
      )
      .background(
        RoundedRectangle(cornerRadius: 8)
          .fill(Color.white.opacity(0.01))
      )
      .overlay(
        RoundedRectangle(cornerRadius: 8)
          .strokeBorder(
            isFocused
              ? NotebookPalette.inkSubtle.opacity(0.4)
              : NotebookPalette.inkFaint.opacity(0.15),
            lineWidth: 1
          )
      )
      .contentShape(Rectangle())
      .offset(dragOffset)
      .highPriorityGesture(
        DragGesture(coordinateSpace: .global)
          .onChanged { value in
            dragOffset = value.translation
            onDragChanged?(value.location)
          }
          .onEnded { value in
            let newPosition = CGPoint(
              x: max(0, box.position.x + value.translation.width),
              y: max(0, box.position.y + value.translation.height)
            )
            // Commit position immediately to prevent snap-back before deletion animation.
            box.position = newPosition
            dragOffset = .zero
            onDragEnded?(value.location, newPosition)
          }
      )
      .onTapGesture {
        // In pencil mode, tapping a text box switches to keyboard mode.
        if !isEditable {
          onTapped?()
        }
      }
      .accessibilityIdentifier("floating_text_box")
  }

  // Shows an editable TextField in keyboard mode, read-only Text in pencil mode.
  @ViewBuilder
  private var textContent: some View {
    if isEditable {
      TextField("", text: $box.text, axis: .vertical)
        .font(NotebookTypography.body)
        .foregroundColor(NotebookPalette.ink)
    } else {
      // Read-only display. Still draggable with finger or pencil.
      Text(box.text.isEmpty ? " " : box.text)
        .font(NotebookTypography.body)
        .foregroundColor(NotebookPalette.ink)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
  }
}

// MARK: - UserInputZoneView

// The freeform drawing and text input area.
// Two-layer ZStack: PKCanvasView on bottom, floating text boxes on top.
// Text boxes are always visible and draggable in both modes.
// Tapping empty space in keyboard mode deselects the focused box and dismisses keyboard.
struct UserInputZoneView: View {
  // Shared view model for input state.
  @Bindable var viewModel: CanvasInputViewModel

  // Available viewport height so the canvas fills the visible screen.
  var availableHeight: CGFloat = 800

  // Focus state for text boxes, keyed by text box ID.
  @FocusState private var focusedBoxID: UUID?

  var body: some View {
    let minHeight = max(viewModel.canvasHeight, availableHeight)

    ZStack(alignment: .topLeading) {
      // Layer 1: PKCanvasView (full surface, always present).
      CanvasInputCanvasView(
        drawing: Binding(
          get: { viewModel.drawing },
          set: { viewModel.onDrawingChanged($0) }
        ),
        isInteractive: viewModel.mode == .pencil,
        onDrawingBegan: { viewModel.onDrawingBegan() }
      )
      .frame(minHeight: minHeight)
      .frame(maxWidth: .infinity)

      // Layer 2: Tap-to-deselect overlay (keyboard mode only).
      // Tapping empty space dismisses the keyboard and deselects the focused text box.
      if viewModel.mode == .keyboard {
        Color.clear
          .contentShape(Rectangle())
          .frame(minHeight: minHeight)
          .onTapGesture {
            viewModel.defocusTextBox()
          }
      }

      // Layer 3: Floating text boxes (always visible, always draggable).
      ForEach($viewModel.textBoxes) { $box in
        FloatingTextBoxView(
          box: $box,
          isEditable: viewModel.mode == .keyboard,
          isFocused: viewModel.focusedTextBoxID == box.id,
          onTapped: {
            // Tap on text box in pencil mode switches to keyboard mode and focuses it.
            // Delay focus slightly so SwiftUI renders the TextField before assigning focus.
            viewModel.mode = .keyboard
            viewModel.isToolbarVisible = false
            Task { @MainActor in
              try? await Task.sleep(for: .milliseconds(100))
              viewModel.focusedTextBoxID = box.id
            }
          },
          onDragChanged: { screenPosition in
            // Set drag state on first call; update position on every call.
            if viewModel.draggingTextBoxID != box.id {
              withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                viewModel.draggingTextBoxID = box.id
                viewModel.focusedTextBoxID = nil
              }
            }
            viewModel.dragScreenPosition = screenPosition
            viewModel.updateTrashHoverState()
          },
          onDragEnded: { screenPosition, newPosition in
            viewModel.dragScreenPosition = screenPosition
            viewModel.updateTrashHoverState()

            if viewModel.isOverTrashZone {
              withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                viewModel.deleteTextBox(id: box.id)
                viewModel.draggingTextBoxID = nil
                viewModel.isOverTrashZone = false
              }
            } else {
              viewModel.moveTextBox(id: box.id, to: newPosition)
              withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                viewModel.draggingTextBoxID = nil
              }
            }
          }
        )
        .focused($focusedBoxID, equals: box.id)
        .position(
          x: box.position.x + box.size.width / 2,
          y: box.position.y + box.size.height / 2
        )
        .transition(.scale(scale: 0.5).combined(with: .opacity))
      }
    }
    .frame(minHeight: minHeight)
    .background(
      // Track viewport size for centering text boxes on creation.
      GeometryReader { geo in
        Color.clear
          .onAppear {
            viewModel.viewportSize = CGSize(width: geo.size.width, height: availableHeight)
          }
          .onChange(of: geo.size) { _, newSize in
            viewModel.viewportSize = CGSize(width: newSize.width, height: availableHeight)
          }
      }
    )
    .onChange(of: viewModel.focusedTextBoxID) { _, newID in
      focusedBoxID = newID
    }
    .onChange(of: focusedBoxID) { _, newID in
      // Sync back from FocusState to viewModel.
      if newID != viewModel.focusedTextBoxID {
        viewModel.focusedTextBoxID = newID
      }
    }
    .accessibilityIdentifier("user_input_zone")
  }
}

// Safe subscript for Array to avoid index-out-of-bounds crashes.
extension Array {
  subscript(safe index: Int) -> Element? {
    indices.contains(index) ? self[index] : nil
  }
}

// MARK: - CanvasInputCanvasView

// UIViewRepresentable wrapper for PKCanvasView used in CanvasInputView.
struct CanvasInputCanvasView: UIViewRepresentable {
  @Binding var drawing: PKDrawing

  // Whether the canvas accepts input.
  var isInteractive: Bool = true

  // Callback when user starts drawing.
  var onDrawingBegan: (() -> Void)?

  // Callback when canvas view is created (for toolbar integration).
  var onCanvasViewCreated: ((PKCanvasView) -> Void)?

  func makeUIView(context: Context) -> PKCanvasView {
    let canvas = PKCanvasView()
    canvas.drawing = drawing
    canvas.delegate = context.coordinator
    canvas.tool = PKInkingTool(.pen, color: .black, width: 2)
    canvas.backgroundColor = .clear
    canvas.isOpaque = false
    canvas.drawingPolicy = .pencilOnly
    canvas.isScrollEnabled = false
    canvas.isUserInteractionEnabled = isInteractive

    // Restrict all gesture recognizers to pencil touches only.
    // Finger touches are unclaimed and propagate to the parent ScrollView.
    let pencilType = NSNumber(value: UITouch.TouchType.pencil.rawValue)
    for gestureRecognizer in canvas.gestureRecognizers ?? [] {
      gestureRecognizer.allowedTouchTypes = [pencilType]
    }

    onCanvasViewCreated?(canvas)
    return canvas
  }

  func updateUIView(_ uiView: PKCanvasView, context: Context) {
    // Only update if drawing has changed externally (e.g., cleared).
    if uiView.drawing != drawing {
      uiView.drawing = drawing
    }
    uiView.isUserInteractionEnabled = isInteractive
  }

  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }

  class Coordinator: NSObject, PKCanvasViewDelegate {
    var parent: CanvasInputCanvasView
    private var wasDrawing = false

    init(_ parent: CanvasInputCanvasView) {
      self.parent = parent
    }

    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
      parent.drawing = canvasView.drawing
    }

    func canvasViewDidBeginUsingTool(_ canvasView: PKCanvasView) {
      if !wasDrawing {
        wasDrawing = true
        parent.onDrawingBegan?()
      }
    }

    func canvasViewDidEndUsingTool(_ canvasView: PKCanvasView) {
      wasDrawing = false
    }
  }
}

// MARK: - Preview

#Preview("Freeform Canvas Input") {
  ScrollView {
    UserInputZoneView(viewModel: CanvasInputViewModel())
  }
  .background(NotebookPalette.paper)
}

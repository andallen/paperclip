//
// CanvasInputView.swift
// InkOS
//
// Persistent input UI at the bottom of the notebook canvas.
// Minimal chrome with invisible canvas feel - no borders, matches paper background.
// User can switch between pencil (PencilKit) and keyboard (text field) modes.
// Attachments can be added via paperclip in either mode.
// Icons fade in sequentially (0.1s stagger) when input appears.
//
// The input system consists of three visual layers:
// 1. User Input Zone - Drawing area and text field below content
// 2. Attachment Previews - Thumbnails of attached files
// 3. Liquid Glass Pill - Mode buttons and send action
//

import PencilKit
import PhotosUI
import SwiftUI

// MARK: - InputMode

// The current input mode for the canvas input.
enum InputMode: Equatable {
  // PencilKit canvas for handwriting.
  case pencil
  // System keyboard for typing.
  case keyboard
}

// MARK: - CanvasInputViewModel

// Observable state for the canvas input system.
// Manages drawing, text, attachments, and mode switching.
@MainActor @Observable
final class CanvasInputViewModel {
  // Current input mode (pencil or keyboard).
  var mode: InputMode = .pencil

  // Text input value (keyboard mode).
  var textInput = ""

  // PencilKit canvas drawing (pencil mode).
  var canvasDrawing = PKDrawing()

  // Attachments added by user.
  var attachments: [InputAttachment] = []

  // Whether the PencilKit toolbar is visible.
  var isToolbarVisible = false

  // Current error to display (cleared after showing).
  var currentError: AttachmentError?

  // Whether there's an active submission in progress (for debouncing).
  var isSubmitting = false

  // Whether the canvas has any strokes.
  var hasDrawing: Bool {
    !canvasDrawing.strokes.isEmpty
  }

  // Whether there's any content to submit.
  var canSubmit: Bool {
    !isSubmitting
      && (!textInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        || hasDrawing
        || !attachments.isEmpty)
  }

  // Total size of all current attachments.
  var totalAttachmentSize: Int {
    attachments.reduce(0) { $0 + $1.data.count }
  }

  // MARK: - Mode Switching

  // Switches to pencil mode, preserving existing content.
  func switchToPencilMode() {
    mode = .pencil
    isToolbarVisible = true
  }

  // Switches to keyboard mode, preserving existing content.
  func switchToKeyboardMode() {
    mode = .keyboard
    isToolbarVisible = false
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

  // Called when user starts drawing - hides toolbar.
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
    // Check file count limit.
    let totalCount = attachments.count + newAttachments.count
    if totalCount > AttachmentLimits.maxFileCount {
      return .tooManyFiles(count: totalCount)
    }

    for attachment in newAttachments {
      // Check individual file size.
      let sizeMB = Double(attachment.data.count) / (1024 * 1024)
      if attachment.data.count > AttachmentLimits.maxFileSizeBytes {
        return .fileTooLarge(filename: attachment.filename, sizeMB: sizeMB)
      }

      // Check total size.
      let newTotal = totalAttachmentSize + attachment.data.count
      let totalMB = Double(newTotal) / (1024 * 1024)
      if newTotal > AttachmentLimits.maxTotalSizeBytes {
        return .totalTooLarge(sizeMB: totalMB)
      }

      // Add the attachment.
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

  // Builds the input response from current state.
  func buildResponse() -> InputResponse {
    // Capture handwriting as image if there are strokes.
    var handwritingData: Data?
    if hasDrawing {
      let bounds = canvasDrawing.bounds
      let image = canvasDrawing.image(from: bounds, scale: UIScreen.main.scale)
      handwritingData = image.pngData()
    }

    // Build response.
    return InputResponse(
      text: textInput.isEmpty ? nil : textInput,
      handwritingImageData: handwritingData,
      attachments: attachments.isEmpty ? nil : attachments
    )
  }

  // Clears all input state after submission.
  func clearAllInput() {
    textInput = ""
    canvasDrawing = PKDrawing()
    attachments = []
    mode = .pencil
    isToolbarVisible = false
    isSubmitting = false
  }
}

// MARK: - CanvasInputView

// Persistent input view at the bottom of the notebook canvas.
// Invisible canvas feel with minimal toolbar icons.
struct CanvasInputView: View {
  // Callback when user submits input.
  var onSubmit: ((InputResponse) -> Void)?

  // View model for managing input state.
  @State private var viewModel = CanvasInputViewModel()

  // Photo picker selection.
  @State private var selectedPhotos: [PhotosPickerItem] = []

  // Sequential fade-in animation state.
  @State private var pencilIconVisible = false
  @State private var keyboardIconVisible = false
  @State private var paperclipIconVisible = false
  @State private var sendButtonVisible = false

  // Focus state for text field.
  @FocusState private var isTextFieldFocused: Bool

  // Alert state for errors.
  @State private var showingError = false

  var body: some View {
    VStack(spacing: 0) {
      // Attachment preview grid (if any attachments).
      if !viewModel.attachments.isEmpty {
        AttachmentPreviewGrid(attachments: viewModel.attachments) { attachment in
          viewModel.removeAttachment(attachment)
        }
        .padding(.horizontal, NotebookSpacing.md)
        .padding(.bottom, NotebookSpacing.xs)
      }

      // Liquid glass pill toolbar.
      glassPillToolbar
    }
    .accessibilityIdentifier("canvas_input_view")
    .onChange(of: selectedPhotos) { _, newItems in
      Task {
        await loadSelectedPhotos(newItems)
      }
    }
    .onChange(of: viewModel.mode) { _, newMode in
      // Update focus based on mode.
      if newMode == .keyboard {
        isTextFieldFocused = true
      } else {
        isTextFieldFocused = false
      }
    }
    .onAppear {
      // Sequential fade-in animation for toolbar icons.
      withAnimation(.easeOut(duration: 0.2).delay(0.0)) {
        pencilIconVisible = true
      }
      withAnimation(.easeOut(duration: 0.2).delay(0.1)) {
        keyboardIconVisible = true
      }
      withAnimation(.easeOut(duration: 0.2).delay(0.2)) {
        paperclipIconVisible = true
      }
      withAnimation(.easeOut(duration: 0.2).delay(0.3)) {
        sendButtonVisible = true
      }
    }
    .alert(
      "Attachment Error",
      isPresented: $showingError,
      presenting: viewModel.currentError
    ) { _ in
      Button("OK", role: .cancel) {
        viewModel.currentError = nil
      }
    } message: { error in
      Text(error.localizedDescription)
    }
  }

  // MARK: - Glass Pill Toolbar

  private var glassPillToolbar: some View {
    HStack(spacing: 24) {
      // Pencil mode button.
      Button {
        withAnimation(.easeInOut(duration: 0.2)) {
          viewModel.switchToPencilMode()
        }
      } label: {
        Image(systemName: "pencil.tip")
          .font(.system(size: 22, weight: .medium))
          .foregroundColor(
            viewModel.mode == .pencil ? NotebookPalette.ink : NotebookPalette.inkSubtle)
      }
      .opacity(pencilIconVisible ? 1 : 0)
      .accessibilityLabel("Pencil mode")
      .accessibilityValue(viewModel.mode == .pencil ? "selected" : "")
      .accessibilityIdentifier("pencil_mode_button")

      // Keyboard mode button.
      Button {
        withAnimation(.easeInOut(duration: 0.2)) {
          viewModel.switchToKeyboardMode()
        }
      } label: {
        Image(systemName: "keyboard")
          .font(.system(size: 22, weight: .medium))
          .foregroundColor(
            viewModel.mode == .keyboard ? NotebookPalette.ink : NotebookPalette.inkSubtle)
      }
      .opacity(keyboardIconVisible ? 1 : 0)
      .accessibilityLabel("Keyboard mode")
      .accessibilityValue(viewModel.mode == .keyboard ? "selected" : "")
      .accessibilityIdentifier("keyboard_mode_button")

      // Paperclip attachment picker.
      PhotosPicker(
        selection: $selectedPhotos,
        maxSelectionCount: AttachmentLimits.maxFileCount - viewModel.attachments.count,
        matching: .any(of: [.images, .screenshots])
      ) {
        Image(systemName: "paperclip")
          .font(.system(size: 22, weight: .medium))
          .foregroundColor(NotebookPalette.inkSubtle)
      }
      .opacity(paperclipIconVisible ? 1 : 0)
      .accessibilityLabel("Attach image")
      .accessibilityIdentifier("paperclip_button")

      // Send button: white up arrow in black circle.
      Button {
        submitInput()
      } label: {
        ZStack {
          Circle()
            .fill(viewModel.canSubmit ? Color.black : NotebookPalette.inkFaint)
            .frame(width: 36, height: 36)
          Image(systemName: "arrow.up")
            .font(.system(size: 16, weight: .bold))
            .foregroundColor(.white)
        }
      }
      .disabled(!viewModel.canSubmit)
      .opacity(sendButtonVisible ? 1 : 0)
      .accessibilityLabel("Send")
      .accessibilityIdentifier("send_button")
    }
    .padding(.horizontal, 20)
    .padding(.vertical, 12)
    .glassEffect(.regular.interactive(), in: .capsule)
  }

  // MARK: - Actions

  private func submitInput() {
    guard viewModel.canSubmit else { return }

    // Debounce rapid taps.
    viewModel.isSubmitting = true

    // Build and send response.
    let response = viewModel.buildResponse()

    // Clear input state.
    viewModel.clearAllInput()
    selectedPhotos = []

    // Notify callback.
    onSubmit?(response)
  }

  private func loadSelectedPhotos(_ items: [PhotosPickerItem]) async {
    var newAttachments: [CanvasInputViewModel.AttachmentData] = []

    for item in items {
      // Skip if already loaded.
      if viewModel.attachments.contains(where: { $0.id == item.itemIdentifier ?? "" }) {
        continue
      }

      // Load image data.
      guard let data = try? await item.loadTransferable(type: Data.self) else {
        viewModel.currentError = .loadFailed(filename: "image")
        showingError = true
        continue
      }

      newAttachments.append(
        CanvasInputViewModel.AttachmentData(
          data: data,
          filename: "image_\(Date().timeIntervalSince1970).png",
          mimeType: "image/png"
        ))
    }

    // Validate and add attachments.
    if let error = viewModel.addAttachments(newAttachments) {
      viewModel.currentError = error
      showingError = true
    }

    // Clear selection to allow re-selecting same photos.
    selectedPhotos = []
  }
}

// MARK: - UserInputZoneView

// The drawing and text input area positioned below content.
// This is a separate view that gets embedded in NotebookCanvasView.
struct UserInputZoneView: View {
  // Shared view model for input state.
  @Bindable var viewModel: CanvasInputViewModel

  // Reference to the PKCanvasView for toolbar integration.
  @State private var canvasView: PKCanvasView?

  // Focus state for text field.
  @FocusState private var isTextFieldFocused: Bool

  // Minimum height for the drawing area.
  private let minDrawingHeight: CGFloat = 200

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      // PencilKit canvas for drawing (always present, but interactive only in pencil mode).
      CanvasInputCanvasView(
        drawing: $viewModel.canvasDrawing,
        isInteractive: viewModel.mode == .pencil,
        onDrawingBegan: { viewModel.onDrawingBegan() },
        onCanvasViewCreated: { canvas in
          canvasView = canvas
        }
      )
      .frame(minHeight: minDrawingHeight)
      .frame(maxWidth: .infinity)

      // Text field for typing (positioned below drawing).
      if viewModel.mode == .keyboard || !viewModel.textInput.isEmpty {
        TextField("Type here...", text: $viewModel.textInput, axis: .vertical)
          .font(NotebookTypography.body)
          .foregroundColor(NotebookPalette.ink)
          .lineLimit(1...10)
          .focused($isTextFieldFocused)
          .padding(.vertical, NotebookSpacing.sm)
          .accessibilityIdentifier("text_input_field")
      }
    }
    .onChange(of: viewModel.mode) { _, newMode in
      isTextFieldFocused = (newMode == .keyboard)
    }
    .accessibilityIdentifier("user_input_zone")
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
    canvas.drawingPolicy = .anyInput
    canvas.isUserInteractionEnabled = isInteractive

    // Notify parent of canvas creation.
    onCanvasViewCreated?(canvas)

    return canvas
  }

  func updateUIView(_ uiView: PKCanvasView, context: Context) {
    // Only update if drawing has changed externally (e.g., cleared).
    if uiView.drawing != drawing {
      uiView.drawing = drawing
    }

    // Update interactivity.
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

#Preview("Canvas Input - Pencil Mode") {
  VStack {
    Spacer()
    CanvasInputView { response in
      print("Submitted: \(response)")
    }
    .padding(.horizontal, 60)
  }
  .background(NotebookPalette.paper)
}

#Preview("Canvas Input - Keyboard Mode") {
  VStack {
    Spacer()
    CanvasInputView { response in
      print("Submitted: \(response)")
    }
    .padding(.horizontal, 60)
  }
  .background(NotebookPalette.paper)
}

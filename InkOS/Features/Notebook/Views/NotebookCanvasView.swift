//
// NotebookCanvasView.swift
// InkOS
//
// Pure white canvas that renders the notebook document.
// User taps anywhere on content to advance to the next block.
// Fixed input bar at the bottom of the screen for messaging Alan.
// Uses ScrollView with LazyVStack for performance.
// Follows Apple HIG for iPad with proper touch targets and safe areas.
//
// The canvas has three main zones:
// 1. Content Zone - Alan's blocks rendered in a scrollable area
// 2. User Input Zone - Drawing/typing area below content
// 3. Fixed Input Bar - Liquid glass pill at bottom of screen
//

import PhotosUI
import SwiftUI
import UniformTypeIdentifiers

// MARK: - NotebookCanvasView

// Pure white canvas for rendering notebook blocks.
// User controls pacing by tapping to reveal the next block.
// Fixed input bar at the bottom allows user to message Alan at any time.
struct NotebookCanvasView: View {
  @Bindable var viewModel: NotebookViewModel
  @Environment(\.horizontalSizeClass) private var horizontalSizeClass

  // Shared input view model for user input zone.
  @State private var inputViewModel = CanvasInputViewModel()

  // Captured viewport height for sizing the drawing canvas.
  @State private var viewportHeight: CGFloat = 800

  var body: some View {
    ZStack(alignment: .bottom) {
      // Main scrollable content with tap-to-advance.
      ScrollViewReader { scrollProxy in
        ScrollView {
          VStack(spacing: 0) {
            // Content blocks — padded for readability.
            LazyVStack(spacing: 0) {
              // Alan's content blocks.
              ForEach(viewModel.document.blocks, id: \.id) { block in
                BlockContainerView(
                  block: block,
                  animationState: viewModel.animationState[block.id] ?? .waiting
                )
              }

              // User input preview blocks (submitted content).
              ForEach(viewModel.inputPreviews) { preview in
                InputPreviewBlockView(
                  response: preview.response,
                  timestamp: preview.timestamp
                )
                .padding(.top, NotebookSpacing.lg)
                .id("preview_\(preview.id)")
              }
            }
            .padding(.horizontal, horizontalPadding)
            .padding(.top, hasContent ? 100 : 0)

            // Active drawing canvas — full width, no horizontal padding.
            userInputZone
              .padding(.top, hasContent ? NotebookSpacing.xl : 0)
              .id("input_zone")
          }
          .padding(.bottom, 160)  // Extra padding for fixed input bar
        }
        .background(
          GeometryReader { geo in
            NotebookPalette.paper
              .onAppear { viewportHeight = geo.size.height }
              .onChange(of: geo.size.height) { _, newHeight in
                viewportHeight = newHeight
              }
          }
        )
        .contentShape(Rectangle())
        .onTapGesture {
          // Dismiss attachment menu if open.
          if inputViewModel.showingAttachmentMenu {
            withAnimation(.easeOut(duration: 0.15)) {
              inputViewModel.showingAttachmentMenu = false
            }
          }
          viewModel.handleContentTap()
        }
        .onChange(of: viewModel.inputPreviews.count) { oldCount, newCount in
          // Scroll to new preview when added.
          if newCount > oldCount, let lastPreview = viewModel.inputPreviews.last {
            withAnimation(.easeOut(duration: 0.3)) {
              scrollProxy.scrollTo("preview_\(lastPreview.id)", anchor: .bottom)
            }
          }
        }
      }
      .accessibilityIdentifier("notebook_canvas")

      // Error banner (if any). Auto-dismisses after 8 seconds.
      if let error = viewModel.errorMessage {
        errorBanner(error)
          .padding(.horizontal, 20)
          .padding(.bottom, 8)
          .transition(.move(edge: .bottom).combined(with: .opacity))
          .task(id: error) {
            // Task is automatically cancelled when the error changes or view disappears.
            try? await Task.sleep(for: .seconds(8))
            guard !Task.isCancelled else { return }
            withAnimation {
              viewModel.errorMessage = nil
            }
          }
      }

      // Bottom bar: swap between toolbar and trash zone during text box drag.
      Group {
        if inputViewModel.isDraggingTextBox {
          TrashZoneView(
            isHovering: inputViewModel.isOverTrashZone,
            onFrameChange: { inputViewModel.trashZoneFrame = $0 }
          )
          .transition(.move(edge: .bottom).combined(with: .opacity))
        } else {
          canvasInputBar
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
      }
      .padding(.bottom, 30)
      .animation(.spring(response: 0.35, dampingFraction: 0.8), value: inputViewModel.isDraggingTextBox)
    }
    .background(NotebookPalette.paper)
  }

  // MARK: - User Input Zone

  // The drawing and text input area positioned below all content.
  private var userInputZone: some View {
    UserInputZoneView(viewModel: inputViewModel, availableHeight: viewportHeight)
  }

  // MARK: - Canvas Input Bar

  // The fixed liquid glass pill toolbar at bottom of screen.
  private var canvasInputBar: some View {
    CanvasInputBar(viewModel: inputViewModel) { response in
      viewModel.submitCanvasInput(response)
    }
  }

  // Error banner shown when Alan encounters an error.
  private func errorBanner(_ message: String) -> some View {
    HStack(spacing: 8) {
      Image(systemName: "exclamationmark.circle.fill")
        .foregroundColor(.red)
      Text(message)
        .font(NotebookTypography.caption)
        .foregroundColor(NotebookPalette.ink)
        .lineLimit(2)

      Spacer()

      Button {
        viewModel.errorMessage = nil
      } label: {
        Image(systemName: "xmark")
          .font(.system(size: 12, weight: .bold))
          .foregroundColor(NotebookPalette.inkSubtle)
      }
    }
    .padding(12)
    .background(
      RoundedRectangle(cornerRadius: 10)
        .fill(Color.red.opacity(0.08))
    )
    .overlay(
      RoundedRectangle(cornerRadius: 10)
        .stroke(Color.red.opacity(0.2), lineWidth: 1)
    )
  }

  // Whether there are any content blocks or input previews to display.
  private var hasContent: Bool {
    !viewModel.document.blocks.isEmpty || !viewModel.inputPreviews.isEmpty
  }

  // Responsive horizontal padding based on size class.
  private var horizontalPadding: CGFloat {
    horizontalSizeClass == .regular
      ? NotebookLayout.horizontalPaddingRegular
      : NotebookLayout.horizontalPaddingCompact
  }
}

// MARK: - TrashZoneView

// Trash icon that appears when a text box is being dragged.
// Enlarges with a fast diagonal shimmer across the whole circle on hover.
// Releasing the text box over this view deletes the text box.
struct TrashZoneView: View {
  // Whether the dragged text box is hovering over this zone.
  var isHovering: Bool
  // Reports the view's frame in global coordinates for hit testing.
  var onFrameChange: (CGRect) -> Void

  var body: some View {
    ZStack {
      Circle()
        .fill(isHovering ? Color.red.opacity(0.12) : Color(.systemGray5))
        .frame(width: 56, height: 56)

      Image(systemName: "trash")
        .font(.system(size: 24, weight: .medium))
        .foregroundStyle(isHovering ? .red : .secondary)
    }
    .scaleEffect(isHovering ? 1.4 : 1.0)
    .background(
      GeometryReader { geo in
        Color.clear
          .onAppear { onFrameChange(geo.frame(in: .global)) }
          .onChange(of: geo.frame(in: .global)) { _, newFrame in
            onFrameChange(newFrame)
          }
      }
    )
    .accessibilityIdentifier("trash_zone")
  }
}

// MARK: - CanvasInputBar

// The liquid glass pill toolbar that stays fixed at the bottom.
// Separated from CanvasInputView for layout purposes.
struct CanvasInputBar: View {
  // Shared input view model.
  @Bindable var viewModel: CanvasInputViewModel

  // Callback when user submits.
  var onSubmit: ((InputResponse) -> Void)?

  // Photo picker selection.
  @State private var selectedPhotos: [PhotosPickerItem] = []

  // Whether the document picker sheet is showing.
  @State private var showingDocumentPicker = false

  // Whether the photo picker sheet is showing.
  @State private var showingPhotoPicker = false

  // Sequential fade-in animation state.
  @State private var pencilIconVisible = false
  @State private var keyboardIconVisible = false
  @State private var paperclipIconVisible = false

  @State private var sendButtonVisible = false

  // Alert state for errors.
  @State private var showingError = false

  var body: some View {
    VStack(spacing: 0) {
      // Floating attachment menu (appears above toolbar).
      if viewModel.showingAttachmentMenu {
        VStack(spacing: 0) {
          Button {
            viewModel.showingAttachmentMenu = false
            showingPhotoPicker = true
          } label: {
            Label("Photo Library", systemImage: "photo.on.rectangle")
              .font(.system(size: 16))
              .foregroundStyle(NotebookPalette.ink)
              .frame(maxWidth: .infinity, alignment: .leading)
              .padding(.horizontal, 16)
              .padding(.vertical, 12)
              .contentShape(Rectangle())
          }

          Divider()

          Button {
            viewModel.showingAttachmentMenu = false
            showingDocumentPicker = true
          } label: {
            Label("Choose File", systemImage: "doc")
              .font(.system(size: 16))
              .foregroundStyle(NotebookPalette.ink)
              .frame(maxWidth: .infinity, alignment: .leading)
              .padding(.horizontal, 16)
              .padding(.vertical, 12)
              .contentShape(Rectangle())
          }
        }
        .frame(width: 220)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.15), radius: 12, y: -4)
        .padding(.bottom, 8)
        .transition(.opacity.combined(with: .scale(scale: 0.9, anchor: .bottom)))
        .accessibilityIdentifier("attachment_menu")
      }

      // Attachment preview grid (if any attachments).
      if !viewModel.attachments.isEmpty {
        AttachmentPreviewGrid(attachments: viewModel.attachments) { attachment in
          viewModel.removeAttachment(attachment)
        }
        .padding(.horizontal, NotebookSpacing.md)
        .padding(.bottom, NotebookSpacing.xs)
      }

      // Glass pill toolbar.
      glassPillToolbar
    }
    .accessibilityElement(children: .contain)
    .accessibilityIdentifier("canvas_input_bar")
    .photosPicker(
      isPresented: $showingPhotoPicker,
      selection: $selectedPhotos,
      maxSelectionCount: max(1, AttachmentLimits.maxFileCount - viewModel.attachments.count),
      matching: .any(of: [.images, .screenshots])
    )
    .sheet(isPresented: $showingDocumentPicker) {
      DocumentPickerView { urls in
        loadSelectedDocuments(urls)
      }
    }
    .onChange(of: selectedPhotos) { _, newItems in
      guard !newItems.isEmpty else { return }
      Task {
        await loadSelectedPhotos(newItems)
      }
    }
    .onAppear {
      // Sequential fade-in animation.
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

  private var glassPillToolbar: some View {
    // Read mode eagerly so @Observable tracks this dependency.
    let currentMode = viewModel.mode

    return HStack(spacing: 24) {
      // Pencil mode button.
      Image(systemName: "pencil.tip")
        .font(.system(size: 22, weight: .medium))
        .foregroundStyle(currentMode == .pencil ? Color.black : NotebookPalette.inkFaint)
        .frame(width: 44, height: 44)
        .contentShape(Rectangle())
        .onTapGesture {
          viewModel.switchToPencilMode()
        }
        .opacity(pencilIconVisible ? 1 : 0)
        .accessibilityLabel("Pencil mode")
        .accessibilityValue(currentMode == .pencil ? "selected" : "")
        .accessibilityIdentifier("pencil_mode_button")
        .accessibilityAddTraits(.isButton)

      // Keyboard mode button.
      Image(systemName: "keyboard")
        .font(.system(size: 22, weight: .medium))
        .foregroundStyle(currentMode == .keyboard ? Color.black : NotebookPalette.inkFaint)
        .frame(width: 44, height: 44)
        .contentShape(Rectangle())
        .onTapGesture {
          viewModel.switchToKeyboardMode()
        }
        .opacity(keyboardIconVisible ? 1 : 0)
        .accessibilityLabel("Keyboard mode")
        .accessibilityValue(currentMode == .keyboard ? "selected" : "")
        .accessibilityIdentifier("keyboard_mode_button")
        .accessibilityAddTraits(.isButton)

      // Paperclip attachment button.
      Image(systemName: "paperclip")
        .font(.system(size: 22, weight: .medium))
        .foregroundStyle(NotebookPalette.inkFaint)
        .frame(width: 44, height: 44)
        .contentShape(Rectangle())
        .onTapGesture {
          withAnimation(.easeOut(duration: 0.15)) {
            viewModel.showingAttachmentMenu.toggle()
          }
        }
        .opacity(paperclipIconVisible ? 1 : 0)
        .accessibilityLabel("Attach file")
        .accessibilityIdentifier("paperclip_button")

      // Send button.
      Button {
        submitInput()
      } label: {
        ZStack {
          Circle()
            .fill(viewModel.canSubmit ? Color.black : NotebookPalette.inkFaint)
            .frame(width: 36, height: 36)
          Image(systemName: "arrow.up")
            .font(.system(size: 16, weight: .bold))
            .foregroundStyle(.white)
        }
      }
      .disabled(!viewModel.canSubmit)
      .opacity(sendButtonVisible ? 1 : 0)
      .accessibilityLabel("Send")
      .accessibilityIdentifier("send_button")
    }
    .padding(.horizontal, 20)
    .padding(.vertical, 12)
    .glassEffect(.regular, in: .capsule)
  }

  private func submitInput() {
    guard viewModel.canSubmit else { return }

    viewModel.isSubmitting = true

    let response = viewModel.buildResponse()
    viewModel.clearAllInput()
    selectedPhotos = []

    onSubmit?(response)
  }

  private func loadSelectedPhotos(_ items: [PhotosPickerItem]) async {
    var newAttachments: [CanvasInputViewModel.AttachmentData] = []

    for item in items {
      if viewModel.attachments.contains(where: { $0.id == item.itemIdentifier ?? "" }) {
        continue
      }

      guard let data = try? await item.loadTransferable(type: Data.self) else {
        viewModel.currentError = .loadFailed(filename: "image")
        showingError = true
        continue
      }

      // Detect actual image format from magic bytes.
      let (mimeType, ext) = detectImageFormat(data)
      let timestamp = Int(Date().timeIntervalSince1970)

      newAttachments.append(
        CanvasInputViewModel.AttachmentData(
          data: data,
          filename: "image_\(timestamp).\(ext)",
          mimeType: mimeType
        ))
    }

    if let error = viewModel.addAttachments(newAttachments) {
      viewModel.currentError = error
      showingError = true
    }

    selectedPhotos = []
  }

  // Loads document files selected from the document picker.
  private func loadSelectedDocuments(_ urls: [URL]) {
    var newAttachments: [CanvasInputViewModel.AttachmentData] = []

    for url in urls {
      // Start accessing the security-scoped resource.
      guard url.startAccessingSecurityScopedResource() else {
        viewModel.currentError = .loadFailed(filename: url.lastPathComponent)
        showingError = true
        continue
      }
      defer { url.stopAccessingSecurityScopedResource() }

      guard let data = try? Data(contentsOf: url) else {
        viewModel.currentError = .loadFailed(filename: url.lastPathComponent)
        showingError = true
        continue
      }

      let mimeType = mimeTypeForURL(url)

      // Validate per-type size limits.
      let maxSize = AttachmentLimits.maxSizeForMimeType(mimeType)
      if data.count > maxSize {
        let sizeMB = Double(data.count) / (1024 * 1024)
        viewModel.currentError = .fileTooLarge(filename: url.lastPathComponent, sizeMB: sizeMB)
        showingError = true
        continue
      }

      newAttachments.append(
        CanvasInputViewModel.AttachmentData(
          data: data,
          filename: url.lastPathComponent,
          mimeType: mimeType
        ))
    }

    if !newAttachments.isEmpty {
      if let error = viewModel.addAttachments(newAttachments) {
        viewModel.currentError = error
        showingError = true
      }
    }
  }

  // Detects image format from magic bytes. Returns (mimeType, extension).
  private func detectImageFormat(_ data: Data) -> (String, String) {
    guard data.count >= 4 else { return ("image/png", "png") }

    let bytes = [UInt8](data.prefix(4))

    // JPEG: FF D8 FF
    if bytes[0] == 0xFF, bytes[1] == 0xD8, bytes[2] == 0xFF {
      return ("image/jpeg", "jpg")
    }

    // PNG: 89 50 4E 47
    if bytes[0] == 0x89, bytes[1] == 0x50, bytes[2] == 0x4E, bytes[3] == 0x47 {
      return ("image/png", "png")
    }

    // GIF: 47 49 46
    if bytes[0] == 0x47, bytes[1] == 0x49, bytes[2] == 0x46 {
      return ("image/gif", "gif")
    }

    // WebP: RIFF....WEBP
    if bytes[0] == 0x52, bytes[1] == 0x49, bytes[2] == 0x46, bytes[3] == 0x46,
      data.count >= 12
    {
      let webpBytes = [UInt8](data[8..<12])
      if webpBytes == [0x57, 0x45, 0x42, 0x50] {
        return ("image/webp", "webp")
      }
    }

    // HEIC: check for ftyp box with heic/heix brands
    if data.count >= 12 {
      let ftypBytes = [UInt8](data[4..<8])
      if ftypBytes == [0x66, 0x74, 0x79, 0x70] {
        return ("image/heic", "heic")
      }
    }

    // Default to PNG.
    return ("image/png", "png")
  }

  // Maps a file URL extension to a MIME type string.
  private func mimeTypeForURL(_ url: URL) -> String {
    let ext = url.pathExtension.lowercased()
    switch ext {
    case "pdf": return "application/pdf"
    case "png": return "image/png"
    case "jpg", "jpeg": return "image/jpeg"
    case "gif": return "image/gif"
    case "webp": return "image/webp"
    case "heic", "heif": return "image/heic"
    case "txt": return "text/plain"
    case "csv": return "text/plain"
    case "md": return "text/plain"
    case "json": return "text/plain"
    case "xml": return "text/plain"
    case "html", "htm": return "text/plain"
    case "swift", "py", "js", "ts", "java", "c", "cpp", "h", "hpp",
      "rb", "go", "rs", "kt", "m", "mm", "css", "scss", "yaml", "yml",
      "toml", "sh", "bash", "zsh":
      return "text/plain"
    default: return "application/octet-stream"
    }
  }
}

// MARK: - DocumentPickerView

// UIViewControllerRepresentable wrapper for UIDocumentPickerViewController.
// Supports picking PDFs, text files, and source code files.
struct DocumentPickerView: UIViewControllerRepresentable {
  // Callback with selected file URLs.
  var onPick: ([URL]) -> Void

  func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
    let types: [UTType] = [
      .pdf,
      .plainText,
      .commaSeparatedText,
      .json,
      .xml,
      .html,
      .sourceCode,
    ]

    let picker = UIDocumentPickerViewController(forOpeningContentTypes: types, asCopy: true)
    picker.allowsMultipleSelection = true
    picker.delegate = context.coordinator
    return picker
  }

  func updateUIViewController(_: UIDocumentPickerViewController, context _: Context) {}

  func makeCoordinator() -> Coordinator {
    Coordinator(onPick: onPick)
  }

  class Coordinator: NSObject, UIDocumentPickerDelegate {
    let onPick: ([URL]) -> Void

    init(onPick: @escaping ([URL]) -> Void) {
      self.onPick = onPick
    }

    func documentPicker(_: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
      onPick(urls)
    }
  }
}

// MARK: - Preview

#Preview {
  NotebookCanvasView(
    viewModel: NotebookViewModel(document: .sample)
  )
}

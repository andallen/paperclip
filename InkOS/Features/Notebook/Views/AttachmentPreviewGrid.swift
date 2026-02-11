//
// AttachmentPreviewGrid.swift
// InkOS
//
// Grid layout for attachment previews in the canvas input.
// Displays 80x80 rounded square thumbnails with 12pt spacing.
// Left-to-right flow with wrap to new row when full.
// Each preview has an X button to remove the attachment.
//

import SwiftUI

// MARK: - Constants

// File size limits based on industry standards.
enum AttachmentLimits {
  // Maximum size for a single file (20 MB).
  static let maxFileSizeBytes: Int = 20 * 1024 * 1024

  // Maximum total size for all attachments (50 MB).
  static let maxTotalSizeBytes: Int = 50 * 1024 * 1024

  // Maximum number of files per submission.
  static let maxFileCount: Int = 5

  // Preview thumbnail size.
  static let previewSize: CGFloat = 80

  // Spacing between previews.
  static let previewSpacing: CGFloat = 12

  // Corner radius for previews.
  static let previewCornerRadius: CGFloat = 12
}

// MARK: - AttachmentError

// Errors that can occur when adding attachments.
enum AttachmentError: LocalizedError {
  case fileTooLarge(filename: String, sizeMB: Double)
  case totalTooLarge(sizeMB: Double)
  case tooManyFiles(count: Int)
  case loadFailed(filename: String)

  var errorDescription: String? {
    switch self {
    case .fileTooLarge(let filename, let sizeMB):
      return "File too large (max 20 MB): \(filename) is \(String(format: "%.1f", sizeMB)) MB"
    case .totalTooLarge(let sizeMB):
      return
        "Total attachments too large (max 50 MB): currently \(String(format: "%.1f", sizeMB)) MB"
    case .tooManyFiles(let count):
      return "Maximum 5 files per message (\(count) selected)"
    case .loadFailed(let filename):
      return "Failed to load file: \(filename)"
    }
  }
}

// MARK: - AttachmentPreviewGrid

// Grid of attachment preview thumbnails.
// Uses FlowLayout for left-to-right wrapping.
struct AttachmentPreviewGrid: View {
  // Attachments to display.
  let attachments: [InputAttachment]

  // Callback to remove an attachment.
  let onRemove: (InputAttachment) -> Void

  var body: some View {
    if attachments.isEmpty {
      EmptyView()
    } else {
      LazyVGrid(
        columns: [
          GridItem(
            .adaptive(minimum: AttachmentLimits.previewSize, maximum: AttachmentLimits.previewSize))
        ],
        alignment: .leading,
        spacing: AttachmentLimits.previewSpacing
      ) {
        ForEach(attachments) { attachment in
          AttachmentPreview(attachment: attachment) {
            onRemove(attachment)
          }
        }
      }
      .padding(.vertical, NotebookSpacing.xs)
      .accessibilityIdentifier("attachment_preview_grid")
    }
  }
}

// MARK: - AttachmentPreview

// Single attachment preview thumbnail with remove button.
struct AttachmentPreview: View {
  let attachment: InputAttachment
  let onRemove: () -> Void

  var body: some View {
    ZStack(alignment: .topTrailing) {
      // Thumbnail content.
      thumbnailContent
        .frame(width: AttachmentLimits.previewSize, height: AttachmentLimits.previewSize)
        .clipShape(RoundedRectangle(cornerRadius: AttachmentLimits.previewCornerRadius))

      // Remove button.
      Button {
        withAnimation(.easeOut(duration: 0.2)) {
          onRemove()
        }
      } label: {
        Image(systemName: "xmark.circle.fill")
          .font(.system(size: 22))
          .symbolRenderingMode(.palette)
          .foregroundStyle(.white, Color.black.opacity(0.7))
      }
      .offset(x: 8, y: -8)
      .accessibilityLabel("Remove attachment")
    }
    .accessibilityIdentifier("attachment_preview_\(attachment.id)")
  }

  @ViewBuilder
  private var thumbnailContent: some View {
    if attachment.mimeType.hasPrefix("image/"), let image = UIImage(data: attachment.data) {
      // Image thumbnail.
      Image(uiImage: image)
        .resizable()
        .aspectRatio(contentMode: .fill)
    } else {
      // Document placeholder.
      documentPlaceholder
    }
  }

  private var documentPlaceholder: some View {
    ZStack {
      RoundedRectangle(cornerRadius: AttachmentLimits.previewCornerRadius)
        .fill(NotebookPalette.inkFaint.opacity(0.15))

      VStack(spacing: 4) {
        Image(systemName: documentIcon)
          .font(.system(size: 24))
          .foregroundColor(NotebookPalette.inkSubtle)

        Text(fileExtension)
          .font(NotebookTypography.caption)
          .foregroundColor(NotebookPalette.inkSubtle)
          .lineLimit(1)
      }
    }
  }

  // Returns appropriate icon based on MIME type.
  private var documentIcon: String {
    switch attachment.mimeType {
    case "application/pdf":
      return "doc.fill"
    case let type where type.hasPrefix("text/"):
      return "doc.text.fill"
    default:
      return "doc.fill"
    }
  }

  // Extracts file extension from filename.
  private var fileExtension: String {
    let components = attachment.filename.split(separator: ".")
    if components.count > 1, let ext = components.last {
      return String(ext).uppercased()
    }
    return "FILE"
  }
}

// MARK: - Preview

#Preview("Attachment Grid - Images") {
  guard let sampleImage = UIImage(systemName: "photo.fill"),
    let imageData = sampleImage.pngData()
  else {
    return Text("Preview failed to load")
  }

  let attachments = [
    InputAttachment(id: "1", filename: "photo1.png", mimeType: "image/png", data: imageData),
    InputAttachment(id: "2", filename: "photo2.png", mimeType: "image/png", data: imageData),
    InputAttachment(id: "3", filename: "photo3.png", mimeType: "image/png", data: imageData)
  ]

  return AttachmentPreviewGrid(attachments: attachments) { attachment in
    print("Remove: \(attachment.filename)")
  }
  .padding()
  .background(NotebookPalette.paper)
}

#Preview("Attachment Grid - Mixed") {
  guard let sampleImage = UIImage(systemName: "photo.fill"),
    let imageData = sampleImage.pngData()
  else {
    return Text("Preview failed to load")
  }

  let attachments = [
    InputAttachment(id: "1", filename: "photo.png", mimeType: "image/png", data: imageData),
    InputAttachment(id: "2", filename: "document.pdf", mimeType: "application/pdf", data: Data()),
    InputAttachment(id: "3", filename: "notes.txt", mimeType: "text/plain", data: Data())
  ]

  return AttachmentPreviewGrid(attachments: attachments) { attachment in
    print("Remove: \(attachment.filename)")
  }
  .padding()
  .background(NotebookPalette.paper)
}

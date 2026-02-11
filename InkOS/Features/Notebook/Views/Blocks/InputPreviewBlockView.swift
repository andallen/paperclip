//
// InputPreviewBlockView.swift
// InkOS
//
// Temporary preview block for submitted user input.
// Shows handwriting image, typed text, and attachment thumbnails.
// Distinct visual style with light border to indicate it's user content.
// Will be replaced with AI processing results in the future.
//

import SwiftUI

// MARK: - InputPreviewBlockView

// Displays submitted user input for visual confirmation.
// Used before AI integration to show what was captured.
struct InputPreviewBlockView: View {
  // The submitted input response.
  let response: InputResponse

  // Timestamp for display.
  let timestamp: Date

  var body: some View {
    VStack(alignment: .leading, spacing: NotebookSpacing.sm) {
      // Header with "Sent" label and timestamp.
      header

      // Handwriting image if present.
      if let handwritingData = response.handwritingImageData,
        let image = UIImage(data: handwritingData) {
        handwritingView(image: image)
      }

      // Typed text if present.
      if let text = response.text, !text.isEmpty {
        textView(text: text)
      }

      // Attachments if present.
      if let attachments = response.attachments, !attachments.isEmpty {
        attachmentsView(attachments: attachments)
      }
    }
    .padding(NotebookSpacing.md)
    .background(
      RoundedRectangle(cornerRadius: 16)
        .fill(NotebookPalette.paper)
        .overlay(
          RoundedRectangle(cornerRadius: 16)
            .strokeBorder(NotebookPalette.inkFaint.opacity(0.3), lineWidth: 1)
        )
    )
    .accessibilityIdentifier("input_preview_block")
  }

  // MARK: - Subviews

  private var header: some View {
    HStack {
      Text("Sent")
        .font(NotebookTypography.caption)
        .foregroundColor(NotebookPalette.inkSubtle)

      Spacer()

      Text(formattedTime)
        .font(NotebookTypography.caption)
        .foregroundColor(NotebookPalette.inkFaint)
    }
  }

  private func handwritingView(image: UIImage) -> some View {
    Image(uiImage: image)
      .resizable()
      .aspectRatio(contentMode: .fit)
      .frame(maxWidth: .infinity)
      .background(Color.white)
      .clipShape(RoundedRectangle(cornerRadius: 8))
      .overlay(
        RoundedRectangle(cornerRadius: 8)
          .strokeBorder(NotebookPalette.inkFaint.opacity(0.2), lineWidth: 1)
      )
      .accessibilityLabel("Handwriting")
  }

  private func textView(text: String) -> some View {
    Text(text)
      .font(NotebookTypography.body)
      .foregroundColor(NotebookPalette.ink)
      .frame(maxWidth: .infinity, alignment: .leading)
  }

  private func attachmentsView(attachments: [InputAttachment]) -> some View {
    VStack(alignment: .leading, spacing: NotebookSpacing.xs) {
      Text("Attachments")
        .font(NotebookTypography.caption)
        .foregroundColor(NotebookPalette.inkSubtle)

      HStack(spacing: AttachmentLimits.previewSpacing) {
        ForEach(attachments) { attachment in
          smallThumbnail(for: attachment)
        }
      }
    }
  }

  private func smallThumbnail(for attachment: InputAttachment) -> some View {
    Group {
      if attachment.mimeType.hasPrefix("image/"), let image = UIImage(data: attachment.data) {
        Image(uiImage: image)
          .resizable()
          .aspectRatio(contentMode: .fill)
      } else {
        Image(systemName: "doc.fill")
          .font(.system(size: 20))
          .foregroundColor(NotebookPalette.inkSubtle)
          .frame(maxWidth: .infinity, maxHeight: .infinity)
          .background(NotebookPalette.inkFaint.opacity(0.1))
      }
    }
    .frame(width: 48, height: 48)
    .clipShape(RoundedRectangle(cornerRadius: 8))
  }

  // MARK: - Helpers

  private var formattedTime: String {
    let formatter = DateFormatter()
    formatter.timeStyle = .short
    return formatter.string(from: timestamp)
  }
}

// MARK: - Preview

#Preview("Input Preview - Text Only") {
  InputPreviewBlockView(
    response: InputResponse(text: "This is a test message that I typed using the keyboard."),
    timestamp: Date()
  )
  .padding()
  .background(NotebookPalette.paper)
}

#Preview("Input Preview - All Content") {
  guard let sampleImage = UIImage(systemName: "scribble"),
    let handwritingData = sampleImage.pngData()
  else {
    return Text("Preview failed to load")
  }

  let attachments = [
    InputAttachment(id: "1", filename: "photo.png", mimeType: "image/png", data: handwritingData),
    InputAttachment(id: "2", filename: "doc.pdf", mimeType: "application/pdf", data: Data())
  ]

  return InputPreviewBlockView(
    response: InputResponse(
      text: "Here's what I drew and some files.",
      handwritingImageData: handwritingData,
      attachments: attachments
    ),
    timestamp: Date()
  )
  .padding()
  .background(NotebookPalette.paper)
}

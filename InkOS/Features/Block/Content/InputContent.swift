//
// InputContent.swift
// InkOS
//
// Data types for user input responses.
// Used by the persistent canvas input to capture text, handwriting, and attachments.
//

import Foundation

// MARK: - CanvasTextBox

// A floating text box on the freeform canvas.
// Positioned at arbitrary coordinates, draggable and editable.
struct CanvasTextBox: Identifiable, Sendable, Codable, Equatable {
  let id: UUID
  var text: String
  // Top-left corner in canvas coordinates.
  var position: CGPoint
  // Width is fixed at 280; height grows with content.
  var size: CGSize

  static func new(at position: CGPoint) -> CanvasTextBox {
    CanvasTextBox(
      id: UUID(),
      text: "",
      position: position,
      size: CGSize(width: 280, height: 44)
    )
  }
}

// MARK: - InputSegment

// An ordered chunk of user input for structured (non-interleaved) submissions.
// Case 3: text and drawing regions are spatially separated on the canvas.
enum InputSegment: Sendable, Codable, Equatable {
  // A text segment from one or more text boxes.
  case text(String)
  // A cropped drawing region as PNG data.
  case drawing(Data)
}

// MARK: - InputResponse

// The user's response from the canvas input.
// Can contain text, handwriting images, ordered segments, and/or file attachments.
struct InputResponse: Sendable, Codable, Equatable {
  // Text input from user.
  let text: String?

  // First handwriting image for backward compatibility.
  let handwritingImageData: Data?

  // All handwriting images from drawing blocks.
  let handwritingImages: [Data]?

  // Ordered segments for structured canvas submissions (text + drawing regions).
  let segments: [InputSegment]?

  // File/image attachments.
  let attachments: [InputAttachment]?

  private enum CodingKeys: String, CodingKey {
    case text
    case handwritingImageData = "handwriting_image_data"
    case handwritingImages = "handwriting_images"
    case segments
    case attachments
  }

  init(
    text: String? = nil,
    handwritingImageData: Data? = nil,
    handwritingImages: [Data]? = nil,
    segments: [InputSegment]? = nil,
    attachments: [InputAttachment]? = nil
  ) {
    self.text = text
    // Use explicit first image, or fall back to first from handwritingImages.
    self.handwritingImageData = handwritingImageData ?? handwritingImages?.first
    self.handwritingImages = handwritingImages
    self.segments = segments
    self.attachments = attachments
  }

  // Whether the response has any content.
  var isEmpty: Bool {
    let hasText = text != nil && !text!.isEmpty
    let hasHandwriting = handwritingImageData != nil
    let hasImages = handwritingImages != nil && !handwritingImages!.isEmpty
    let hasSegments = segments != nil && !segments!.isEmpty
    let hasAttachments = attachments != nil && !attachments!.isEmpty
    return !hasText && !hasHandwriting && !hasImages && !hasSegments && !hasAttachments
  }

  // Convenience initializer for text-only response.
  static func text(_ text: String) -> InputResponse {
    InputResponse(text: text)
  }

  // Convenience initializer for handwriting-only response.
  static func handwriting(_ imageData: Data) -> InputResponse {
    InputResponse(handwritingImageData: imageData)
  }
}

// MARK: - InputAttachment

// A file or image attachment in the input response.
struct InputAttachment: Sendable, Codable, Equatable, Identifiable {
  // Unique identifier for this attachment.
  let id: String

  // Original filename.
  let filename: String

  // MIME type (e.g., "image/png", "application/pdf").
  let mimeType: String

  // File data.
  let data: Data

  private enum CodingKeys: String, CodingKey {
    case id
    case filename
    case mimeType = "mime_type"
    case data
  }

  init(id: String = UUID().uuidString, filename: String, mimeType: String, data: Data) {
    self.id = id
    self.filename = filename
    self.mimeType = mimeType
    self.data = data
  }
}

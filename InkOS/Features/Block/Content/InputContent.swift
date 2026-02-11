//
// InputContent.swift
// InkOS
//
// Data types for user input responses.
// Used by the persistent canvas input to capture text, handwriting, and attachments.
//

import Foundation

// MARK: - InputResponse

// The user's response from the canvas input.
// Can contain text, handwriting image, and/or file attachments.
struct InputResponse: Sendable, Codable, Equatable {
  // Text input from user.
  let text: String?

  // Handwriting captured as PNG image data (PencilKit screenshot).
  let handwritingImageData: Data?

  // File/image attachments.
  let attachments: [InputAttachment]?

  private enum CodingKeys: String, CodingKey {
    case text
    case handwritingImageData = "handwriting_image_data"
    case attachments
  }

  init(
    text: String? = nil,
    handwritingImageData: Data? = nil,
    attachments: [InputAttachment]? = nil
  ) {
    self.text = text
    self.handwritingImageData = handwritingImageData
    self.attachments = attachments
  }

  // Whether the response has any content.
  var isEmpty: Bool {
    let hasText = text != nil && !text!.isEmpty
    let hasHandwriting = handwritingImageData != nil
    let hasAttachments = attachments != nil && !attachments!.isEmpty
    return !hasText && !hasHandwriting && !hasAttachments
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

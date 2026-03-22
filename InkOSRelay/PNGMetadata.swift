//
// PNGMetadata.swift
// InkOSRelay
//
// PNG metadata marker detection for the Mac companion.
// Mirrors the iPad app's PNGMetadata utility.
//

import ImageIO
import UniformTypeIdentifiers

enum PNGMetadata {
  // The marker string embedded in PNG metadata by the iPad app.
  static let marker = "InkOS-v1"

  // Checks whether the given PNG data contains the InkOS marker.
  static func isInkOSImage(_ pngData: Data) -> Bool {
    guard let source = CGImageSourceCreateWithData(pngData as CFData, nil) else {
      return false
    }

    guard let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil)
      as? [String: Any]
    else {
      return false
    }

    guard let pngDict = properties[kCGImagePropertyPNGDictionary as String]
      as? [String: Any]
    else {
      return false
    }

    let description = pngDict[kCGImagePropertyPNGDescription as String] as? String
    return description == marker
  }
}

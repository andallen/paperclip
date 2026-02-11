//
// EmbedContent.swift
// InkOS
//
// Embedded web content rendered via WKWebView.
// Backend constructs complete URLs; iOS just displays them.
//

import Foundation

// MARK: - EmbedContent

// Embedded web content. Backend provides complete URLs.
struct EmbedContent: Sendable, Codable, Equatable {
  // Complete URL to embed. Required.
  let url: String

  // Provider hint for display/analytics (e.g., "youtube", "desmos", "phet").
  let provider: String?

  // Sizing options.
  let sizing: EmbedSizing?

  // Optional caption displayed below the embed.
  let caption: String?

  // Whether to allow fullscreen mode.
  let allowFullscreen: Bool

  private enum CodingKeys: String, CodingKey {
    case url
    case provider
    case sizing
    case caption
    case allowFullscreen = "allow_fullscreen"
  }

  init(
    url: String,
    provider: String? = nil,
    sizing: EmbedSizing? = nil,
    caption: String? = nil,
    allowFullscreen: Bool = true
  ) {
    self.url = url
    self.provider = provider
    self.sizing = sizing
    self.caption = caption
    self.allowFullscreen = allowFullscreen
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.url = try container.decode(String.self, forKey: .url)
    self.provider = try container.decodeIfPresent(String.self, forKey: .provider)
    self.sizing = try container.decodeIfPresent(EmbedSizing.self, forKey: .sizing)
    self.caption = try container.decodeIfPresent(String.self, forKey: .caption)
    self.allowFullscreen =
      try container.decodeIfPresent(Bool.self, forKey: .allowFullscreen) ?? true
  }

  // Convenience initializer for simple URL embeds.
  static func url(_ src: String, provider: String? = nil, caption: String? = nil) -> EmbedContent {
    EmbedContent(url: src, provider: provider, caption: caption)
  }
}

// MARK: - EmbedSizing

// Sizing options for embed blocks.
struct EmbedSizing: Sendable, Codable, Equatable {
  // Width (e.g., "100%", "400px").
  let width: String

  // Fixed height in points.
  let height: Double?

  // Aspect ratio (width / height). Used if height is nil.
  let aspectRatio: Double?

  private enum CodingKeys: String, CodingKey {
    case width
    case height
    case aspectRatio = "aspect_ratio"
  }

  init(width: String = "100%", height: Double? = nil, aspectRatio: Double? = nil) {
    self.width = width
    self.height = height
    self.aspectRatio = aspectRatio
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.width = try container.decodeIfPresent(String.self, forKey: .width) ?? "100%"
    self.height = try container.decodeIfPresent(Double.self, forKey: .height)
    self.aspectRatio = try container.decodeIfPresent(Double.self, forKey: .aspectRatio)
  }
}

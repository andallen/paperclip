//
// ImageLoader.swift
// InkOS
//
// Async image loader with caching for ImageBlockView.
// Handles URL, base64, library, and generated image sources.
//

import SwiftUI

// MARK: - ImageLoadingState

// Loading states for image content.
enum ImageLoadingState: Equatable {
  case loading
  case loaded(UIImage)
  case failed(ImageLoadError)

  static func == (lhs: ImageLoadingState, rhs: ImageLoadingState) -> Bool {
    switch (lhs, rhs) {
    case (.loading, .loading):
      return true
    case (.loaded(let lhsImage), .loaded(let rhsImage)):
      return lhsImage === rhsImage
    case (.failed(let lhsError), .failed(let rhsError)):
      return lhsError == rhsError
    default:
      return false
    }
  }
}

// MARK: - ImageLoadError

// Errors that can occur during image loading.
enum ImageLoadError: Equatable {
  case invalidURL
  case networkError
  case decodingError
  case generationPending
}

// MARK: - ImageLoader

// Observable async image loader with caching.
@Observable
final class ImageLoader {
  private(set) var state: ImageLoadingState = .loading

  // Shared cache across all loaders (50MB limit).
  private static let cache: NSCache<NSString, UIImage> = {
    let cache = NSCache<NSString, UIImage>()
    cache.totalCostLimit = 50 * 1024 * 1024
    return cache
  }()

  // Load image from source.
  func load(source: ImageSource) async {
    state = .loading

    switch source {
    case .url(let url):
      await loadFromURL(url)

    case .base64(let data, _):
      loadFromBase64(data)

    case .library(let libraryId):
      // Library IDs are URLs in this system.
      await loadFromURL(libraryId)

    case .generated(_, let resultUrl, _):
      if let url = resultUrl {
        await loadFromURL(url)
      } else {
        state = .failed(.generationPending)
      }
    }
  }

  // Load from URL with caching.
  private func loadFromURL(_ urlString: String) async {
    let cacheKey = urlString as NSString

    // Check cache first.
    if let cached = Self.cache.object(forKey: cacheKey) {
      state = .loaded(cached)
      return
    }

    // Validate URL.
    guard let url = URL(string: urlString) else {
      state = .failed(.invalidURL)
      return
    }

    // Fetch from network.
    do {
      let (data, _) = try await URLSession.shared.data(from: url)

      guard let image = UIImage(data: data) else {
        state = .failed(.decodingError)
        return
      }

      // Cache the image.
      let cost = data.count
      Self.cache.setObject(image, forKey: cacheKey, cost: cost)

      state = .loaded(image)
    } catch {
      state = .failed(.networkError)
    }
  }

  // Load from base64 data.
  private func loadFromBase64(_ base64String: String) {
    guard let data = Data(base64Encoded: base64String),
          let image = UIImage(data: data) else {
      state = .failed(.decodingError)
      return
    }

    state = .loaded(image)
  }
}

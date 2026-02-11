//
// ImageErrorView.swift
// InkOS
//
// Error state display for failed image loads.
//

import SwiftUI

// MARK: - ImageErrorView

// Displays error state when image loading fails.
struct ImageErrorView: View {
  let error: ImageLoadError
  let cornerRadius: CGFloat

  var body: some View {
    RoundedRectangle(cornerRadius: cornerRadius)
      .fill(NotebookPalette.inkFaint.opacity(0.06))
      .overlay {
        VStack(spacing: 8) {
          Image(systemName: iconName)
            .font(.system(size: 28))
            .foregroundColor(NotebookPalette.inkFaint)

          Text(message)
            .font(NotebookTypography.caption)
            .foregroundColor(NotebookPalette.inkSubtle)
            .multilineTextAlignment(.center)
        }
        .padding()
      }
      .frame(minHeight: 100)
  }

  // Icon based on error type.
  private var iconName: String {
    switch error {
    case .invalidURL:
      return "link.badge.plus"
    case .networkError:
      return "wifi.slash"
    case .decodingError:
      return "photo.badge.exclamationmark"
    case .generationPending:
      return "sparkles"
    }
  }

  // Message based on error type.
  private var message: String {
    switch error {
    case .invalidURL:
      return "Invalid image URL"
    case .networkError:
      return "Could not load image"
    case .decodingError:
      return "Could not decode image"
    case .generationPending:
      return "Image being generated..."
    }
  }
}

// MARK: - Preview

#Preview {
  VStack(spacing: 20) {
    ImageErrorView(error: .invalidURL, cornerRadius: 8)
    ImageErrorView(error: .networkError, cornerRadius: 8)
    ImageErrorView(error: .decodingError, cornerRadius: 8)
    ImageErrorView(error: .generationPending, cornerRadius: 12)
  }
  .padding()
  .background(NotebookPalette.paper)
}

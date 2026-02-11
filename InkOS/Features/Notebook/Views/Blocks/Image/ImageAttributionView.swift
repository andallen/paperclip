//
// ImageAttributionView.swift
// InkOS
//
// Attribution display for image sources.
//

import SwiftUI

// MARK: - ImageAttributionView

// Displays source attribution below an image.
struct ImageAttributionView: View {
  let attribution: ImageAttribution

  var body: some View {
    if let text = formattedText {
      Text(text)
        .font(NotebookTypography.caption)
        .foregroundColor(NotebookPalette.inkFaint)
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
    }
  }

  // Format: "Source (License)" or just "Source" or just "License".
  private var formattedText: String? {
    switch (attribution.source, attribution.license) {
    case (let source?, let license?):
      return "\(source) (\(license))"
    case (let source?, nil):
      return source
    case (nil, let license?):
      return license
    case (nil, nil):
      return nil
    }
  }
}

// MARK: - Preview

#Preview {
  VStack(spacing: 20) {
    ImageAttributionView(attribution: ImageAttribution(
      source: "NASA",
      url: "https://nasa.gov",
      license: "Public Domain"
    ))

    ImageAttributionView(attribution: ImageAttribution(
      source: "OpenStax Biology",
      license: "CC BY 4.0"
    ))

    ImageAttributionView(attribution: ImageAttribution(
      source: "Unsplash"
    ))

    ImageAttributionView(attribution: ImageAttribution(
      license: "CC0"
    ))
  }
  .padding()
  .background(NotebookPalette.paper)
}

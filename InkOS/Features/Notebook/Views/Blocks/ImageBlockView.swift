//
// ImageBlockView.swift
// InkOS
//
// Renders image blocks with support for URL, base64, library, and generated sources.
// Includes skeleton loading, sizing modes, borders, captions, and attribution.
//

import SwiftUI

// MARK: - ImageBlockView

// Main view for rendering image blocks.
struct ImageBlockView: View {
  let content: ImageContent

  @State private var loader = ImageLoader()

  var body: some View {
    VStack(spacing: 8) {
      GeometryReader { geometry in
        HStack {
          Spacer()
          ImageContainerView(
            state: loader.state,
            content: content,
            containerWidth: geometry.size.width
          )
          Spacer()
        }
      }
      .aspectRatio(aspectRatio, contentMode: .fit)
      .frame(minHeight: 120)

      if let caption = content.caption {
        ImageCaptionView(caption: caption)
      }

      if let attribution = content.attribution {
        ImageAttributionView(attribution: attribution)
      }
    }
    .padding(.vertical, 16)
    .task {
      await loader.load(source: content.source)
    }
  }

  // Default aspect ratio for skeleton/error states.
  private var aspectRatio: CGFloat {
    if let ratio = content.sizing?.aspectRatio, ratio > 0 {
      return CGFloat(ratio)
    }

    // Use loaded image's natural ratio if available.
    if case .loaded(let image) = loader.state {
      return image.size.width / image.size.height
    }

    // Default 16:9 for loading/error states.
    return 16.0 / 9.0
  }
}

// MARK: - ImageContainerView

// Routes to appropriate view based on loading state.
private struct ImageContainerView: View {
  let state: ImageLoadingState
  let content: ImageContent
  let containerWidth: CGFloat

  var body: some View {
    switch state {
    case .loading:
      ImageSkeletonView(cornerRadius: cornerRadius)

    case .loaded(let image):
      ImageDisplayView(
        image: image,
        sizing: content.sizing,
        border: content.border,
        altText: content.altText,
        containerWidth: containerWidth
      )

    case .failed(let error):
      ImageErrorView(error: error, cornerRadius: cornerRadius)
    }
  }

  private var cornerRadius: CGFloat {
    CGFloat(content.border?.radius ?? 8)
  }
}

// MARK: - Preview

#Preview("URL Source") {
  ScrollView {
    VStack(spacing: 32) {
      ImageBlockView(content: ImageContent(
        source: .url(url: "https://picsum.photos/800/600"),
        altText: "Random landscape photo",
        caption: "A beautiful landscape from Lorem Picsum",
        attribution: ImageAttribution(source: "Lorem Picsum", license: "Free to use")
      ))

      ImageBlockView(content: ImageContent(
        source: .url(url: "https://picsum.photos/400/400"),
        sizing: ImageSizing(mode: .fit, maxWidth: 0.5),
        border: ImageBorder(enabled: true, color: "#3366CC", width: 2, radius: 16)
      ))
    }
    .padding()
  }
  .background(NotebookPalette.paper)
}

#Preview("Error States") {
  ScrollView {
    VStack(spacing: 32) {
      ImageBlockView(content: ImageContent(
        source: .url(url: "invalid-url"),
        caption: "This will show an error"
      ))

      ImageBlockView(content: ImageContent(
        source: .generated(prompt: "A cat", resultUrl: nil, model: nil),
        caption: "Waiting for generation"
      ))
    }
    .padding()
  }
  .background(NotebookPalette.paper)
}

#Preview("Sizing Modes") {
  ScrollView {
    VStack(spacing: 32) {
      Text("Fit (default)").font(NotebookTypography.caption)
      ImageBlockView(content: ImageContent(
        source: .url(url: "https://picsum.photos/800/400"),
        sizing: ImageSizing(mode: .fit)
      ))

      Text("Fill").font(NotebookTypography.caption)
      ImageBlockView(content: ImageContent(
        source: .url(url: "https://picsum.photos/800/400"),
        sizing: ImageSizing(mode: .fill, aspectRatio: 1.0)
      ))

      Text("50% width").font(NotebookTypography.caption)
      ImageBlockView(content: ImageContent(
        source: .url(url: "https://picsum.photos/800/400"),
        sizing: ImageSizing(mode: .fit, maxWidth: 0.5)
      ))
    }
    .padding()
  }
  .background(NotebookPalette.paper)
}

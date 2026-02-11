//
// ImageDisplayView.swift
// InkOS
//
// Renders a loaded UIImage with sizing mode and optional border.
//

import SwiftUI

// MARK: - ImageDisplayView

// Displays a loaded image with sizing and border options.
struct ImageDisplayView: View {
  let image: UIImage
  let sizing: ImageSizing?
  let border: ImageBorder?
  let altText: String?
  let containerWidth: CGFloat

  var body: some View {
    Image(uiImage: image)
      .resizable()
      .aspectRatio(contentMode: contentMode)
      .if(sizing?.aspectRatio != nil) { view in
        view.aspectRatio(CGFloat(sizing!.aspectRatio!), contentMode: contentMode)
      }
      .frame(maxWidth: maxWidth)
      .if(sizingMode == .fill) { view in
        view.clipped()
      }
      .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
      .if(borderEnabled) { view in
        view.overlay(
          RoundedRectangle(cornerRadius: cornerRadius)
            .strokeBorder(borderColor, lineWidth: borderWidth)
        )
      }
      .accessibilityLabel(altText ?? "Image")
  }

  // MARK: - Sizing

  private var sizingMode: ImageSizingMode {
    sizing?.mode ?? .fit
  }

  private var contentMode: ContentMode {
    switch sizingMode {
    case .fit, .original:
      return .fit
    case .fill:
      return .fill
    }
  }

  private var maxWidth: CGFloat? {
    let fraction = max(0.1, min(1.0, sizing?.maxWidth ?? 1.0))
    return containerWidth * CGFloat(fraction)
  }

  // MARK: - Border

  private var borderEnabled: Bool {
    border?.enabled ?? false
  }

  private var cornerRadius: CGFloat {
    CGFloat(border?.radius ?? 8)
  }

  private var borderWidth: CGFloat {
    CGFloat(border?.width ?? 1)
  }

  private var borderColor: Color {
    if let hexColor = border?.color {
      return Color(hex: hexColor) ?? NotebookPalette.inkFaint
    }
    return NotebookPalette.inkFaint
  }
}

// MARK: - View Extension

extension View {
  // Conditional view modifier.
  @ViewBuilder
  func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
    if condition {
      transform(self)
    } else {
      self
    }
  }
}

// MARK: - Preview

#Preview {
  VStack(spacing: 20) {
    // Sample with system image converted to UIImage.
    if let image = UIImage(systemName: "photo.fill") {
      ImageDisplayView(
        image: image,
        sizing: ImageSizing(mode: .fit, maxWidth: 0.8),
        border: ImageBorder(enabled: true, color: "#CCCCCC", width: 2, radius: 12),
        altText: "Sample image",
        containerWidth: 300
      )
      .frame(height: 200)

      ImageDisplayView(
        image: image,
        sizing: nil,
        border: nil,
        altText: nil,
        containerWidth: 300
      )
      .frame(height: 150)
    }
  }
  .padding()
  .background(NotebookPalette.paper)
}

//
// ImageCaptionView.swift
// InkOS
//
// Caption text displayed below images.
//

import SwiftUI

// MARK: - ImageCaptionView

// Displays caption text below an image.
struct ImageCaptionView: View {
  let caption: String

  var body: some View {
    Text(caption)
      .font(NotebookTypography.caption)
      .foregroundColor(NotebookPalette.inkSubtle)
      .multilineTextAlignment(.center)
      .frame(maxWidth: .infinity)
  }
}

// MARK: - Preview

#Preview {
  VStack(spacing: 20) {
    ImageCaptionView(caption: "A beautiful sunset over the mountains")
    ImageCaptionView(caption: "Figure 1: Diagram showing the cell structure")
  }
  .padding()
  .background(NotebookPalette.paper)
}

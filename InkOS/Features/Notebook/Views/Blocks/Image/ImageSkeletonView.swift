//
// ImageSkeletonView.swift
// InkOS
//
// Pulsing skeleton placeholder shown while images load.
//

import SwiftUI

// MARK: - ImageSkeletonView

// Skeleton placeholder for loading images.
struct ImageSkeletonView: View {
  let cornerRadius: CGFloat

  @State private var isPulsing = false

  var body: some View {
    RoundedRectangle(cornerRadius: cornerRadius)
      .fill(NotebookPalette.inkFaint.opacity(isPulsing ? 0.12 : 0.08))
      .overlay {
        Image(systemName: "photo")
          .font(.system(size: 32))
          .foregroundColor(NotebookPalette.inkFaint.opacity(0.4))
      }
      .frame(minHeight: 120)
      .animation(
        .easeInOut(duration: 0.8).repeatForever(autoreverses: true),
        value: isPulsing
      )
      .onAppear {
        isPulsing = true
      }
  }
}

// MARK: - Preview

#Preview {
  VStack(spacing: 20) {
    ImageSkeletonView(cornerRadius: 8)
      .frame(height: 200)

    ImageSkeletonView(cornerRadius: 16)
      .frame(height: 150)
  }
  .padding()
  .background(NotebookPalette.paper)
}

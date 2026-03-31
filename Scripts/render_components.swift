#!/usr/bin/env swift

// Renders the send button and sent toast as standalone PNGs.
// Uses SwiftUI ImageRenderer on macOS — material/glass effects
// are approximated with solid fills since there's no compositing window.

import SwiftUI
import AppKit

// MARK: - Color Tokens (mirrored from NotebookDesignTokens)

let inkColor = Color(red: 0.12, green: 0.11, blue: 0.10)

// MARK: - Send Button

struct SendButton: View {
  var body: some View {
    HStack(spacing: 6) {
      Image(systemName: "paperplane.fill")
        .font(.system(size: 16, weight: .medium))
      Text("Send")
        .font(.system(size: 15, weight: .semibold))
    }
    .foregroundColor(.white)
    .padding(.horizontal, 20)
    .padding(.vertical, 10)
    .background(
      Capsule()
        .fill(inkColor)
    )
  }
}

// MARK: - Sent Toast

struct SentToast: View {
  var body: some View {
    HStack(spacing: 8) {
      Image(systemName: "checkmark.circle.fill")
        .foregroundColor(.green)
      Text("Sent")
        .font(.system(size: 15, weight: .medium))
        .foregroundColor(inkColor)
    }
    .padding(.horizontal, 20)
    .padding(.vertical, 10)
    .background(
      Capsule()
        .fill(Color(nsColor: .controlBackgroundColor).opacity(0.85))
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
    )
  }
}

// MARK: - Sidebar

// Standalone sidebar rendering with fake note data.
struct SidebarRender: View {
  // Fake note names that feel realistic.
  let notes = [
    "Meeting notes 3/28",
    "API design sketch",
    "Shopping list",
    "Weekly standup",
    "Recipe — pasta sauce",
    "Gift ideas for Dad",
    "Project timeline",
    "Quick math",
    "Letter to Mom",
    "Book recommendations",
    "Workout plan",
  ]

  // Index of the "active" note (highlighted).
  let activeIndex = 0

  // Color tokens.
  let paper = Color(red: 0.97, green: 0.97, blue: 0.96)
  let inkFaint = Color(red: 0.55, green: 0.53, blue: 0.50)

  var body: some View {
    VStack(spacing: 0) {
      // Top bar: search, compose, hamburger.
      topBar
        .padding(.horizontal, 14)
        .padding(.top, 14)
        .padding(.bottom, 10)

      // Note list.
      VStack(spacing: 2) {
        ForEach(Array(notes.enumerated()), id: \.offset) { index, title in
          noteRow(title: title, isActive: index == activeIndex)
        }
      }
      .padding(.horizontal, 8)

      Spacer(minLength: 0)
    }
    .frame(width: 340, height: 1000)
    .background(
      RoundedRectangle(cornerRadius: 16, style: .continuous)
        .fill(paper)
    )
    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    .shadow(color: .black.opacity(0.15), radius: 12, x: 4, y: 0)
  }

  // Search field + compose + hamburger.
  private var topBar: some View {
    HStack(spacing: 10) {
      // Search field.
      HStack(spacing: 8) {
        Image(systemName: "magnifyingglass")
          .font(.system(size: 14))
          .foregroundColor(inkFaint)
        Text("Search")
          .font(.system(size: 17, weight: .regular, design: .rounded))
          .foregroundColor(inkFaint)
        Spacer()
      }
      .padding(.horizontal, 12)
      .padding(.vertical, 8)
      .background(
        Capsule()
          .fill(Color.gray.opacity(0.06))
      )
      .overlay(
        Capsule()
          .stroke(inkFaint.opacity(0.2), lineWidth: 1)
      )

      // Compose button.
      Image(systemName: "square.and.pencil")
        .font(.system(size: 18, weight: .medium))
        .foregroundColor(inkColor)
        .frame(width: 32, height: 32)

      // Hamburger close.
      VStack(alignment: .leading, spacing: 5) {
        RoundedRectangle(cornerRadius: 1.5)
          .fill(inkColor)
          .frame(width: 22, height: 2.5)
        RoundedRectangle(cornerRadius: 1.5)
          .fill(inkColor)
          .frame(width: 16, height: 2.5)
      }
      .frame(width: 32, height: 32)
    }
  }

  // Single note row.
  private func noteRow(title: String, isActive: Bool) -> some View {
    HStack {
      Text(title)
        .font(.system(size: 17, weight: .regular, design: .rounded))
        .foregroundColor(inkColor)
        .lineLimit(1)
      Spacer()
    }
    .padding(.horizontal, 12)
    .padding(.vertical, 10)
    .background(
      RoundedRectangle(cornerRadius: 8)
        .fill(isActive ? inkColor.opacity(0.06) : Color.clear)
    )
  }
}

// MARK: - Crop Selection

// The dashed crop rectangle that appears when the user drags to select
// a region of the canvas in crop mode.
struct CropSelection: View {
  let paper = Color(red: 0.97, green: 0.97, blue: 0.96)

  var body: some View {
    // Crop rectangle with dashed border and subtle fill.
    Rectangle()
      .stroke(
        inkColor.opacity(0.5),
        style: StrokeStyle(lineWidth: 1.5, dash: [6, 4])
      )
      .background(
        Rectangle().fill(inkColor.opacity(0.06))
      )
      .frame(width: 360, height: 260)
  }
}

// MARK: - Mode Picker Pill

// The three-icon pill for switching between crop, viewport, and full canvas modes.
// Liquid glass approximated with a light fill since there's no compositing window.
struct ModePickerPill: View {
  let inkFaint = Color(red: 0.55, green: 0.53, blue: 0.50)

  var body: some View {
    HStack(spacing: 0) {
      // Crop mode icon (active).
      Image(systemName: "crop")
        .font(.system(size: 18, weight: .medium))
        .foregroundColor(inkColor)
        .frame(width: 44, height: 44)

      // Viewport mode icon.
      Image(systemName: "rectangle.dashed")
        .font(.system(size: 18, weight: .medium))
        .rotationEffect(.degrees(90))
        .foregroundColor(inkFaint)
        .frame(width: 44, height: 44)

      // Full canvas mode icon.
      Image(systemName: "doc.text")
        .font(.system(size: 18, weight: .medium))
        .foregroundColor(inkFaint)
        .frame(width: 44, height: 44)
    }
    .background(
      Capsule()
        .fill(Color(nsColor: .controlBackgroundColor).opacity(0.85))
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
    )
  }
}

// MARK: - Rendering

@MainActor
func render() throws {
  let outputDir = URL(fileURLWithPath: CommandLine.arguments.count > 1
    ? CommandLine.arguments[1]
    : FileManager.default.currentDirectoryPath)

  // Render at 3x for crisp output.
  let scale: CGFloat = 3.0

  // Render send button.
  let buttonRenderer = ImageRenderer(content: SendButton().padding(8))
  buttonRenderer.scale = scale
  if let cgImage = buttonRenderer.cgImage {
    let bitmap = NSBitmapImageRep(cgImage: cgImage)
    bitmap.size = NSSize(
      width: CGFloat(cgImage.width) / scale,
      height: CGFloat(cgImage.height) / scale
    )
    if let pngData = bitmap.representation(using: .png, properties: [:]) {
      let url = outputDir.appendingPathComponent("send_button.png")
      try pngData.write(to: url)
      print("Wrote \(url.path)")
    }
  }

  // Render sent toast.
  let toastRenderer = ImageRenderer(content: SentToast().padding(8))
  toastRenderer.scale = scale
  if let cgImage = toastRenderer.cgImage {
    let bitmap = NSBitmapImageRep(cgImage: cgImage)
    bitmap.size = NSSize(
      width: CGFloat(cgImage.width) / scale,
      height: CGFloat(cgImage.height) / scale
    )
    if let pngData = bitmap.representation(using: .png, properties: [:]) {
      let url = outputDir.appendingPathComponent("sent_toast.png")
      try pngData.write(to: url)
      print("Wrote \(url.path)")
    }
  }

  // Render mode picker pill.
  let pillRenderer = ImageRenderer(content: ModePickerPill().padding(8))
  pillRenderer.scale = scale
  if let cgImage = pillRenderer.cgImage {
    let bitmap = NSBitmapImageRep(cgImage: cgImage)
    bitmap.size = NSSize(
      width: CGFloat(cgImage.width) / scale,
      height: CGFloat(cgImage.height) / scale
    )
    if let pngData = bitmap.representation(using: .png, properties: [:]) {
      let url = outputDir.appendingPathComponent("mode_picker.png")
      try pngData.write(to: url)
      print("Wrote \(url.path)")
    }
  }

  // Render crop selection.
  let cropRenderer = ImageRenderer(content: CropSelection().padding(8))
  cropRenderer.scale = scale
  if let cgImage = cropRenderer.cgImage {
    let bitmap = NSBitmapImageRep(cgImage: cgImage)
    bitmap.size = NSSize(
      width: CGFloat(cgImage.width) / scale,
      height: CGFloat(cgImage.height) / scale
    )
    if let pngData = bitmap.representation(using: .png, properties: [:]) {
      let url = outputDir.appendingPathComponent("crop_selection.png")
      try pngData.write(to: url)
      print("Wrote \(url.path)")
    }
  }

  // Render sidebar.
  let sidebarRenderer = ImageRenderer(content: SidebarRender().padding(12))
  sidebarRenderer.scale = scale
  if let cgImage = sidebarRenderer.cgImage {
    let bitmap = NSBitmapImageRep(cgImage: cgImage)
    bitmap.size = NSSize(
      width: CGFloat(cgImage.width) / scale,
      height: CGFloat(cgImage.height) / scale
    )
    if let pngData = bitmap.representation(using: .png, properties: [:]) {
      let url = outputDir.appendingPathComponent("sidebar.png")
      try pngData.write(to: url)
      print("Wrote \(url.path)")
    }
  }
}

try MainActor.assumeIsolated {
  try render()
}

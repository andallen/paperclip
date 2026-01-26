//
// InputBlockView.swift
// InkOS
//
// Input block rendering and inline input for user conversations with Alan.
// InputBlockView is a placeholder for future form controls.
// InlineInputView is the floating input shown when user taps the blob.
//

import SwiftUI

// MARK: - InputBlockView

// Placeholder for input blocks.
struct InputBlockView: View {
  let content: InputContent

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      if let prompt = content.prompt {
        Text(prompt)
          .font(.body)
      }

      RoundedRectangle(cornerRadius: 8)
        .fill(Color.gray.opacity(0.1))
        .frame(height: 100)
        .overlay {
          VStack(spacing: 8) {
            Image(systemName: inputIcon)
              .font(.title)
              .foregroundColor(.secondary)
            Text("Input (\(content.inputType.rawValue))")
              .font(.caption)
              .foregroundColor(.secondary)
          }
        }

      Button(content.submitLabel) {
        // Placeholder action.
      }
      .buttonStyle(.borderedProminent)
      .disabled(true)
    }
    .padding(.vertical, 16)
  }

  private var inputIcon: String {
    switch content.inputType {
    case .text: return "text.cursor"
    case .handwriting: return "pencil.tip"
    case .multipleChoice: return "list.bullet"
    case .multiSelect: return "checkmark.square"
    case .button: return "hand.tap"
    case .slider: return "slider.horizontal.3"
    case .numeric: return "number"
    }
  }
}

// MARK: - InlineInputView

// Floating input view shown when user taps the blob.
// Allows user to type a message to Alan.
struct InlineInputView: View {
  @Binding var text: String
  let onSubmit: () -> Void
  let onDismiss: () -> Void
  @FocusState private var isFocused: Bool

  var body: some View {
    VStack(spacing: 12) {
      TextField("Ask Alan anything...", text: $text, axis: .vertical)
        .textFieldStyle(.roundedBorder)
        .lineLimit(1...5)
        .focused($isFocused)
        .submitLabel(.send)
        .onSubmit(onSubmit)
        .font(NotebookTypography.body)

      HStack {
        Button("Cancel") { onDismiss() }
          .foregroundColor(.secondary)
          .font(NotebookTypography.body)
        Spacer()
        Button("Send") { onSubmit() }
          .buttonStyle(.borderedProminent)
          .disabled(text.isEmpty)
          .font(NotebookTypography.body)
      }
    }
    .padding()
    .background(NotebookPalette.paper)
    .cornerRadius(12)
    .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
    .onAppear { isFocused = true }
  }
}

// MARK: - Preview

#Preview("Inline Input") {
  VStack {
    Spacer()
    InlineInputView(
      text: .constant(""),
      onSubmit: {},
      onDismiss: {}
    )
    .padding()
    Spacer()
  }
  .background(NotebookPalette.paper)
}

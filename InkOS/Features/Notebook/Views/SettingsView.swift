import SwiftUI

// Settings screen presented as a sheet from the sidebar.
// Provides a custom instructions field that persists via UserDefaults.
struct SettingsView: View {
  @Environment(\.dismiss) private var dismiss
  @AppStorage("customInstructions") private var customInstructions = ""

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(alignment: .leading, spacing: NotebookSpacing.sm) {
          // Section heading.
          Text("Custom Instructions")
            .font(NotebookTypography.headline)
            .foregroundStyle(NotebookPalette.ink)

          // Description text.
          Text("Personal preferences for your notebook.")
            .font(NotebookTypography.caption)
            .foregroundStyle(NotebookPalette.inkFaint)

          // Text editor in a rounded container.
          ZStack(alignment: .topLeading) {
            TextEditor(text: $customInstructions)
              .font(NotebookTypography.body)
              .foregroundStyle(NotebookPalette.ink)
              .scrollContentBackground(.hidden)
              .padding(12)

            // Placeholder text when editor is empty.
            if customInstructions.isEmpty {
              Text("Add any preferences that you want the AI to consider in its responses here...")
                .font(NotebookTypography.body)
                .foregroundStyle(NotebookPalette.inkFaint)
                .padding(12)
                .padding(.top, 8)
                .padding(.leading, 4)
                .allowsHitTesting(false)
            }
          }
          .frame(height: 200)
          .clipShape(RoundedRectangle(cornerRadius: 12))
          .background(
            RoundedRectangle(cornerRadius: 12)
              .fill(NotebookPalette.paper)
              .overlay(
                RoundedRectangle(cornerRadius: 12)
                  .stroke(NotebookPalette.inkFaint.opacity(0.3), lineWidth: 1)
              )
          )
        }
        .padding(NotebookSpacing.sm)
      }
      .background(NotebookPalette.paper)
      .navigationTitle("Settings")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .confirmationAction) {
          Button("Done") { dismiss() }
            .foregroundStyle(NotebookPalette.ink)
        }
      }
    }
  }
}

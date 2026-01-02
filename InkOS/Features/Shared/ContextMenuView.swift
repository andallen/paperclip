import SwiftUI

// MARK: - Context Menu Action

// Represents a single action in a context menu.
// Used by the custom ContextMenuOverlay for building menu items.
struct ContextMenuAction: Identifiable {
  let id = UUID()
  let title: String
  let systemImage: String
  let isDestructive: Bool
  let handler: () -> Void

  init(
    title: String,
    systemImage: String,
    isDestructive: Bool = false,
    handler: @escaping () -> Void
  ) {
    self.title = title
    self.systemImage = systemImage
    self.isDestructive = isDestructive
    self.handler = handler
  }
}

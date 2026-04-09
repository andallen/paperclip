//
//  AppStoreLinks.swift
//  PaperClip
//
//  Single source of truth for companion app App Store URLs.
//

import UIKit

enum AppStoreLinks {
  // Replace PLACEHOLDER with the real Mac app Apple ID once known
  // e.g. "https://apps.apple.com/app/paperclip-receiver/id1234567890"
  static let macReceiverURL = URL(string: "https://apps.apple.com/app/paperclip-receiver/idPLACEHOLDER")!

  /// Opens the Mac Receiver page in the App Store and fires a light haptic.
  static func openMacReceiver() {
    UIApplication.shared.open(macReceiverURL)
    UIImpactFeedbackGenerator(style: .light).impactOccurred()
  }
}

//
//  AppStoreLinks.swift
//  PaperClip
//
//  Single source of truth for companion app App Store URLs.
//

import UIKit

enum AppStoreLinks {
  static let macReceiverURL = URL(string: "https://apps.apple.com/app/id6761500831")!

  /// Opens the Mac Receiver page in the App Store and fires a light haptic.
  static func openMacReceiver() {
    UIApplication.shared.open(macReceiverURL)
    UIImpactFeedbackGenerator(style: .light).impactOccurred()
  }
}

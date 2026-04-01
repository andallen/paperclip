//
// PaperClipMacApp.swift
// PaperClipMac
//
// Menu bar companion app that receives drawings from the PaperClip iPad app
// and places them on the Mac clipboard. No Dock icon, no main window — just
// a status icon in the menu bar.
//

import SwiftUI

@main
struct PaperClipMacApp: App {
  // The receiver service lives for the entire app lifetime.
  @State private var service = ReceiverService()

  init() {
    // Start the receiver immediately on app launch — not when the menu is
    // opened, since MenuBarExtra content only renders on click.
    service.start()
  }

  var body: some Scene {
    // Menu bar extra with a dynamic icon that reflects connection state.
    // Uses .window style for rich custom UI (thumbnails, colored indicators).
    MenuBarExtra {
      MenuBarView(service: service)
    } label: {
      Image(systemName: menuBarIconName)
    }
    .menuBarExtraStyle(.window)
  }

  // Consistent paperclip icon in the menu bar across all states.
  private var menuBarIconName: String {
    "paperclip"
  }
}

//
// AppDelegate.swift
// InkOSRelay
//
// Menu bar agent that monitors the clipboard for InkOS images
// and auto-pastes them into the terminal for Claude Code.
// Runs as a background agent (no Dock icon).
//

import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
  private var statusItem: NSStatusItem!
  private var monitor: ClipboardMonitor!

  func applicationDidFinishLaunching(_ notification: Notification) {
    // Hide from Dock.
    NSApp.setActivationPolicy(.accessory)

    // Create menu bar icon.
    statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    if let button = statusItem.button {
      button.image = NSImage(
        systemSymbolName: "pencil.and.scribble",
        accessibilityDescription: "InkOS Relay"
      )
    }

    // Build menu.
    let menu = NSMenu()
    menu.addItem(withTitle: "InkOS Relay", action: nil, keyEquivalent: "")
    menu.addItem(NSMenuItem.separator())

    let statusLabel = accessibilityStatus()
    menu.addItem(withTitle: statusLabel, action: nil, keyEquivalent: "")

    menu.addItem(NSMenuItem.separator())
    menu.addItem(withTitle: "Quit", action: #selector(quit), keyEquivalent: "q")
    statusItem.menu = menu

    // Check accessibility permission.
    checkAccessibility()

    // Start clipboard monitoring.
    monitor = ClipboardMonitor()
    monitor.start()
  }

  private func accessibilityStatus() -> String {
    if AXIsProcessTrusted() {
      return "Status: Listening"
    } else {
      return "Status: Needs Accessibility Permission"
    }
  }

  private func checkAccessibility() {
    if !AXIsProcessTrusted() {
      print("[InkOSRelay] Requesting Accessibility permission...")
      let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue(): true] as CFDictionary
      AXIsProcessTrustedWithOptions(options)
    }
  }

  @objc private func quit() {
    monitor.stop()
    NSApp.terminate(nil)
  }
}

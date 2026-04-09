# Companion App Cross-Promotion Design

**Date:** 2026-04-09
**Status:** Approved

## Overview

Both PaperClip (iPad) and PaperClip Receiver (Mac) are live on the App Store. Users discover the Mac app exclusively through the iPad app, never the reverse. This spec adds minimal, on-palette cross-promotion from the iPad app pointing to the Mac App Store page at the two moments a user most needs it: during first-time onboarding setup and when they open the disconnected troubleshooting card.

## Scope

- **In scope:** iPad app only. Two touch-points.
- **Out of scope:** Mac app changes (untouched), landing page/website, analytics, App Store Connect description edits (separate manual task).

## Design Principles

- No blue links. No underlines. No UI chrome that feels foreign to the warm paper/ink aesthetic.
- Links are contextual — they appear when a user might not have the Mac app yet, and hide once they're a returning user.
- Single source of truth for the App Store URL.

---

## Component 1: `AppStoreLinks.swift`

**Location:** `PaperClip/Features/Shared/AppStoreLinks.swift`

A small enum with the Mac companion's App Store URL and a helper that opens it with a light haptic. All other components reference this one place. The URL is a placeholder (`PLACEHOLDER_MAC_APP_STORE_URL`) until the real App Store ID is known.

```swift
enum AppStoreLinks {
  static let macReceiverURL = URL(string: "https://apps.apple.com/app/paperclip-receiver/PLACEHOLDER_MAC_APP_STORE_URL")!
  static func openMacReceiver() {
    UIApplication.shared.open(macReceiverURL)
    UIImpactFeedbackGenerator(style: .light).impactOccurred()
  }
}
```

---

## Component 2: Connection History Tracking

**Location:** `PaperClip/Features/Shared/Services/TransferService.swift`

An `@AppStorage` boolean persisted to UserDefaults. Flipped to `true` once, the first time `connectionState` transitions to `.connected`. Never reset. Exposed as a read-only `var hasEverConnected: Bool` so views can observe it without importing AppStorage directly.

**Key:** `"hasEverConnectedToMac"`

---

## Component 3: Onboarding Page 3 — Tappable Card (Treatment A)

**Location:** `PaperClip/Features/Shared/OnboardingView.swift`

The existing `setupCard(icon:title:detail:visible:)` gains one optional parameter: `action: (() -> Void)?`. When non-nil:
- The card body is wrapped in a `Button` with `.buttonStyle(.plain)`.
- A small `Image(systemName: "arrow.up.right")` in `NotebookPalette.inkFaint` appears as the rightmost element (before the `Spacer()` call is removed and placed after the icon).
- Tap invokes `action`, which callers pass as `AppStoreLinks.openMacReceiver`.
- Haptic is handled inside `AppStoreLinks.openMacReceiver()` — the card itself does nothing extra.

Only the first setupCard ("Get PaperClip for Mac") receives an action. The other two cards pass `action: nil` and render identically to today.

Visual: icon circle + title + detail + `Spacer()` + small `arrow.up.right` chevron in `inkFaint`. No color change, no underline, no blue. Reads like the rest of the notebook.

---

## Component 4: Disconnected Help Card — Inline Link (Treatment B)

**Location:** `PaperClip/Features/Notebook/Views/NotebookCanvasView.swift`

Step 1 of `connectionHelpCard` becomes conditional on `transferService.hasEverConnected`:

**First-time user (`hasEverConnected == false`):**
A custom `firstTimeHelpStep1` view replaces the generic `helpStep(number:text:)` for step 1. It renders the same badge + text layout, but uses `AttributedString` to make only the phrase "PaperClip Receiver" tappable:

- The full phrase renders in `NotebookTypography.caption` / `inkSubtle` (same as other steps)
- "PaperClip Receiver" is bold + carries a `.link` attribute pointing to `AppStoreLinks.macReceiverURL`
- An `.environment(\.openURL, ...)` modifier on the `Text` view routes taps to `AppStoreLinks.openMacReceiver()` instead of Safari
- SwiftUI's default blue link tint is overridden by setting `foregroundColor` to `NotebookPalette.ink` on the link range of the `AttributedString`
- A tiny `Image(systemName: "arrow.up.right")` glyph follows inline, in `inkFaint`, via `Text` + image concatenation

**Returning user (`hasEverConnected == true`):**
The existing `helpStep(number: "1", text: "Install **PaperClip Receiver** ...")` renders unchanged. No link, no visual difference from today.

Steps 2, 3, and 💡 are unconditional and untouched.

---

## Non-Code Task: App Store Connect

Manually add a mention of PaperClip Receiver (with its App Store link) in the iPad app's App Store description, and vice versa. Apple also automatically renders a "More by this developer" row on both pages since they share the same developer account. This requires no code.

---

## Files Changed

| File | Change |
|------|--------|
| `PaperClip/Features/Shared/AppStoreLinks.swift` | New — URL constant + open helper |
| `PaperClip/Features/Shared/Services/TransferService.swift` | Add `@AppStorage("hasEverConnectedToMac")` + transition logic |
| `PaperClip/Features/Shared/OnboardingView.swift` | Add optional `action` param to `setupCard`, wire first card |
| `PaperClip/Features/Notebook/Views/NotebookCanvasView.swift` | Conditional inline link in help card step 1 |

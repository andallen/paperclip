# Companion App Cross-Promotion Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add minimal, on-palette cross-promotion from the iPad app pointing to the Mac App Store page — once on the onboarding setup page (tappable card), and once in the disconnected troubleshooting card (inline tappable phrase, hidden for returning users).

**Architecture:** Four changes across three files + one new file. A shared `AppStoreLinks` enum centralises the URL. `TransferService` persists first-connection history to UserDefaults. `OnboardingView` gains an optional tap action on the setup card. `NotebookCanvasView` renders a conditional rich step-1 with an inline tappable "PaperClip Receiver" phrase.

**Tech Stack:** Swift 5.9, SwiftUI, UIKit (UIApplication.open), Foundation (UserDefaults / @AppStorage), AttributedString

---

### Task 1: Create `AppStoreLinks.swift` and wire connection history in `TransferService`

**Files:**
- Create: `PaperClip/Features/Shared/AppStoreLinks.swift`
- Modify: `PaperClip/Features/Notebook/Services/TransferService.swift` (lines 56–72 for class properties, line 197 for the `.ready` case)

- [ ] **Step 1: Create `AppStoreLinks.swift`**

Create the file at `PaperClip/Features/Shared/AppStoreLinks.swift` with this exact content:

```swift
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
```

- [ ] **Step 2: Add the file to the Xcode project**

Open `PaperClip.xcodeproj` in Xcode. In the Project Navigator, right-click `PaperClip/Features/Shared/` → "Add Files to 'PaperClip'…" → select `AppStoreLinks.swift`. Make sure it's added to the **PaperClip** target only (not PaperClipMac or tests).

- [ ] **Step 3: Add connection history property to `TransferService`**

In `PaperClip/Features/Notebook/Services/TransferService.swift`, add one property inside the `TransferService` class, directly after the `var connectedMacName: String?` declaration (around line 61):

```swift
  // Persisted flag: true once this device has ever successfully connected
  // to a Mac running PaperClip Receiver. Used by the UI to hide the
  // "Get the Mac app" link once the user is a returning user.
  @AppStorage("hasEverConnectedToMac") var hasEverConnectedToMac: Bool = false
```

Note: `@AppStorage` works inside `@Observable` classes in Swift 5.9+ and will trigger view updates when the value changes.

- [ ] **Step 4: Set the flag on first connection**

In `TransferService.swift`, locate `handleConnectionState(_:name:endpoint:)` (around line 194). In the `.ready` case, add one line immediately after `connectionState = .connected`:

```swift
    case .ready:
      connectionState = .connected
      hasEverConnectedToMac = true        // ← add this line
      connectedMacName = name
      log.info("Connected to \(name)")
      sendDeviceName()
```

- [ ] **Step 5: Build the PaperClip target**

In Xcode, select the **PaperClip** scheme and press **⌘B**. Expected: build succeeds with no errors or warnings related to these new additions.

- [ ] **Step 6: Commit**

```bash
git add PaperClip/Features/Shared/AppStoreLinks.swift \
        PaperClip/Features/Notebook/Services/TransferService.swift \
        PaperClip.xcodeproj/project.pbxproj
git commit -m "Add AppStoreLinks helper and connection history tracking"
```

---

### Task 2: Upgrade onboarding `setupCard` to support a tap action

**Files:**
- Modify: `PaperClip/Features/Shared/OnboardingView.swift` (lines 312–332 for card call sites, lines 364–396 for the `setupCard` function)

- [ ] **Step 1: Add `action` parameter to `setupCard`**

Open `OnboardingView.swift`. Replace the `setupCard` function signature and body (lines 364–396) with the following. The only structural changes are: (a) a new optional `action` parameter, (b) a trailing arrow icon shown when action is non-nil, and (c) `.onTapGesture` to invoke the action.

```swift
  // Setup step card with icon, title, detail, and optional tap action.
  // When action is non-nil, a subtle arrow glyph appears and the card is tappable.
  private func setupCard(
    icon: String,
    title: String,
    detail: Text,
    visible: Bool,
    action: (() -> Void)? = nil
  ) -> some View {
    HStack(spacing: 14) {
      // Icon in a subtle ink-tinted circle.
      Image(systemName: icon)
        .font(.system(size: 19, weight: .medium))
        .foregroundColor(NotebookPalette.ink)
        .frame(width: 42, height: 42)
        .background(Circle().fill(OnboardingStyle.accentTint))

      // Step text.
      VStack(alignment: .leading, spacing: 2) {
        Text(title)
          .font(NotebookTypography.headline)
          .foregroundColor(NotebookPalette.ink)

        detail
          .font(NotebookTypography.body)
          .foregroundColor(NotebookPalette.inkSubtle)
      }

      Spacer()

      // Trailing arrow — only visible when the card is tappable.
      if action != nil {
        Image(systemName: "arrow.up.right")
          .font(.system(size: 12, weight: .medium))
          .foregroundColor(NotebookPalette.inkFaint)
      }
    }
    .padding(16)
    .liquidGlassBackground(cornerRadius: 14)
    .opacity(visible ? 1 : 0)
    .offset(y: visible ? 0 : 10)
    .onTapGesture { action?() }
  }
```

- [ ] **Step 2: Wire the first card's action**

In `setupPage` (around line 312), update the first `setupCard` call to pass the action. Leave the other two cards unchanged.

Replace:
```swift
        setupCard(
          icon: "arrow.down.circle",
          title: "Get PaperClip for Mac",
          detail: Text("Free companion app — lives in your menu bar"),
          visible: checkVisible[0]
        )
```

With:
```swift
        setupCard(
          icon: "arrow.down.circle",
          title: "Get PaperClip for Mac",
          detail: Text("Free companion app — lives in your menu bar"),
          visible: checkVisible[0],
          action: AppStoreLinks.openMacReceiver
        )
```

- [ ] **Step 3: Build the PaperClip target**

Press **⌘B**. Expected: succeeds with no errors.

- [ ] **Step 4: Manual verification**

Run on iPad simulator (or device). If onboarding has already been completed, reset it by running in the simulator and going to Settings → General → Reset → Reset All Settings, or by deleting and reinstalling the app.

Navigate to onboarding page 3. Verify:
1. The "Get PaperClip for Mac" card shows a small `↗` icon on its trailing edge.
2. The "Launch It" and "You're Connected" cards do NOT show the arrow.
3. Tapping the "Get PaperClip for Mac" card fires a light haptic (feel it on device, or confirm the `openMacReceiver()` code path is reached).

- [ ] **Step 5: Commit**

```bash
git add PaperClip/Features/Shared/OnboardingView.swift
git commit -m "Make 'Get PaperClip for Mac' onboarding card tappable with App Store link"
```

---

### Task 3: Add inline conditional link to disconnected help card step 1

**Files:**
- Modify: `PaperClip/Features/Notebook/Views/NotebookCanvasView.swift` (lines 680–732)

The help card is in `connectionHelpCard`. Step 1 is currently a call to `helpStep(number: "1", text: "Install **PaperClip Receiver** ...")`. For first-time users (`!transferService.hasEverConnectedToMac`), replace this with a custom view that makes "PaperClip Receiver" tappable via `AttributedString` + custom `openURL` handler.

- [ ] **Step 1: Add the `step1AttributedText` computed property to `NoteCanvasView`**

Add this private computed property inside `NoteCanvasView`, below the existing `helpStep` function (after line 750, before the closing `}`):

```swift
  // AttributedString for help card step 1 that makes "PaperClip Receiver"
  // a tappable link in ink color (overriding SwiftUI's default blue).
  private var step1AttributedText: AttributedString {
    var text = AttributedString("Install ")

    var linkPart = AttributedString("PaperClip Receiver")
    // Use Nunito Bold to match the palette — same size as caption but bold weight.
    linkPart.font = NotebookTypography.nunitoFont(size: 13, weight: .bold)
    linkPart.foregroundColor = NotebookPalette.ink
    linkPart.link = AppStoreLinks.macReceiverURL

    var rest = AttributedString(" on your Mac. It's a free companion app that lives in your menu bar")

    text.append(linkPart)
    text.append(rest)
    return text
  }
```

- [ ] **Step 2: Add the `firstTimeStep1` view to `NoteCanvasView`**

Add this private computed property immediately after `step1AttributedText`:

```swift
  // Custom step-1 row for first-time users: same layout as helpStep but with
  // "PaperClip Receiver" as an inline tappable link.
  private var firstTimeStep1: some View {
    HStack(alignment: .top, spacing: 10) {
      // Number badge — matches helpStep styling.
      Text("1")
        .font(.system(size: 12, weight: .bold, design: .rounded))
        .foregroundColor(NotebookPalette.paper)
        .frame(width: 22, height: 22)
        .background(Circle().fill(NotebookPalette.ink))

      // Attributed text with tappable phrase.
      // .font and .foregroundColor set defaults for characters without explicit
      // attributes. .tint overrides SwiftUI's default blue for link ranges,
      // making the tappable phrase render in ink color instead.
      Text(step1AttributedText)
        .font(NotebookTypography.caption)
        .foregroundColor(NotebookPalette.inkSubtle)
        .tint(NotebookPalette.ink)
        .fixedSize(horizontal: false, vertical: true)
        .environment(\.openURL, OpenURLAction { _ in
          AppStoreLinks.openMacReceiver()
          return .handled
        })
    }
  }
```

- [ ] **Step 3: Make step 1 conditional in `connectionHelpCard`**

In `connectionHelpCard` (around line 680), replace the first `helpStep` call with a conditional:

Replace:
```swift
      helpStep(
        number: "1",
        text: "Install **PaperClip Receiver** on your Mac. It's a free companion app that lives in your menu bar"
      )
```

With:
```swift
      if !transferService.hasEverConnectedToMac {
        firstTimeStep1
      } else {
        helpStep(
          number: "1",
          text: "Install **PaperClip Receiver** on your Mac. It's a free companion app that lives in your menu bar"
        )
      }
```

- [ ] **Step 4: Build the PaperClip target**

Press **⌘B**. Expected: succeeds with no errors.

- [ ] **Step 5: Manual verification — first-time user**

Reset `hasEverConnectedToMac` in UserDefaults by running this once in the simulator console or by deleting the app:
```swift
UserDefaults.standard.removeObject(forKey: "hasEverConnectedToMac")
```

Open the app. Dismiss the "No Mac found" label's `?` button to expand the help card. Verify:
1. Step 1 shows "PaperClip Receiver" in bold ink (not blue).
2. Tapping "PaperClip Receiver" fires a light haptic and attempts to open the App Store URL.
3. Steps 2, 3, 💡 are unchanged.

- [ ] **Step 6: Manual verification — returning user**

In Xcode, set a breakpoint on `hasEverConnectedToMac = true` in `TransferService.swift` and let it fire (or manually set the UserDefaults key to `true` in the simulator). Reopen the help card.

Verify:
1. Step 1 is plain text — "Install **PaperClip Receiver** on your Mac…" with no tappable link, matching steps 2 and 3 visually.

- [ ] **Step 7: Commit**

```bash
git add PaperClip/Features/Notebook/Views/NotebookCanvasView.swift
git commit -m "Add inline App Store link in help card for first-time users"
```

---

### Task 4: Commit spec and plan, replace URL placeholder

**Files:**
- Modify: `PaperClip/Features/Shared/AppStoreLinks.swift` (replace placeholder with real URL)
- Commit: `docs/superpowers/specs/2026-04-09-companion-crosspromotion-design.md`
- Commit: `docs/superpowers/plans/2026-04-09-companion-crosspromotion.md`

- [ ] **Step 1: Get the real Mac App Store URL**

In App Store Connect, go to your Mac app's page and copy the App Store URL (format: `https://apps.apple.com/app/paperclip-receiver/id1234567890`).

- [ ] **Step 2: Replace the placeholder URL**

In `PaperClip/Features/Shared/AppStoreLinks.swift`, replace:
```swift
  static let macReceiverURL = URL(string: "https://apps.apple.com/app/paperclip-receiver/idPLACEHOLDER")!
```
With the real URL, e.g.:
```swift
  static let macReceiverURL = URL(string: "https://apps.apple.com/app/paperclip-receiver/id1234567890")!
```

- [ ] **Step 3: Build once more to confirm**

Press **⌘B**. Expected: clean build.

- [ ] **Step 4: Final commit**

```bash
git add PaperClip/Features/Shared/AppStoreLinks.swift \
        docs/superpowers/specs/2026-04-09-companion-crosspromotion-design.md \
        docs/superpowers/plans/2026-04-09-companion-crosspromotion.md
git commit -m "Wire real App Store URL, add spec and plan docs"
```

- [ ] **Step 5: Push**

```bash
git push
```

---

## Non-Code Reminder

In App Store Connect, update both app descriptions to mention the companion:
- iPad app description: mention "requires the free PaperClip Receiver companion app for Mac"
- Mac app description: mention "works with the free PaperClip iPad app"

Apple also auto-renders a "More by this developer" section on both pages since they share the same developer account — no action needed for that.

# PaperClip — App Store Publishing Checklist

## Overview

PaperClip is a two-app system: an iPad app for handwriting with Apple Pencil and a macOS menu bar companion app (PaperClipMac) that receives drawings over peer-to-peer Wi-Fi and places them on the Mac clipboard. Both apps need to be published to their respective App Stores.

This document tracks every step needed to ship both apps. Steps are grouped into phases. All steps within a phase can be done in parallel unless noted otherwise.

---

## Phase 1: Code Changes (Done)

### ~~1. Rename project from InkOS to PaperClip~~
**Status:** Done

### ~~2. Add Privacy Manifest (PrivacyInfo.xcprivacy)~~
**Status:** Done (empty API types array — no privacy-sensitive APIs used)

### ~~3. Add ITSAppUsesNonExemptEncryption to Info.plist~~
**Status:** Done (both iPad and Mac Info.plist)

### ~~4. Replace Universal Clipboard with peer-to-peer transfer~~
**Status:** Done
**What was done:**
- iPad: `TransferService` discovers Mac via Bonjour (`_paperclip._tcp`) over AWDL, sends framed PNGs over persistent TCP connection
- Mac: `ReceiverService` listens via NWListener with `.includePeerToPeer`, writes received PNGs to NSPasteboard
- Both: `NSLocalNetworkUsageDescription` and `NSBonjourServices` in Info.plist
- UIPasteboard writes removed entirely from iPad app

### ~~5. Build macOS companion app (PaperClipMac)~~
**Status:** Done
**What was done:**
- SwiftUI MenuBarExtra with LSUIElement (no Dock icon)
- ReceiverService: Observable NWListener, 4-byte length-prefixed PNG protocol
- MenuBarView: status display, "Start at Login" toggle (SMAppService), quit button
- Sandboxed with network.client + network.server entitlements
- Build script: `Scripts/buildmac`

---

## Phase 2: Pre-Submission Content (Parallel)

### ~~6. Decide on Deployment Target~~
**Status:** Done (iPad: iOS 26.0, Mac: macOS 14.0)

### ~~7. Take App Store Screenshots — iPad~~
**Status:** Done — 5 screenshots at 2064x2752 in `/Users/andrewallen/Downloads/appstore_screenshots/`

### ~~8. Take App Store Screenshots — Mac~~
**Status:** Done
**What:** The Mac App Store requires screenshots for the macOS companion app listing.
**Required resolutions (at least one):**

| Display | Resolution | Required? |
|---|---|---|
| Retina 16" | 3456 x 2234 | Recommended |
| Retina 13" | 2880 x 1800 | Alternative |

**How to do it:**
1. Run `Scripts/buildmac` then `open build/PaperClipMac.app`
2. Click the menu bar icon to open the dropdown
3. Take a screenshot of the menu bar area showing the dropdown (Cmd+Shift+4, drag)
4. Show at least: "Waiting for iPad" state, and "Connected" state with a device name
5. Optionally show the menu bar icon in context (top-right of screen)

**Note:** Mac screenshots can be more minimal — the app is a menu bar utility. 2-3 screenshots are sufficient. Consider compositing them into a single image with labels.

**Deliverable:** 2-3 PNG or JPEG images at one of the required resolutions.

### ~~9. Create a Privacy Policy URL~~
**Status:** Done — https://andallen.github.io/paperclip/privacy.html

### ~~10. Create a Support URL~~
**Status:** Done — https://andallen.github.io/paperclip/support.html

### ~~11. Update App Store Listing Copy~~
**Status:** Done — `docs/app-store-copy.txt` updated with both iPad and Mac app listings. Review notes reference PaperClipMac companion app and bundle IDs. Keywords updated. Mac app copy written.

### ~~12. Update Onboarding Flow~~
**Status:** Done — Page 2 Step 3 and Page 3 updated to reference companion app instead of Universal Clipboard.

### ~~13. Add Disconnected State UI~~
**Status:** Done — Send button disabled when no Mac connected. "No Mac found" label with tappable `?` help button that expands a troubleshooting card with setup steps. Auto-dismisses when Mac connects.

### ~~14. Update Privacy Policy Page~~
**Status:** Done — Updated to mention both apps, companion Mac app by name, peer-to-peer transfer, local network access explanation. No Universal Clipboard references.

### ~~15. Update Support Page~~
**Status:** Done — Added full troubleshooting section ("No Mac found", clipboard issues, connection drops), updated getting started with companion app install steps, added FAQ on peer-to-peer and network requirements. Fixed broken GitHub link.

---

## Phase 3: Code Quality & Polish (Parallel)

### ~~16. App Icons~~
**Status:** Done — Mac app now uses the same 1024x1024 AppIcon.png as the iPad app. Xcode downscales to all required Mac sizes automatically.

### ~~17. Code Signing Setup~~
**Status:** Done

### ~~18. Version Numbers~~
**Status:** Done — both apps at 1.0 (build 1). Mac Info.plist was missing version keys; added.

### ~~19. Mac App Privacy Manifest~~
**Status:** Done — created `PaperClipMac/PrivacyInfo.xcprivacy` (no tracking, no privacy-sensitive APIs). NSPasteboard is not a "required reason API" so no declaration needed.

### ~~20. Mac App Sandbox Entitlements Review~~
**Status:** Done — entitlements verified correct. `app-sandbox` + `network.client` + `network.server` covers all functionality. NSPasteboard works in sandbox without special entitlement. SMAppService is the modern sandbox-compatible login item API. Bonjour/AWDL verified working by end-to-end testing.

---

## Phase 4: Apple Developer Account (Sequential)

### ~~21. Purchase Apple Developer Program Membership~~
**Status:** Done

### ~~22. Accept App Store Connect Agreements~~
**Status:** Done

---

## Phase 5: Submission — iPad App (Sequential)

### ~~23. Create iPad App in App Store Connect~~
**Status:** Done
**How:**
1. Go to appstoreconnect.apple.com → My Apps → + → New App
2. Fill in:
   - **Platform:** iOS
   - **Name:** PaperClip - Handwrite for AI
   - **Primary Language:** English
   - **Bundle ID:** `me.andy.allen.PaperClip`
   - **SKU:** `paperclip-ipad-v1`
3. Category: Productivity (primary), Utilities (secondary)
4. Age Rating: 4+ (no objectionable content)
5. Upload iPad screenshots (from step 7)
6. Fill in listing copy (from step 11)
7. Enter privacy policy URL and support URL

### ~~24. Archive and Upload iPad Build~~
**Status:** Done
**How:**
1. In Xcode, select the PaperClip scheme, set destination to "Any iOS Device (arm64)"
2. Product → Archive
3. Organizer → Distribute App → App Store Connect → Upload
4. Wait for processing email (5-30 minutes)

### ~~25. Submit iPad App for Review~~
**Status:** Done — submitted 2026-04-01
**How:**
1. In App Store Connect → your app → App Store tab
2. Select the uploaded build
3. Paste App Review Notes explaining the companion app workflow
4. Submit to App Review

**Important for review notes:** Explain that the full workflow requires the companion Mac app (PaperClipMac), but the iPad app is fully functional standalone for note-taking. The send feature requires the Mac app to be running. Provide clear instructions for the reviewer on how to test.

---

## Phase 6: Submission — Mac Companion App (Sequential)

### ~~26. Create Mac App in App Store Connect~~
**Status:** Done
**How:**
1. Go to appstoreconnect.apple.com → My Apps → + → New App
2. Fill in:
   - **Platform:** macOS
   - **Name:** PaperClip Receiver (or similar)
   - **Primary Language:** English
   - **Bundle ID:** `me.andy.allen.PaperClipMac`
   - **SKU:** `paperclip-mac-v1`
3. Category: Utilities (primary), Productivity (secondary)
4. Age Rating: 4+
5. Upload Mac screenshots (from step 8)
6. Fill in Mac listing copy (from step 11)
7. Enter same privacy policy URL and support URL

### ~~27. Archive and Upload Mac Build~~
**Status:** Done
**How:**
1. In Xcode, select the PaperClipMac scheme, set destination to "My Mac"
2. Product → Archive
3. Organizer → Distribute App → App Store Connect → Upload
4. Wait for processing email

**Note:** macOS archive builds require proper code signing and may need a provisioning profile for the App Store. Ensure the sandbox entitlements are included.

### ~~28. Submit Mac App for Review~~
**Status:** Done — submitted 2026-04-01
**How:**
1. In App Store Connect → your Mac app → App Store tab
2. Select the uploaded build
3. Paste App Review Notes explaining it's a companion to the iPad app
4. Submit to App Review

**Important for review notes:** This is a menu bar utility — no main window, no Dock icon. Explain this is intentional (LSUIElement). Describe the two-app workflow. Mention the iPad app by name and bundle ID. If the iPad app is already approved, reference it.

---

## Phase 7: Post-Launch

### 29. Cross-Link the Apps
**Status:** Not started (blocked by both apps being approved)
**What:** Once both apps are live:
- Update the iPad app description to link to the Mac app ("Download PaperClip Receiver on the Mac App Store")
- Update the Mac app description to link to the iPad app
- Consider using App Store Connect's "Related Apps" feature if available

---

## Quick Reference

| # | Step | Status | Blocks |
|---|---|---|---|
| 1 | Rename project | Done | — |
| 2 | Privacy manifest | Done | — |
| 3 | Encryption declaration | Done | — |
| 4 | P2P transfer | Done | — |
| 5 | Mac companion app | Done | — |
| 6 | Deployment targets | Done | — |
| 7 | iPad screenshots | Done | — |
| 8 | Mac screenshots | Done | — |
| 9 | Privacy policy URL | Done | — |
| 10 | Support URL | Done | — |
| 11 | Update listing copy | Done | — |
| 12 | Update onboarding | Done | — |
| 13 | Disconnected state UI | Done | — |
| 14 | Update privacy page | Done | — |
| 15 | Update support page | Done | — |
| 16 | App icons | Done | — |
| 17 | Code signing | Done | 24, 27 |
| 18 | Version numbers | Done | — |
| 19 | Mac privacy manifest | Done | — |
| 20 | Sandbox entitlements review | Done | — |
| 21 | Developer membership | Done | — |
| 22 | App Store Connect agreements | Done | 23, 26 |
| 23 | Create iPad listing | Done | — |
| 24 | Upload iPad build | Done | — |
| 25 | Submit iPad for review | Done (2026-04-01) | — |
| 26 | Create Mac listing | Done | — |
| 27 | Upload Mac build | Done | — |
| 28 | Submit Mac for review | Done (2026-04-01) | — |
| 29 | Cross-link apps | Not started | — |

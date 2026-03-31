# PaperClip — App Store Publishing Checklist

## Overview

This document tracks every step needed to publish PaperClip to the App Store. Steps are grouped into phases. All steps within "Phase 2" can be done in parallel. Everything else is sequential.

---

## Phase 1: Code Changes (Sequential)

### ~~1. Rename project from InkOS to PaperClip~~
**Status:** Done
**Why:** InkOS was the old project name. The App Store listing, bundle ID, and all internal references need to be consistent under the final name. The bundle ID is permanent once published.

### ~~2. Add Privacy Manifest (PrivacyInfo.xcprivacy)~~
**Status:** Done (updated — clipboard declaration removed since the app no longer uses `UIPasteboard`)
**Why:** Apple requires all apps to declare which "required reason APIs" they use. PaperClip previously accessed the system clipboard, but now sends drawings over peer-to-peer Wi-Fi instead. The manifest is kept with an empty API types array since the file is still required.

### ~~3. Add ITSAppUsesNonExemptEncryption to Info.plist~~
**Status:** Done
**Why:** Every time you upload a build, Apple asks whether the app uses non-exempt encryption (for US export compliance). PaperClip doesn't use any custom encryption — just standard system APIs. Adding `ITSAppUsesNonExemptEncryption = NO` to Info.plist answers this question automatically so you don't have to click through it on every upload.

---

## Phase 2: Pre-Submission Prep (All Parallel)

These six tasks have no dependencies on each other and can be done simultaneously by different people. None of them require an Apple Developer account.

### ~~4. Decide on Deployment Target~~
**Status:** Done (set to 26.0)
**What:** The app's minimum iOS version is currently set to 26.2. This means only devices running iOS 26.2+ can install it.
**Why this matters:** A higher deployment target means fewer people can download the app. Lowering it (e.g., to 18.0) opens the app to more users, but may require adding compatibility checks for newer APIs like `liquidGlassBackground` that don't exist on older iOS versions.
**How to do it:**
1. Open `PaperClip.xcodeproj` in Xcode
2. Select the PaperClip target → General → Minimum Deployments
3. Choose a target version (18.0 is a common choice for broad support, 26.0 if you only want current devices)
4. Build the app and fix any compiler errors from APIs unavailable on the older target
5. Test on a simulator running the minimum version to verify nothing crashes

**Deliverable:** A working build at the chosen deployment target.

### ~~5. Take App Store Screenshots~~
**Status:** Done — 5 screenshots at 2064×2752 in `/Users/andrewallen/Downloads/appstore_screenshots/`
**What:** The App Store requires screenshots at the **13-inch iPad** resolution (2064 × 2752). This is the only mandatory iPad size — Apple auto-scales it for all smaller iPads on the store listing.
**Why this matters:** Screenshots are the first thing users see on your App Store listing. Apple will reject the submission if screenshots are missing. They also reject screenshots that don't match the actual app UI.

**Required resolution:**

| Device | Resolution (portrait) | Required? |
|---|---|---|
| 13" iPad | 2064 × 2752 | Yes (only mandatory iPad size) |
| iPhone 6.9" | 1320 × 2868 | Only if you support iPhone |

**Important:** Screenshots from your physical iPad (A16, 11-inch) won't work — its native resolution is 2360 × 1640, which doesn't match the required 2064 × 2752. App Store Connect requires exact pixel-match uploads. You need to use the Xcode simulator for this.

**How to do it:**
1. Open the project in Xcode and run the app in the **iPad Pro 13-inch (M4) simulator**
2. Take screenshots with **Cmd+S** in the simulator (saves to Desktop)
3. Capture 3-5 screenshots showing key screens:
   - A blank canvas (the "fresh paper" experience)
   - A canvas with handwriting on it (showing what it looks like in use)
   - The sidebar open with multiple notes listed
   - The send action / toast confirmation
4. **Optional polish:** Use a free tool like [AppMockUp](https://app-mockup.com) or Rotato to place the raw screenshots inside iPad device frames with colored backgrounds and short marketing text (e.g., "Write naturally with Apple Pencil"). This is what makes App Store listings look professional — the device frame + text overlay style.
5. You need minimum 1, maximum 10 screenshots

**Deliverable:** 1-10 PNG or JPEG images at 2064×2752.

### ~~6. Create a Privacy Policy URL~~
**Status:** Done — https://andallen.github.io/paperclip/privacy.html
**What:** A publicly accessible webpage containing a privacy policy for the app.
**Why this matters:** Apple requires this URL before you can submit. They will reject the app without it. The URL is displayed on the App Store listing and must remain accessible as long as the app is published.

**What PaperClip's privacy policy should say:**
- PaperClip does **not** collect any personal data
- Drawings are stored locally on the device in the app's sandboxed Documents folder
- No user accounts, no sign-in, no analytics, no tracking
- The send feature transmits drawings directly to a companion Mac app over local peer-to-peer Wi-Fi (AWDL) — no data passes through Apple's servers or any external server
- No third-party SDKs that collect data

**How to do it:** Create a simple page on GitHub Pages, Notion (set to public), a personal website, or any static hosting. It can be a single paragraph. The legal bar for a free app with no data collection is very low — just be honest and accurate.

**Deliverable:** A public URL (e.g., `https://yoursite.com/paperclip/privacy`).

### ~~7. Create a Support URL~~
**Status:** Done — https://andallen.github.io/paperclip/support.html
**What:** A publicly accessible URL where users can get help or report issues.
**Why this matters:** Apple requires this field when creating the app listing. It appears on the App Store page. Without it, you cannot submit.

**How to do it:** Any of these work:
- A GitHub repository with Issues enabled (users file bugs as GitHub issues)
- A simple webpage with a contact email address
- A Google Form for feedback
- A link to a personal site with a "Contact" section

**Deliverable:** A public URL.

### ~~8. Write the App Store Listing Copy~~
**Status:** Done — saved to `docs/app-store-copy.txt`
**What:** The text content that appears on your App Store page, plus a private note to Apple's review team.
**Why this matters:** These fields are required to create the app listing in App Store Connect. The description and keywords affect search ranking. The review notes prevent Apple from rejecting the app for being "incomplete" since the full workflow involves a Mac companion.

**Fields to write:**

| Field | Max Length | Guidance |
|---|---|---|
| **App Name** | 30 characters | The title on the App Store. e.g., "PaperClip" or "PaperClip - Digital Paper" |
| **Subtitle** | 30 characters | One-line tagline shown below the name. e.g., "Handwrite to Claude Code" |
| **Description** | 4000 characters | What the app does, who it's for, key features. Written for potential users browsing the store. |
| **Keywords** | 100 characters total, comma-separated | Search terms users might type. e.g., "handwriting,apple pencil,clipboard,digital paper,notes,drawing,coding". Don't repeat words already in your app name. |
| **App Review Notes** | No limit | A private note only Apple's reviewer sees. Explain the peer-to-peer architecture: the iPad sends drawings to a Mac companion receiver (PaperClipReceiver) over AWDL/Bonjour, and the Mac places them on the clipboard. The iPad app is standalone for note-taking; the send feature uses standard Apple networking APIs. |

**Deliverable:** A text document with all five fields filled out.

---

## Phase 3: Apple Developer Account (Sequential, blocks everything after)

### ~~9. Purchase Apple Developer Program Membership~~
**Status:** Done
**What:** Enroll in the Apple Developer Program at [developer.apple.com/enroll](https://developer.apple.com/enroll). Costs $99/year.
**Why this matters:** You cannot upload builds or create App Store listings without this. Nothing in Phase 4 can happen without an active membership.
**How long:** Approval typically takes a few hours to a couple of days. Apple may request identity verification.

### 10. Accept App Store Connect Agreements
**Status:** Not started (blocked by step 9)
**What:** Log into [appstoreconnect.apple.com](https://appstoreconnect.apple.com) and accept all required agreements. Fill out banking and tax information.
**Why this matters:** Even for a free app, Apple requires the Paid Applications Agreement to be signed and tax/banking info filled in before you can submit. App Store Connect will show a banner at the top if agreements need attention.

---

## Phase 4: Submission (Sequential)

### 11. Create App in App Store Connect
**Status:** Not started (blocked by step 10)
**What:** Create the app listing in App Store Connect.
**How to do it:**
1. Go to [appstoreconnect.apple.com](https://appstoreconnect.apple.com) → My Apps → **+** → New App
2. Fill in:
   - **Platform:** iOS
   - **Name:** (from step 8)
   - **Primary Language:** English
   - **Bundle ID:** Select `me.andy.allen.PaperClip` from the dropdown
   - **SKU:** Any unique string (e.g., `paperclip-v1`)
3. Set **Category** to Productivity (primary), Utilities (secondary)
4. Complete the **Age Rating** questionnaire (PaperClip should be 4+ — no objectionable content)
5. Upload screenshots (from step 5)
6. Fill in name, subtitle, description, keywords (from step 8)
7. Enter privacy policy URL (from step 6) and support URL (from step 7)

### 12. Archive and Upload the Build
**Status:** Not started (blocked by step 11)
**What:** Create a release build and upload it to App Store Connect.
**How to do it:**
1. In Xcode, set the device dropdown to **Any iOS Device (arm64)** (not a simulator)
2. Go to **Product → Archive**
3. When the Organizer window opens, click **Distribute App** → **App Store Connect** → **Upload**
4. Xcode validates the build, checks code signing, and uploads
5. Wait for a processing email from Apple (usually 5-30 minutes)
6. Check the email for any compliance warnings

**Alternative (command line):**
```bash
xcodebuild archive \
  -workspace PaperClip.xcworkspace \
  -scheme PaperClip \
  -archivePath build/PaperClip.xcarchive \
  -destination "generic/platform=iOS"

xcodebuild -exportArchive \
  -archivePath build/PaperClip.xcarchive \
  -exportPath build/AppStore \
  -exportOptionsPlist ExportOptions.plist
```
(Requires an ExportOptions.plist with `method` set to `app-store-connect`.)

### 13. Submit for App Review
**Status:** Not started (blocked by step 12)
**What:** Select the uploaded build and submit it to Apple's review team.
**How to do it:**
1. In App Store Connect, go to your app → **App Store** tab
2. Scroll to the **Build** section → click **+** → select the uploaded build
3. Paste the App Review Notes (from step 8) into the **Notes for Reviewer** field
4. Click **Add for Review** → **Submit to App Review**

**What to expect:**
- First-time submissions typically take **24-48 hours** to review
- You'll get an email when approved or if changes are requested
- Common rejection reasons for first-timers:
  - Missing privacy policy URL
  - App feels incomplete or crashes
  - Description doesn't match what the app actually does
  - Unclear functionality (the review notes from step 8 help prevent this)

---

## Quick Reference: What's Done

| # | Step | Status |
|---|---|---|
| 1 | Rename project to PaperClip | Done |
| 2 | Add PrivacyInfo.xcprivacy | Done |
| 3 | Add ITSAppUsesNonExemptEncryption | Done |
| 4 | Decide on deployment target | Done (26.0) |
| 5 | Take screenshots | Done |
| 6 | Privacy policy URL | Done |
| 7 | Support URL | Done |
| 8 | Store listing copy | Done |
| 9 | Apple Developer membership | Done |
| 10 | Accept App Store Connect agreements | Not started |
| 11 | Create app in App Store Connect | Not started |
| 12 | Archive and upload build | Not started |
| 13 | Submit for App Review | Not started |

# PaperClip

**Draw on your iPad. Paste anywhere on your Mac.**

PaperClip is a free, open source handwriting bridge that sends drawings from your iPad directly to your Mac's clipboard over peer to peer Wi-Fi. No accounts, no cloud, no subscriptions. Just draw and paste.

## How It Works

1. Open PaperClip on your iPad and draw with Apple Pencil
2. The companion Mac app auto discovers your iPad on the same network
3. Tap send and your drawing lands on your Mac clipboard as a PNG
4. Paste into any app: ChatGPT, terminals, Figma, email, notes, anything

## Features

**Drawing Canvas**
  * Full screen PencilKit canvas with Apple Pencil support
  * Native tool picker for brushes, colors, and widths
  * Multi note notebook with sidebar, search, and auto save

**Three Send Modes**
  * **Crop** selects a rectangular region of your drawing
  * **Viewport** captures exactly what's visible on screen
  * **Full Canvas** captures everything from top to bottom

**Peer to Peer Transfer**
  * Zero configuration Bonjour discovery over local Wi Fi
  * Works on restricted networks (university, corporate) via AWDL
  * Persistent TCP connection for fast, repeated sends
  * No internet connection required. Everything stays local.

**Mac Companion App**
  * Lives in your menu bar, always ready to receive
  * Shows thumbnail preview of the last received image
  * Optional start at login
  * Detects PaperClip images and displays them with appropriate styling

## Architecture

```
PaperClip/          iPad app (SwiftUI + PencilKit)
PaperClipMac/       macOS menu bar receiver (SwiftUI + Network.framework)
PaperClipReceiver/  CLI receiver for headless setups
Scripts/            Build and test scripts
```

The transfer protocol is simple: Bonjour advertises a `_paperclip._tcp` service, the iPad connects over TCP, and sends PNG frames with a 4 byte length header. Images are rendered at 2x scale with opaque white backgrounds so they look sharp in any app, light or dark.

## Requirements

* iPad running iOS 17+ with Apple Pencil
* Mac running macOS 14+
* Both devices on the same Wi Fi network

## Building

Open `PaperClip.xcodeproj` in Xcode 16+ and build the scheme you want:

* **PaperClip** for the iPad app
* **PaperClipMac** for the Mac companion

Or use the included build scripts:

```bash
Scripts/buildapp       # Build the iPad app
Scripts/buildmac       # Build the Mac app
Scripts/buildreceiver  # Build the CLI receiver
```

## Privacy

PaperClip never connects to the internet. All transfers happen directly between your devices over local Wi Fi. No analytics, no tracking, no data collection. Your drawings never leave your network.

## License

MIT

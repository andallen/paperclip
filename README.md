# PaperClip

PaperClip sends handwriting from an iPad to a Mac's system clipboard over peer to peer Wi Fi. You draw with Apple Pencil, tap send, and the image is on your clipboard as a PNG. It works with any app that accepts pasted images.

There are two components: an iPad app built with SwiftUI and PencilKit, and a macOS menu bar app that listens for incoming images and writes them to `NSPasteboard`.

## How It Works

The two devices find each other automatically using Bonjour. The connection runs over AWDL, which is the same transport AirDrop uses, so it works even on restricted networks like college WiFi. No internet connection is involved and nothing leaves your local network.

Once connected, the iPad holds a persistent TCP connection to the Mac and reuses it for every send. Images arrive on the Mac as PNG data and get written straight to the system clipboard.

There are three send modes: **Viewport** captures what's currently visible on screen, **Crop** lets you drag a selection rectangle, and **Full Canvas** captures everything from top to bottom. All three render at 2x scale with a white background.

## The iPad App

The drawing surface uses PencilKit with Apple Pencil only input. The canvas scrolls vertically and extends as you draw, up to a height cap that keeps exported images within size limits that work well when pasting into AI chat apps.

Notes are saved locally as JSON files with the drawing data serialized alongside metadata and a thumbnail. Auto save kicks in 2 seconds after your last stroke.

## The Mac App

A menu bar app that advertises itself on the network and waits for connections. When an image arrives it goes directly to the clipboard. The menu bar shows connection status, a thumbnail of the last received image, and a start at login toggle.

There's also a headless CLI receiver (`PaperClipReceiver`) for setups without a GUI.

## Project Structure

```
PaperClip/              iPad app (SwiftUI + PencilKit)
PaperClipMac/           macOS menu bar receiver
PaperClipReceiver/      Headless CLI receiver
Scripts/                Build and test scripts
```

## Building

Requires Xcode 16+. Open `PaperClip.xcodeproj` and build the `PaperClip` scheme for iPad or `PaperClipMac` for the Mac companion. Both devices need to be on the same Wi Fi network.

```
Scripts/buildapp        # iPad app
Scripts/buildmac        # Mac menu bar app
Scripts/buildreceiver   # CLI receiver
```

The iPad app requires iOS 17+ and the Mac app requires macOS 14+.

## License

[MIT](LICENSE)

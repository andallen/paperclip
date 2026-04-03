# PaperClip

PaperClip sends handwriting from an iPad to a Mac's system clipboard over peer to peer Wi Fi. You draw with Apple Pencil, tap send, and the image is on your clipboard as a PNG. It works with any app that accepts pasted images.

There are two components: an iPad app built with SwiftUI and PencilKit, and a macOS menu bar app that listens for incoming images and writes them to `NSPasteboard`.

## Transfer Protocol

Both devices discover each other automatically via Bonjour, advertising a `_paperclip._tcp` service. The connection uses `Network.framework` with `includePeerToPeer = true`, which enables AWDL (the same transport AirDrop uses). This means it works on restricted networks like college WiFi where multicast DNS might otherwise be blocked.

Once the iPad discovers the Mac's service, it opens a persistent TCP connection that stays alive across multiple sends. The wire format is simple:

```
[4 bytes: payload length, big endian UInt32] [N bytes: payload]
```

The first frame after connecting sends the iPad's device name as UTF 8 text. All subsequent frames are PNG image data. The Mac receiver distinguishes between the two by checking for PNG magic bytes (`89 50 4E 47 0D 0A 1A 0A`) at the start of each payload.

Payloads can arrive in chunks smaller than the requested length, so the receiver accumulates bytes in a loop until the full frame is assembled before processing.

## PNG Metadata

Each PNG embeds a marker in its `tEXt` chunk via `kCGImagePropertyPNGDescription`. The format is `PaperClip-v1:<mode>` where mode is one of `crop`, `viewport`, or `fullCanvas`. The Mac app reads this to decide how to display the thumbnail (rounded corners for cropped/viewport captures, sharp corners for full canvas).

The metadata is written using `CGImageDestination` and read back with `CGImageSource`, both from ImageIO.

## Canvas

The drawing surface is a `PKCanvasView` subclass (`OverlayPassthroughCanvasView`) with a few modifications:

**Height capping.** The content height extends dynamically as you draw but is hard capped at 4000pt. At the 2x render scale used for export, that produces an 8000px tall image, which is the largest size that works reliably when pasting into AI chat interfaces.

**Hit test passthrough.** PKCanvasView is a UIScrollView subclass and aggressively captures touch events. The custom `hitTest` temporarily hides the canvas from the view hierarchy and re runs the hit test on the window to find SwiftUI buttons layered above it in a ZStack. Without this, overlay controls are untappable.

**Edit menu suppression.** PKCanvasView inherits UIScrollView's edit menu interaction, which causes a "Select All" popup on finger taps. The subclass strips `UIEditMenuInteraction` on every layout pass because PencilKit re adds it internally.

## Send Modes

Images are rendered at 2x scale with an opaque white background (avoids transparency issues in dark mode apps).

**Viewport** captures the visible portion of the canvas. **Crop** lets you drag a rectangle and captures that region. **Full Canvas** renders from the top of the canvas down to the lowest stroke.

## Note Storage

Notes are stored as JSON files in the app's documents directory. Each file contains metadata (title, timestamps) and the PencilKit drawing serialized via `PKDrawing.dataRepresentation()`. Sidebar thumbnails are PNG snapshots stored inline. Auto save triggers 2 seconds after the last drawing change.

## Project Structure

```
PaperClip/              iPad app
  PaperClipApp.swift    Entry point, onboarding gate
  Features/
    Notebook/
      Core/             NoteModel (metadata + drawing data)
      Services/         TransferService (Bonjour + send), SessionService (persistence)
      ViewModels/       NotebookViewModel (drawing state, auto save)
      Views/            Canvas, sidebar, send controls
    Shared/             PNGMetadata, OnboardingView

PaperClipMac/           macOS menu bar receiver
  ReceiverService.swift NWListener + clipboard write
  MenuBarView.swift     Status, thumbnail, settings

PaperClipReceiver/      Headless CLI receiver (same protocol)
Scripts/                Build and test shell scripts
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

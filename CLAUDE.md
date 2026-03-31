# PaperClip — Digital Paper for Claude Code

## Project Overview

PaperClip is an iPad app that acts as digital paper. You write with Apple Pencil, tap send, and a raw image of your handwriting appears in Claude Code on your Mac. The iPad sends drawings directly to a small Mac receiver daemon over peer-to-peer Wi-Fi (AWDL), bypassing Universal Clipboard entirely.

## Directory Structure

```
PaperClip/
├── PaperClip/                                      # iPad app source
│   ├── PaperClipApp.swift                          # App entry point (@main)
│   ├── App/
│   │   └── AppRootView.swift                   # Root view: sidebar toggle, note switching, note creation
│   └── Features/
│       ├── Notebook/
│       │   ├── Core/
│       │   │   └── NoteModel.swift             # NoteMetadata + NoteData models (PKDrawing storage)
│       │   ├── Design/
│       │   │   └── NotebookDesignTokens.swift  # NotebookPalette (colors), NotebookTypography, spacing
│       │   ├── Services/
│       │   │   ├── SessionService.swift        # NoteService: note CRUD, JSON persistence in Documents/notes/
│       │   │   └── TransferService.swift       # TransferService: Bonjour P2P discovery + PNG send to Mac
│       │   ├── ViewModels/
│       │   │   └── NotebookViewModel.swift     # NoteViewModel: drawing state, auto-save with debounce
│       │   └── Views/
│       │       ├── NotebookCanvasView.swift     # NoteCanvasView: full-screen PencilKit canvas + send button + toast
│       │       ├── CanvasInputView.swift        # CanvasView: PKCanvasView UIViewRepresentable wrapper
│       │       ├── PencilKitToolbarView.swift   # PKToolPicker UIViewRepresentable wrapper
│       │       ├── SidebarView.swift            # Note list with search, rename (context menu), delete
│       │       └── SettingsView.swift           # User preferences (untracked, in progress)
│       └── Shared/
│           ├── PNGMetadata.swift                # PNG tEXt marker: embed "PaperClip-v1", detect on read
│           └── UIComponents.swift               # Reusable glass-effect UI components
│
├── PaperClipUITests/
│   └── PaperClipUITests.swift                      # UI test suite
│
├── PaperClipReceiver/
│   └── main.swift                                  # Mac receiver daemon (single-file Swift CLI)
│
├── Scripts/
│   ├── buildapp                                # Build iPad app (xcodebuild)
│   ├── buildreceiver                           # Build Mac receiver (swiftc)
│   ├── install-receiver                        # Install receiver as launchd agent
│   ├── uninstall-receiver                      # Remove receiver and launchd agent
│   ├── test-transfer                           # Loopback test: receiver + send + clipboard verify
│   ├── testapp                                 # Run unit tests
│   ├── test-ui                                 # Run UI tests
│   └── run-ui-tests                            # UI test runner with device selection
│
├── apple-hig/                                  # Apple Human Interface Guidelines reference docs
├── PaperClip.xcodeproj/                            # Xcode project
├── PaperClip.xcworkspace/                          # Xcode workspace
└── Logs/                                       # Build and test log output
```

**Note on filenames**: Some files on disk have legacy names that differ from the class names inside them. `SessionService.swift` contains `NoteService`, `NotebookViewModel.swift` contains `NoteViewModel`, `NotebookCanvasView.swift` contains `NoteCanvasView`, and `CanvasInputView.swift` contains `CanvasView`.

## Architecture

### iPad App
- **PencilKit canvas** — full-screen drawing with Apple Pencil (pencil-only policy, finger scrolls)
- **Send button** — captures drawing as PNG with embedded `PaperClip-v1` metadata marker, sends to Mac via peer-to-peer
- **TransferService** — discovers Mac receiver via Bonjour (`_paperclip._tcp`) with AWDL peer-to-peer. Maintains a persistent connection for instant sends. Shows connection status indicator near send button.
- **Note persistence** — PKDrawing serialized to JSON files in Documents/notes/
- **Sidebar** — slide-in panel for browsing notes, search, rename (long-press context menu), delete

### Mac Receiver (PaperClipReceiver)
- **Single-file Swift CLI** — listens on `_paperclip._tcp` with `.includePeerToPeer` (AWDL)
- **Protocol** — 4-byte big-endian UInt32 length header + raw PNG bytes (repeated on persistent connection)
- **Clipboard** — received PNGs are written to `NSPasteboard.general` for Cmd+V
- **launchd agent** — install once via `Scripts/install-receiver`, starts on login, runs silently

### PNG Metadata Marker
Images are marked by embedding `"PaperClip-v1"` in the PNG tEXt description chunk via `CGImageDestination`.

## Project Rules

### 1. Comments
- Comment frequently with simple and direct language
- Concisely spell out what every part of the code is doing
- Be impersonal; no first/second/third person

### 2. Quality Assurance
- Make errors explicit. No force unwraps (`!`), `try!`, or `fatalError`
- Use `throws` and pass error messages back to the UI

## Build Commands

- **Build iOS**: `Scripts/buildapp`
- **Build Mac receiver**: `Scripts/buildreceiver`
- **Install Mac receiver**: `Scripts/install-receiver`
- **Test iOS**: `Scripts/testapp`
- **UI Test iOS**: `Scripts/test-ui`
- **Test transfer**: `Scripts/test-transfer`

# InkOS Project Structure

## Project Overview

InkOS is an iPad note-taking app built with SwiftUI and the MyScript iink SDK for handwriting recognition. The app uses a bundle-based storage system for notebooks and supports PDF annotation.

## Module Organization

```
InkOS/
├── InkOS/                                # App source root
│   ├── InkOSApp.swift                    # App entry point
│   ├── InkOS-Bridging-Header.h           # Exposes MyScript Obj-C headers to Swift
│   ├── Info.plist                        # App configuration
│   ├── theme.css                         # Styling for text rendering
│   │
│   ├── App/                              # High-level navigation & integration
│   │   ├── AppRootView.swift             # Root view (Loading -> Dashboard)
│   │   ├── EditorHostView.swift          # SwiftUI bridge for EditorViewController
│   │   └── NotebookTransition/           # Custom notebook open/close animations
│   │       ├── EditorNavigationController.swift
│   │       ├── NotebookPresentAnimator.swift
│   │       ├── NotebookDismissAnimator.swift
│   │       └── NotebookTransitionCoordinator.swift
│   │
│   ├── Features/                         # SwiftUI Feature Modules
│   │   ├── Dashboard/                    # Notebook library and management UI
│   │   │   ├── DashboardView.swift       # Main dashboard view
│   │   │   ├── DashboardItem.swift       # Dashboard item model
│   │   │   ├── DashboardComponents.swift # Reusable dashboard UI components
│   │   │   ├── DashboardAlerts.swift     # Alert dialogs for dashboard actions
│   │   │   ├── NotebookLibrary.swift     # Notebook data source
│   │   │   ├── FolderCard.swift          # Folder display card
│   │   │   ├── FolderOverlay.swift       # Folder contents overlay
│   │   │   ├── FolderDropDelegate.swift  # Drag-and-drop folder handling
│   │   │   ├── MoveToFolderSheet.swift   # Move notebook to folder UI
│   │   │   └── ContextMenuOverlay.swift  # Context menu presentation overlay
│   │   │
│   │   ├── Notebook/                     # Notebook metadata models
│   │   │   └── NotebookModel.swift
│   │   │
│   │   ├── PDFImport/                    # PDF import functionality
│   │   │   ├── PDFDataModel.swift        # NoteDocument, NoteBlock, ImportCoordinator
│   │   │   └── PDFImport.swift           # PDFDocumentWrapper implementation
│   │   │
│   │   ├── PDFDisplay/                   # PDF viewing and annotation
│   │   │   ├── PDFEditorHostView.swift   # SwiftUI bridge for PDF editor
│   │   │   ├── PDFEditorViewController.swift  # PDF editor controller
│   │   │   ├── PDFEditorViewModel.swift  # PDF editor state management
│   │   │   ├── PDFPageLayout.swift       # PDF page layout calculations
│   │   │   ├── PDFBackgroundRenderer.swift    # PDF background rendering
│   │   │   ├── DottedGridView.swift      # Grid overlay for annotation
│   │   │   └── PDFStubs.swift            # PDF-related stub implementations
│   │   │
│   │   └── Shared/                       # Shared UI components & utilities
│   │       ├── ContextMenuView.swift     # Reusable context menu component
│   │       ├── NotebookNotifications.swift
│   │       └── UIComponents.swift
│   │
│   ├── Storage/                          # Persistence Layer (Actors)
│   │   ├── BundleManager.swift           # Central actor for file system operations
│   │   ├── BundleStorage.swift           # Helper for directory paths
│   │   ├── DocumentHandle.swift          # Safe handle for open notebook operations
│   │   ├── PDFDocumentHandle.swift       # Handle for PDF document operations
│   │   ├── Manifest.swift                # JSON metadata structure
│   │   ├── FolderManifest.swift          # Folder metadata structure
│   │   ├── SDKProtocols.swift            # SDK protocol definitions
│   │   │
│   │   └── JIIXPersistence/              # JIIX format persistence
│   │       ├── JIIXPersistenceTypes.swift         # Error types, protocols, configuration
│   │       ├── JIIXPersistenceService.swift       # Persistence service
│   │       └── IINKEditorExportExtension.swift    # Editor export extension
│   │
│   ├── Editor/                           # EDITOR IMPLEMENTATION (Core Logic)
│   │   ├── EditorViewController.swift    # The main Editor Canvas UI
│   │   ├── EditorViewModel.swift         # Editor state & tool logic
│   │   ├── EngineProvider.swift          # Singleton managing IINKEngine lifecycle
│   │   ├── ToolPaletteView.swift         # Floating custom toolbar
│   │   ├── EditingToolbarView.swift      # Undo/Redo/Clear toolbar
│   │   ├── ColorThicknessPillView.swift  # Color and thickness selection UI
│   │   │
│   │   └── RawContentConfiguration/      # MyScript Raw Content mode settings
│   │       └── RawContentConfiguration.swift  # Configuration applier for recognition
│   │
│   ├── Frameworks/
│   │   └── Ink/                          # Low-level MyScript Wrappers
│   │       ├── IInkUIReferenceImplementation-Bridging-Header.h
│   │       │
│   │       ├── Input/                    # Touch/Pen input handling
│   │       │   ├── InputViewController.swift
│   │       │   └── InputViewModel.swift
│   │       │
│   │       ├── Rendering/                # Display & rendering logic
│   │       │   ├── DisplayViewController.swift
│   │       │   └── DisplayViewModel.swift
│   │       │
│   │       ├── UIObjects/                # Core UI rendering components
│   │       │   ├── Canvas.swift
│   │       │   ├── InputView.swift
│   │       │   ├── RenderView.swift
│   │       │   └── OffscreenRenderSurfaces.swift
│   │       │
│   │       ├── SmartGuide/               # Text conversion guide UI
│   │       │   ├── SmartGuideViewController.h
│   │       │   └── SmartGuideViewController.mm
│   │       │
│   │       └── Utils/                    # Utility helpers
│   │           ├── FontMetricsProvider.swift
│   │           ├── ImageLoader.swift
│   │           ├── ImagePainter.swift
│   │           ├── TextFormatHelper.swift
│   │           ├── IInkUIRefImplUtils.swift
│   │           ├── ContextualActionsHelper.swift
│   │           ├── Helper.swift
│   │           ├── Path.swift
│   │           ├── SynchronizedSwift.swift
│   │           ├── UIFont+Helper.swift
│   │           ├── NSFileManager+Additions.swift
│   │           ├── NSAttributedString+Helper.swift
│   │           └── CTRun+Metrics.swift
│   │
│   └── Assets.xcassets                   # App assets
│
├── InkOSTests/                           # Unit test suite
│   ├── Editor/
│   │   ├── EditorViewModelTests.swift
│   │   ├── EngineProviderTests.swift
│   │   └── InputViewModelTests.swift
│   │
│   ├── Features/
│   │   ├── NotebookModelTests.swift
│   │   └── PDFImport/
│   │
│   ├── Rendering/
│   │   ├── DisplayViewModelTests.swift
│   │   └── OffscreenRenderSurfacesTests.swift
│   │
│   └── Storage/
│       ├── BundleManagerTests.swift
│       ├── BundleStorageTests.swift
│       ├── DocumentHandleTests.swift
│       └── ManifestTests.swift
│
├── InkOSUITests/                         # UI test suite
│   └── InkOSUITests.swift
│
├── MyScriptCertificate/                  # License Key
│   ├── MyCertificate.h
│   └── me.andy.allen.Trivial.c
│
├── Scripts/                              # Build & Utility Scripts
│   ├── buildapp                          # Build executable
│   ├── testapp                           # Test executable
│   ├── grablogs                          # Grab logs script
│   └── retrieve_recognition-assets.sh    # Download recognition assets
│
├── Docs/                                 # Reference documentation
│   ├── myscript_docs.md
│   ├── myscript_headers.txt
│   └── myscript-reference.txt
│
├── recognition-assets/                   # MyScript recognition data (binary)
│   └── resources/
│       ├── en_US/                        # English language resources
│       ├── math/                         # Math recognition
│       └── shape/                        # Shape recognition
│
└── Logs/                                 # Build artifacts & logs
```

## Project Rules

### 1. Comments
- Comment frequently with simple and direct language
- Concisely spell out what every part of the code is doing, making the logic easy to follow
- Use clear grammar and avoid special headers, decorative markers, or section labels
- Be impersonal; no first/second/third person

### 2. Architectural Decoupling
- The UI must remain replaceable. SwiftUI views should only handle presentation and layout
- Data and storage code must live outside the UI. Centralize all file-system access in **BundleManager** and **EngineProvider**

### 3. Quality Assurance
- Make errors explicit. Do not use force unwraps (`!`), `try!`, or `fatalError` for expected runtime issues
- Use `throws` and pass error messages back to the UI so the user can be notified

### 4. Security & Configuration
- Do not commit private keys or license material beyond the checked-in certificate files
- Treat `recognition-assets/` as large binary dependencies; avoid editing by hand

## Build Commands

- **Build**: `Scripts/buildapp`
- **Test**: `Scripts/testapp`
- **Grab Logs**: `Scripts/grablogs`

## Key Architecture Notes

See subdirectory CLAUDE.md files for layer-specific rules:
- `InkOS/Editor/CLAUDE.md` - MainActor isolation and thread safety for MyScript SDK
- `InkOS/Storage/CLAUDE.md` - Actor isolation for BundleManager and DocumentHandle
- `InkOS/Features/Dashboard/CLAUDE.md` - Dashboard UI consistency guidelines

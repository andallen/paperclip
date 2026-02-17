# Alan Project Structure

## Project Overview

Alan is an iPad app built with SwiftUI and the MyScript iink SDK for handwriting recognition. It features a tutoring agent (Alan) that generates interactive notebook content through a subagent architecture.

## Module Organization

```
Alan/
├── InkOS/                                # App source root
│   ├── InkOSApp.swift                    # App entry point
│   ├── InkOS-Bridging-Header.h           # Exposes MyScript Obj-C headers to Swift
│   ├── App/                              # High-level navigation (AppRootView)
│   │
│   ├── Features/                         # Feature Modules
│   │   ├── Alan/                         # Alan tutoring agent system
│   │   │   ├── Core/                     # AlanContract, AlanError
│   │   │   ├── Networking/               # AlanAPIClient, AlanEndpoints, SSEParser
│   │   │   └── Orchestration/            # OrchestrationActor, BlockFactory, OutputParser
│   │   │
│   │   ├── Auth/                         # AuthManager (Firebase auth)
│   │   │
│   │   ├── Block/                        # Block primitive system (content model)
│   │   │   ├── Core/                     # BlockContract, BlockContent
│   │   │   ├── Content/                  # Text, Image, Graphics, Table, Embed, Input, Checkpoint
│   │   │   ├── Rendering/               # HTMLRenderer
│   │   │   └── Views/                    # GraphicsBlockView
│   │   │
│   │   ├── Memory/                       # MemoryContract, MemoryManager, MemoryAPIClient
│   │   │
│   │   ├── Notebook/                     # Notebook UI and data models
│   │   │   ├── Core/                     # NotebookContract
│   │   │   ├── Design/                   # NotebookDesignTokens
│   │   │   ├── ViewModels/               # NotebookViewModel
│   │   │   └── Views/                    # Canvas, BlockContainer, Input, Toolbar
│   │   │       ├── AlanPresence/         # Metal metaball avatar animation
│   │   │       └── Blocks/              # Per-type block views
│   │   │           ├── Image/            # Image subcomponents (display, loading, attribution)
│   │   │           └── Text/             # Text subcomponents (plain, code, LaTeX, kinetic)
│   │   │
│   │   └── Shared/                       # UIComponents, FileLogger, ContextMenuView
│   │
│   ├── Editor/                           # EditorViewModel, EditorUIComponents
│   ├── Storage/                          # BundleStorage, JIIXPersistence
│   │
│   └── Frameworks/
│       └── Ink/                          # MyScript SDK Wrappers
│           ├── EngineProvider.swift       # MyScript engine singleton
│           ├── Input/                    # Touch/Pen input handling
│           ├── Rendering/               # Display & rendering logic
│           ├── UIObjects/               # Canvas, InputView, RenderView
│           ├── SmartGuide/              # Text conversion guide (Obj-C++)
│           └── Utils/                    # Font, image, text helpers
│
├── InkOSTests/                           # Unit tests (Alan, Block, Memory, Notebook, Rendering)
├── InkOSUITests/                         # UI tests
│
├── Firebase/                             # Firebase backend services
│   └── functions/src/
│       ├── alan/                         # Alan agent (Gemini), prompts, output schema
│       ├── memory/                       # Memory system (schema, subagent, LLM processor, rules)
│       ├── subagents/                    # Router, visual router, table/image/graphics/embed subagents
│       │   └── apis/                     # Image library APIs (NASA, Wikimedia, museums, PubChem, etc.)
│       └── __tests__/                    # Jest test suites (alan/, memory/)
│
├── Scripts/                              # buildapp, testapp, test-ui, run-ui-tests, html-preview
├── Docs/                                 # MyScript docs, NotebookDesignSystem.md
├── apple-hig/                            # Apple Human Interface Guidelines reference
├── recognition-assets/                   # MyScript recognition data (binary, do not edit)
├── MyScriptCertificate/                  # License key files
└── Podfile / Pods/                       # CocoaPods dependencies
```

## Architecture Overview

### Alan Agent System

Alan is the main tutoring agent that generates notebook content. It uses a subagent architecture:

1. **Alan Agent** (`alan/alanAgent.ts`) - Main tutoring agent powered by Gemini. Outputs Text/Input blocks directly and delegates Table/Visual blocks to specialized subagents. Supports session model tracking and memory context.

2. **Subagent Router** (`subagents/subagentRouter.ts`) - Dispatches requests to appropriate subagents based on `target_type`.

3. **Visual Router** (`subagents/visualRouter.ts`) - Routes visual requests to image, graphics, or embed subagents based on intent.

4. **Subagents**:
   - **Table** - Generates table content
   - **Image** - Searches educational image libraries (NASA, Wikimedia, museums, PubChem, etc.)
   - **Graphics** - Creates interactive visualizations (Chart.js, p5.js, Three.js, JSXGraph)
   - **Embed** - Matches to embed providers (PhET, Desmos, YouTube)

5. **Memory System** (`memory/`) - Manages long-term user context:
   - **memorySchema** - Defines memory types (facts, preferences, concepts)
   - **memorySubagent** - Endpoint for memory operations
   - **llmProcessor** - Extracts memorable information from conversations
   - **rules** - Scores memory importance for retention

### iOS Orchestration

The iOS app coordinates with the backend through:

1. **OrchestrationActor** - Sends messages to Alan, processes streaming responses, dispatches subagent requests in parallel. Manages session model and memory context.
2. **AlanAPIClient** - HTTP client for Alan and subagent endpoints
3. **SSEParser** - Parses server-sent events for streaming responses
4. **BlockFactory** - Creates Block instances from subagent responses
5. **MemoryManager** - Client-side memory operations and caching
6. **AuthManager** - Firebase authentication management

### Notebook UI System

The notebook UI is built with SwiftUI and Metal:

1. **NotebookViewModel** - Coordinates notebook state, block management, and Alan orchestration
2. **NotebookCanvasView** - Main scrollable canvas displaying blocks
3. **BlockContainerView** - Handles layout and animations for individual blocks
4. **Block Views** - Specialized views for each content type (Text, Image, Table, Graphics, Embed, Input, Checkpoint)
5. **AlanPresence** - Animated avatar using Metal shaders for metaball effects

## Project Rules

### 1. Comments
- Comment frequently with simple and direct language
- Concisely spell out what every part of the code is doing, making the logic easy to follow
- Use clear grammar and avoid special headers, decorative markers, or section labels
- Be impersonal; no first/second/third person

### 2. Quality Assurance
- Make errors explicit. Do not use force unwraps (`!`), `try!`, or `fatalError` for expected runtime issues
- Use `throws` and pass error messages back to the UI so the user can be notified

### 3. Security & Configuration
- Do not commit private keys or license material beyond the checked-in certificate files
- Treat `recognition-assets/` as large binary dependencies; avoid editing by hand

## Build Commands

- **Build iOS**: `Scripts/buildapp`
- **Test iOS**: `Scripts/testapp`
- **UI Test iOS**: `Scripts/test-ui`
- **Build Firebase**: `cd Firebase/functions && npm run build`
- **Test Firebase**: `cd Firebase/functions && npm test`
- **Deploy Firebase**: `cd Firebase && firebase deploy --only functions`

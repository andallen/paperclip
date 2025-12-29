# Editor Layer Rules

## MAIN ACTOR ISOLATION & THREAD SAFETY

### MyScript Thread Safety Requirements

The EngineProvider must be annotated with `@MainActor` because the MyScript `IINKEditor` and `IINKRenderer` are not thread-safe and must be accessed from the main thread to sync with the UI.

### Implementation Requirements
- EngineProvider must be annotated with `@MainActor class EngineProvider`
- Any classes that directly interact with IINKEditor or IINKRenderer must also use `@MainActor`
- UI components that call MyScript APIs can safely do so because they already run on the main thread

### Background Operations

Perform heavy export operations (e.g., converting ink to PDF or high-resolution images) in detached tasks or background blocks provided by the SDK to avoid hanging the UI.

Use patterns like:
```swift
Task.detached {
  // Heavy export operation here
  await MainActor.run {
    // Update UI with results
  }
}
```

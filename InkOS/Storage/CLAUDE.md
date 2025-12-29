# Storage Layer Rules

## ACTOR ISOLATION & THREAD SAFETY

The BundleManager and DocumentHandle must remain Actors to manage disk I/O and folder state without race conditions.

### Why Actors?
- BundleManager coordinates all file system operations for notebook bundles
- DocumentHandle manages the lifecycle of an opened notebook
- Both perform disk I/O that must be serialized to prevent data corruption
- Actor isolation ensures that concurrent access to the same notebook or file system state is safely serialized

### Implementation Requirements
- BundleManager must be declared as `actor BundleManager`
- DocumentHandle must be declared as `actor DocumentHandle`
- All methods that modify file system state must be async and called with `await`
- Public APIs should return Sendable types (like NotebookMetadata) to safely pass data across actor boundaries

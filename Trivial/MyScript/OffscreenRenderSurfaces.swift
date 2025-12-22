import UIKit
import CoreGraphics

// Manages CGLayer buffers for offscreen rendering.
// The MyScript renderer creates offscreen surfaces for tiling and caching.
// Matches reference pattern: NSObject container with @objc scale and NSNumber keys.
class OffscreenRenderSurfaces: NSObject {
    @objc var scale: CGFloat = 1.0
    
    private var surfaces: [NSNumber: CGLayer] = [:]
    private var nextId: UInt32 = 1
    private let lock = NSLock()
    
    // Create a new offscreen surface and return its ID.
    // The returned UInt32 must be converted to NSNumber(value:) for consistent lookup/release.
    @objc func addSurface(with buffer: CGLayer) -> UInt32 {
        lock.lock()
        defer { lock.unlock() }
        
        let id = nextId
        nextId += 1
        
        // Store using NSNumber key for Objective-C compatibility.
        surfaces[NSNumber(value: id)] = buffer
        return id
    }
    
    // Retrieve a surface buffer by ID.
    // Converts UInt32 to NSNumber(value:) for lookup to match storage key.
    @objc func getSurfaceBuffer(_ id: UInt32) -> CGLayer? {
        lock.lock()
        defer { lock.unlock() }
        return surfaces[NSNumber(value: id)]
    }
    
    // Release a surface by ID.
    // Converts UInt32 to NSNumber(value:) for removal to match storage key.
    @objc func releaseSurface(_ id: UInt32) {
        lock.lock()
        defer { lock.unlock() }
        surfaces.removeValue(forKey: NSNumber(value: id))
    }
    
    // Get the context for a surface (helper method).
    func getContext(_ id: UInt32) -> CGContext? {
        return getSurfaceBuffer(id)?.context
    }
}


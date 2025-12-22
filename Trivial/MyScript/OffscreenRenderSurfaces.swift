import UIKit
import CoreGraphics

// Manages CGLayer buffers for offscreen rendering.
// The MyScript renderer creates offscreen surfaces for tiling and caching.
class OffscreenRenderSurfaces {
    var scale: CGFloat = 1.0
    private var surfaces: [UInt32: CGLayer] = [:]
    private var nextId: UInt32 = 1
    private let lock = NSLock()
    
    // Structure to hold surface buffer information.
    struct SurfaceBuffer {
        let context: CGContext
        let size: CGSize
    }
    
    // Create a new offscreen surface and return its ID.
    func createSurface(width: Int32, height: Int32, context: CGContext, alphaMask: Bool) -> UInt32 {
        lock.lock()
        defer { lock.unlock() }
        
        let id = nextId
        nextId += 1
        
        // Create a CGLayer for offscreen rendering.
        let size = CGSize(width: CGFloat(width), height: CGFloat(height))
        let layer = CGLayer(context, size: size, auxiliaryInfo: nil)
        
        surfaces[id] = layer
        return id
    }
    
    // Retrieve a surface by ID.
    func getSurface(_ id: UInt32) -> CGLayer? {
        lock.lock()
        defer { lock.unlock() }
        return surfaces[id]
    }
    
    // Release a surface by ID.
    func releaseSurface(_ id: UInt32) {
        lock.lock()
        defer { lock.unlock() }
        surfaces.removeValue(forKey: id)
    }
    
    // Get the context for a surface.
    func getContext(_ id: UInt32) -> CGContext? {
        lock.lock()
        defer { lock.unlock() }
        return surfaces[id]?.context
    }
    
    // Get surface buffer with context and size information.
    func getSurfaceBuffer(_ id: UInt32) -> SurfaceBuffer? {
        guard let layer = getSurface(id), let ctx = layer.context else { return nil }
        return SurfaceBuffer(context: ctx, size: layer.size)
    }
    
    // Add a surface from an existing CGLayer.
    func addSurface(with layer: CGLayer) -> UInt32 {
        lock.lock()
        defer { lock.unlock() }
        let id = nextId
        nextId += 1
        surfaces[id] = layer
        return id
    }
}


import UIKit

// Custom view that bridges MyScript rendering to the UIKit screen.
class RenderView: UIView, IINKIRenderTarget {
    weak var renderer: IINKRenderer?
    weak var editor: IINKEditor?
    private var canvas: Canvas?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        self.isMultipleTouchEnabled = true
        self.canvas = Canvas()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - IINKIRenderTarget
    
    func invalidate(_ renderer: IINKRenderer, layers: IINKLayerType) {
        // Dispatch to main thread since setNeedsDisplay() must be called on the main thread.
        // The MyScript SDK may call this from background threads.
        DispatchQueue.main.async { [weak self] in
            self?.setNeedsDisplay()
        }
    }

    func invalidate(_ renderer: IINKRenderer, area: CGRect, layers: IINKLayerType) {
        // Dispatch to main thread since setNeedsDisplay() must be called on the main thread.
        // The MyScript SDK may call this from background threads.
        DispatchQueue.main.async { [weak self] in
            self?.setNeedsDisplay(area)
        }
    }

    var pixelDensity: Float {
        return Float(self.contentScaleFactor)
    }
    
    func createOffscreenRenderSurface(width: Int32, height: Int32, alphaMask: Bool) -> UInt32 {
        // Basic implementation - returns 0 for now
        // Can be extended to create actual offscreen surfaces if needed
        return 0
    }
    
    func releaseOffscreenRenderSurface(_ surfaceId: UInt32) {
        // Basic implementation - no-op for now
    }
    
    func createOffscreenRenderCanvas(_ surfaceId: UInt32) -> IINKICanvas {
        let canvas = Canvas()
        // Set up canvas for offscreen rendering if needed
        return canvas
    }
    
    func releaseOffscreenRenderCanvas(_ canvas: IINKICanvas) {
        // Basic implementation - no-op for now
    }

    // MARK: - Drawing

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext(), let renderer = renderer, let canvas = canvas else { return }
        
        // Set up the canvas with the current graphics context.
        canvas.context = context
        canvas.size = self.bounds.size
        canvas.clearAtStartDraw = false
        
        // Draw the permanent background ink (Model) and the active strokes (Capture).
        renderer.drawModel(rect, canvas: canvas)
        renderer.drawCaptureStrokes(rect, canvas: canvas)
    }

    // MARK: - Input Routing

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        processTouches(touches, type: .down)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let event = event else { return }
        let coalesced = event.coalescedTouches(for: touch) ?? [touch]
        processTouches(Set(coalesced), type: .move)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        processTouches(touches, type: .up)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let editor = editor else { return }
        for touch in touches {
            let pointerId = Int32(truncatingIfNeeded: touch.hash)
            try? editor.pointerCancel(Int(pointerId))
        }
    }

    private func processTouches(_ touches: Set<UITouch>, type: IINKPointerEventType) {
        guard let editor = editor else { return }
        
        let pointerEvents = touches.map { touch in
            let location = touch.location(in: self)
            let force = touch.maximumPossibleForce > 0 ? Float(touch.force / touch.maximumPossibleForce) : 0
            let timestamp = Int64(touch.timestamp * 1000)
            let pointerType: IINKPointerType = (touch.type == .stylus) ? .pen : .touch
            let pointerId = Int32(truncatingIfNeeded: touch.hash)

            return IINKPointerEventMake(type, location, timestamp, force, pointerType, pointerId)
        }

        // Convert array to UnsafeMutablePointer for the API
        var mutableEvents = pointerEvents
        let count = mutableEvents.count
        mutableEvents.withUnsafeMutableBufferPointer { buffer in
            guard let baseAddress = buffer.baseAddress else { return }
            try? editor.pointerEvents(baseAddress, count: count, doProcessGestures: true)
        }
    }
}
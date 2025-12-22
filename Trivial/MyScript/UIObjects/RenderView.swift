import UIKit

// Draws either the model layer or the capture layer.
final class RenderView: UIView {
    // Selects which renderer layer should be drawn.
    private let layerType: IINKLayerType

    // Holds the renderer created by the engine.
    var renderer: IINKRenderer?

    // Provides access to offscreen buffers used by the renderer.
    var offscreenRenderSurfaces: OffscreenRenderSurfaces?

    init(frame: CGRect, layer: IINKLayerType) {
        self.layerType = layer
        super.init(frame: frame)

        // Keeps the view transparent so layers can stack.
        isOpaque = false
        backgroundColor = .clear

        // Redraws on invalidation.
        contentMode = .redraw
    }

    required init?(coder: NSCoder) {
        return nil
    }

    override func draw(_ rect: CGRect) {
        print("🎨 RenderView.draw: layerType=\(layerType), rect=(\(rect.origin.x), \(rect.origin.y), \(rect.width), \(rect.height))")
        // Skips drawing if the renderer is not ready.
        guard let ctx = UIGraphicsGetCurrentContext() else {
            print("❌ RenderView.draw: No graphics context")
            return
        }
        guard let renderer else {
            print("❌ RenderView.draw: No renderer available")
            return
        }

        print("✅ RenderView.draw: Context and renderer available")

        // Creates a canvas that wraps the current Core Graphics context.
        let canvas = Canvas()
        canvas.context = ctx
        canvas.size = bounds.size
        canvas.offscreenRenderSurfaces = offscreenRenderSurfaces

        print("🎨 RenderView.draw: Canvas created, size=(\(canvas.size.width), \(canvas.size.height))")

        // Converts the UIKit redraw rect from points to pixels.
        let scale = contentScaleFactor
        let regionPx = CGRect(
            x: rect.origin.x * scale,
            y: rect.origin.y * scale,
            width: rect.size.width * scale,
            height: rect.size.height * scale
        )

        print("🎨 RenderView.draw: Drawing region (px)=(\(regionPx.origin.x), \(regionPx.origin.y), \(regionPx.width), \(regionPx.height)), scale=\(scale)")

        // Draws the selected renderer layer for the invalidated region.
        if layerType == .model {
            print("🎨 RenderView.draw: Calling drawModel")
            let result = renderer.drawModel(regionPx, canvas: canvas)
            print("🎨 RenderView.draw: drawModel result=\(result)")
        } else if layerType == .capture {
            print("🎨 RenderView.draw: Calling drawCaptureStrokes")
            let result = renderer.drawCaptureStrokes(regionPx, canvas: canvas)
            print("🎨 RenderView.draw: drawCaptureStrokes result=\(result)")
        } else {
            print("⚠️ RenderView.draw: Unknown layer type")
        }
    }

    func setNeedsDisplay(areaPx: CGRect) {
        print("🔄 RenderView.setNeedsDisplay(areaPx): layerType=\(layerType), area=(\(areaPx.origin.x), \(areaPx.origin.y), \(areaPx.width), \(areaPx.height))")
        // Converts pixel rectangles back to points for UIKit invalidation.
        let scale = contentScaleFactor
        let areaPt = CGRect(
            x: areaPx.origin.x / scale,
            y: areaPx.origin.y / scale,
            width: areaPx.size.width / scale,
            height: areaPx.size.height / scale
        )
        print("🔄 RenderView: Converting to points: area=(\(areaPt.origin.x), \(areaPt.origin.y), \(areaPt.width), \(areaPt.height))")
        setNeedsDisplay(areaPt)
    }
}
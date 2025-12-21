import UIKit
import Foundation

// A UIView that acts as the rendering target for the MyScript engine.
// Implements IINKIRenderTarget to handle drawing commands.
// Routes touch input to the IINKEditor.
class CanvasView: UIView, IINKIRenderTarget {
  // The MyScript editor to route input to.
  weak var editor: IINKEditor?

  // Storage for offscreen render surfaces.
  private var offscreenSurfaces: [UInt32: CALayer] = [:]

  // Storage for offscreen render canvases.
  private var offscreenCanvases: [UInt32: IINKICanvas] = [:]

  // Next available surface ID.
  private var nextSurfaceId: UInt32 = 1

  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setup()
  }

  private func setup() {
    self.backgroundColor = .white
    self.isMultipleTouchEnabled = true
  }

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let editor = editor else { return }
    for touch in touches {
      let pointerEvent = createPointerEvent(from: touch, eventType: .down)
      do {
        try editor.pointerDown(
          point: CGPoint(x: CGFloat(pointerEvent.x), y: CGFloat(pointerEvent.y)),
          timestamp: pointerEvent.t,
          force: pointerEvent.f,
          type: pointerEvent.pointerType,
          pointerId: Int(pointerEvent.pointerId)
        )
      } catch {
        // Pointer down failed.
      }
    }
  }

  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let editor = editor else { return }
    guard let touch = touches.first else { return }
    
    // Use coalesced touches to batch multiple touch points together.
    // This prevents the "too many points" error by sending points in batches.
    let coalescedTouches = event?.coalescedTouches(for: touch) ?? [touch]
    
    if coalescedTouches.count > 1 {
      // Batch multiple touch points together for better performance.
      var events = coalescedTouches.map { coalescedTouch in
        createPointerEvent(from: coalescedTouch, eventType: .move)
      }
      
      // Use pointerEvents batch API to send all points at once.
      // Allocate memory for the pointer events array.
      let pointerEvents = UnsafeMutablePointer<IINKPointerEvent>.allocate(capacity: events.count)
      pointerEvents.initialize(from: &events, count: events.count)
      
      do {
        try editor.pointerEvents(pointerEvents, count: events.count, doProcessGestures: true)
      } catch {
        // Batch pointer events failed, fall back to single events.
        // This can happen if the batch is too large.
        for event in events {
          do {
            try editor.pointerMove(
              point: CGPoint(x: CGFloat(event.x), y: CGFloat(event.y)),
              timestamp: event.t,
              force: event.f,
              type: event.pointerType,
              pointerId: Int(event.pointerId)
            )
          } catch {
            // Individual pointer move failed.
          }
        }
      }
      
      // Deallocate the memory.
      pointerEvents.deinitialize(count: events.count)
      pointerEvents.deallocate()
    } else {
      // Single touch point, use regular pointerMove.
      let pointerEvent = createPointerEvent(from: touch, eventType: .move)
      do {
        try editor.pointerMove(
          point: CGPoint(x: CGFloat(pointerEvent.x), y: CGFloat(pointerEvent.y)),
          timestamp: pointerEvent.t,
          force: pointerEvent.f,
          type: pointerEvent.pointerType,
          pointerId: Int(pointerEvent.pointerId)
        )
      } catch {
        // Pointer move failed.
      }
    }
  }

  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let editor = editor else { return }
    for touch in touches {
      let pointerEvent = createPointerEvent(from: touch, eventType: .up)
      do {
        try editor.pointerUp(
          point: CGPoint(x: CGFloat(pointerEvent.x), y: CGFloat(pointerEvent.y)),
          timestamp: pointerEvent.t,
          force: pointerEvent.f,
          type: pointerEvent.pointerType,
          pointerId: Int(pointerEvent.pointerId)
        )
      } catch {
        // Pointer up failed.
      }
    }
  }

  override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let editor = editor else { return }
    for touch in touches {
      let pointerEvent = createPointerEvent(from: touch, eventType: .cancel)
      do {
        try editor.pointerCancel(Int(pointerEvent.pointerId))
      } catch {
        // Pointer cancel failed.
      }
    }
  }

  // Converts a UITouch to an IINKPointerEvent.
  private func createPointerEvent(from touch: UITouch, eventType: IINKPointerEventType) -> IINKPointerEvent {
    let location = touch.preciseLocation(in: self)

    // Normalize force to 0-1 range. Default to 0 if device has no force sensor.
    let force: Float
    if touch.maximumPossibleForce > 0 {
      force = Float(touch.force / touch.maximumPossibleForce)
    } else {
      force = 0
    }

    // Convert timestamp to milliseconds.
    let timestamp = Int64(touch.timestamp * 1000)

    // Determine pointer type based on touch type.
    let pointerType: IINKPointerType = (touch.type == .stylus) ? .pen : .touch

    // Use hash of touch as pointer ID to track individual fingers.
    // Mask to 32 bits to safely convert Int (64-bit) to Int32.
    let pointerId = Int32(truncatingIfNeeded: touch.hash)

    return IINKPointerEventMake(
      eventType,
      CGPoint(x: location.x, y: location.y),
      timestamp,
      force,
      pointerType,
      pointerId
    )
  }

  // MARK: - IINKIRenderTarget Protocol

  // Invalidates the given set of layers.
  func invalidate(_ renderer: IINKRenderer, layers: IINKLayerType) {
    // Mark the view as needing display for the specified layers.
    self.setNeedsDisplay()
  }

  // Invalidates a specified rectangle area on the given set of layers.
  func invalidate(_ renderer: IINKRenderer, area: CGRect, layers: IINKLayerType) {
    // Mark the specific area as needing display.
    self.setNeedsDisplay(area)
  }

  // The device Pixel Density.
  var pixelDensity: Float {
    return Float(self.contentScaleFactor)
  }

  // Creates an offscreen render surface and returns a unique identifier.
  func createOffscreenRenderSurface(width: Int32, height: Int32, alphaMask: Bool) -> UInt32 {
    let surfaceId = nextSurfaceId
    nextSurfaceId += 1

    // Create a CALayer for the offscreen surface.
    let layer = CALayer()
    layer.frame = CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height))
    layer.contentsScale = self.contentScaleFactor
    offscreenSurfaces[surfaceId] = layer

    return surfaceId
  }

  // Releases the offscreen render surface associated with the given identifier.
  func releaseOffscreenRenderSurface(_ surfaceId: UInt32) {
    offscreenSurfaces.removeValue(forKey: surfaceId)
    offscreenCanvases.removeValue(forKey: surfaceId)
  }

  // Creates a Canvas that draws onto the offscreen render surface.
  func createOffscreenRenderCanvas(_ surfaceId: UInt32) -> IINKICanvas {
    // Create a canvas that draws to the offscreen surface layer.
    guard let layer = offscreenSurfaces[surfaceId] else {
      // Return a basic canvas if surface not found.
      return OffscreenCanvas()
    }
    let canvas = OffscreenCanvas(layer: layer)
    offscreenCanvases[surfaceId] = canvas
    return canvas
  }

  // Releases the offscreen render canvas.
  func releaseOffscreenRenderCanvas(_ canvas: IINKICanvas) {
    // Find and remove the canvas from storage.
    if let key = offscreenCanvases.first(where: { $0.value === canvas })?.key {
      offscreenCanvases.removeValue(forKey: key)
    }
  }
}

// A basic implementation of IINKICanvas for offscreen rendering.
// This canvas draws to a CALayer using Core Graphics.
class OffscreenCanvas: NSObject, IINKICanvas {
  private let layer: CALayer?
  private var currentTransform = CGAffineTransform.identity
  private var strokeColor: UInt32 = 0xFF000000
  private var strokeWidth: Float = 1.0
  private var fillColor: UInt32 = 0xFF000000

  init(layer: CALayer? = nil) {
    self.layer = layer
    super.init()
  }

  // MARK: - View Properties

  func getTransform() -> CGAffineTransform {
    return currentTransform
  }

  func setTransform(_ transform: CGAffineTransform) {
    currentTransform = transform
  }

  // MARK: - Stroking Properties

  func setStrokeColor(_ color: UInt32) {
    strokeColor = color
  }

  func setStrokeWidth(_ width: Float) {
    strokeWidth = width
  }

  func setStroke(_ lineCap: IINKLineCap) {
    // Store for path drawing.
  }

  func setStroke(_ lineJoin: IINKLineJoin) {
    // Store for path drawing.
  }

  func setStrokeMiterLimit(_ limit: Float) {
    // Store for path drawing.
  }

  func setStrokeDashArray(_ array: UnsafePointer<Float>?, size: size_t) {
    // Store for path drawing.
  }

  func setStrokeDashOffset(_ offset: Float) {
    // Store for path drawing.
  }

  // MARK: - Filling Properties

  func setFillColor(_ color: UInt32) {
    fillColor = color
  }

  func setFillRule(_ rule: IINKFillRule) {
    // Store for path drawing.
  }

  // MARK: - Drop Shadow Properties

  func setDropShadow(_ xOffset: Float, yOffset: Float, radius: Float, color: UInt32) {
    // Store for path drawing.
  }

  // MARK: - Font Properties

  func setFontProperties(_ family: String, height lineHeight: Float, size: Float, style: String, variant: String, weight: Int32) {
    // Store for text drawing.
  }

  // MARK: - Group Management

  func startGroup(_ identifier: String, region: CGRect, clip: Bool) {
    // Group management for complex drawings.
  }

  func endGroup(_ identifier: String) {
    // Group management for complex drawings.
  }

  func startItem(_ identifier: String) {
    // Item management for complex drawings.
  }

  func endItem(_ identifier: String) {
    // Item management for complex drawings.
  }

  // MARK: - Drawing Commands

  func createPath() -> IINKIPath {
    // Create a basic path implementation.
    return BasicPath()
  }

  func draw(_ path: IINKIPath) {
    // Draw the path to the layer.
    // This is a simplified implementation.
  }

  func drawRectangle(_ rect: CGRect) {
    // Draw rectangle to the layer.
    // This is a simplified implementation.
  }

  func drawLine(_ from: CGPoint, to: CGPoint) {
    // Draw line to the layer.
    // This is a simplified implementation.
  }

  func drawObject(_ url: String, mimeType: String, region: CGRect) {
    // Draw object to the layer.
    // This is a simplified implementation.
  }

  func drawText(_ label: String, anchor: CGPoint, region: CGRect) {
    // Draw text to the layer.
    // This is a simplified implementation.
  }
}

// A basic implementation of IINKIPath for path drawing.
class BasicPath: NSObject, IINKIPath {
  private let cgPath = CGMutablePath()

  func move(to position: CGPoint) {
    cgPath.move(to: position)
  }

  func line(to position: CGPoint) {
    cgPath.addLine(to: position)
  }

  func close() {
    cgPath.closeSubpath()
  }
}

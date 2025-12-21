import UIKit
import Foundation
import Combine

// UIKit controller that manages the IINKRenderer and the custom RenderView.
class EditorViewController: UIViewController {

  let editorWorker: EditorWorker
  private let engine: IINKEngine?
  private var renderer: IINKRenderer?
  
  // Use the custom RenderView for high-performance rendering.
  private var renderView: RenderView?

  init(editorWorker: EditorWorker) {
    self.editorWorker = editorWorker
    self.engine = EngineProvider.shared.engine
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    // Initialize the custom RenderView.
    let canvas = RenderView(frame: self.view.bounds)
    canvas.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    self.view.addSubview(canvas)
    self.renderView = canvas

    setupMyScript()
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    if let editor = editorWorker.editor {
      let size = self.view.bounds.size
      if size.width > 0 && size.height > 0 {
        do {
          // Inform the editor of size changes for coordinate calibration.
          try editor.set(viewSize: size)
        } catch {
          // Setting view size failed.
        }
      }
    }
  }

  private func setupMyScript() {
    guard let engine = self.engine, let canvas = self.renderView else {
      return
    }

    // CORRECTED: Use nativeScale to calculate physical DPI (iPad Pro is ~264 DPI).
    // This ensures ink appears exactly under the Apple Pencil tip.
    // Use trait collection scale if available, otherwise fall back to screen scale.
    // In viewDidLoad, the window might not be set yet, so we use the trait collection.
    let scale: CGFloat
    if let windowScene = self.view.window?.windowScene {
      scale = windowScene.screen.nativeScale
    } else if #available(iOS 13.0, *) {
      // Use trait collection scale as fallback (iOS 26.0+ recommendation)
      scale = self.view.traitCollection.displayScale
    } else {
      // Final fallback for older iOS versions
      scale = UIScreen.main.nativeScale
    }
    let physicalDPI = Float(scale * 132) 

    if let renderer = try? engine.createRenderer(dpiX: physicalDPI, dpiY: physicalDPI, target: canvas) {
      self.renderer = renderer
      canvas.renderer = renderer
      editorWorker.attach(engine: engine, renderer: renderer)
      
      // Pass the editor reference to the RenderView for input handling.
      // The editor will be set asynchronously by attach(), so we need to wait for it.
      DispatchQueue.main.async { [weak self] in
        guard let self = self else { return }
        canvas.editor = self.editorWorker.editor
      }
    }
  }
}
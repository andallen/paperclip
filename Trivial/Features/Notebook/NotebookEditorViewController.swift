import UIKit

// Owns the MyScript editor, renderer, display, and input plumbing.
final class NotebookEditorViewController: UIViewController {
    // Identifies which notebook package should be opened.
    private let documentHandle: DocumentHandle

    // Owns the engine and shared providers needed by the editor.
    private var engineProvider: EngineProvider?

    // Receives invalidation callbacks and routes them into the render views.
    private let displayViewModel = DisplayViewModel()

    // Installs the render views.
    private let displayVC: DisplayViewController

    // Converts touches into pointer events for the editor.
    private let inputViewOverlay = InputView(frame: .zero)

    // Tracks whether the package and part have been loaded.
    private var didLoadDocument = false

    init(documentHandle: DocumentHandle) {
        self.documentHandle = documentHandle
        self.displayVC = DisplayViewController(viewModel: displayViewModel)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        return nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Sets a clean background for the writing surface.
        view.backgroundColor = .systemBackground

        // Installs the display controller so rendering can start early.
        addChild(displayVC)
        view.addSubview(displayVC.view)
        displayVC.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            displayVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            displayVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            displayVC.view.topAnchor.constraint(equalTo: view.topAnchor),
            displayVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        displayVC.didMove(toParent: self)

        // Installs the input overlay on top of the render views.
        view.addSubview(inputViewOverlay)
        inputViewOverlay.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            inputViewOverlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            inputViewOverlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            inputViewOverlay.topAnchor.constraint(equalTo: view.topAnchor),
            inputViewOverlay.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        // Builds the engine, editor, renderer, and tool controller.
        setupMyScript()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Sets the editor view size in pixels.
        // Treats invalidation rectangles as pixel rectangles.
        let scale = view.contentScaleFactor
        let sizePx = CGSize(width: view.bounds.width * scale, height: view.bounds.height * scale)
        print("📐 NotebookEditorViewController.viewDidLayoutSubviews: size=(\(sizePx.width), \(sizePx.height)), scale=\(scale)")
        do {
            try displayViewModel.editor?.set(viewSize: sizePx)
            print("✅ NotebookEditorViewController: View size set successfully")
        } catch {
            print("❌ NotebookEditorViewController: Failed to set view size: \(error)")
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Loads the package and part once when the screen becomes visible.
        guard !didLoadDocument else { return }
        didLoadDocument = true
        loadDocument()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // Attempts to persist the package on exit.
        // Ignores errors here to keep navigation responsive.
        Task {
            do {
                try await documentHandle.savePackage()
            } catch {
                // Ignore save errors during navigation.
            }
        }
    }

    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
        // Defers all system edge gestures to the app so touch events are delivered immediately.
        // This prevents iOS from holding touches at the gesture gate, which causes invisible ink
        // when the initial touchesBegan events arrive too late for stroke construction.
        return .all
    }

    private func setupMyScript() {
        print("🔧 NotebookEditorViewController.setupMyScript: Starting")
        Task {
            do {
                // Creates or reuses a shared engine instance.
                let provider = EngineProvider.shared
                if provider.engine == nil {
                    print("🔧 NotebookEditorViewController: Initializing engine")
                    try await provider.initializeEngine()
                } else {
                    print("🔧 NotebookEditorViewController: Using existing engine")
                }
                engineProvider = provider

                guard let engine = provider.engine else {
                    print("❌ NotebookEditorViewController: Engine is nil after initialization")
                    return
                }
                print("✅ NotebookEditorViewController: Engine available")

                // Creates a renderer bound to the display view model render target.
                let dpi = Helper.scaledDpi()
                print("🔧 NotebookEditorViewController: Creating renderer with DPI=\(dpi)")
                let renderer = try engine.createRenderer(dpiX: dpi, dpiY: dpi, target: displayViewModel)
                displayViewModel.renderer = renderer
                print("✅ NotebookEditorViewController: Renderer created")

                // Creates a tool controller for gesture and tool behavior.
                // Must be created before the editor.
                let toolController = engine.createToolController()
                inputViewOverlay.toolController = toolController
                print("✅ NotebookEditorViewController: Tool controller created")

                // Creates an editor linked to the renderer and tool controller.
                guard let editor = engine.createEditor(renderer: renderer, toolController: toolController) else {
                    print("❌ NotebookEditorViewController: Failed to create editor")
                    return
                }
                displayViewModel.editor = editor
                print("✅ NotebookEditorViewController: Editor created")
                print("📐 NotebookEditorViewController: Editor viewSize=(\(editor.viewSize.width), \(editor.viewSize.height))")
                print("📄 NotebookEditorViewController: Editor part=\(editor.part != nil ? "YES" : "NO")")
                if let part = editor.part {
                    print("📄 NotebookEditorViewController: Editor part type=\(part.type)")
                }

                // Creates a font metrics provider for text layout.
                let fontProvider = FontMetricsProvider()
                editor.set(fontMetricsProvider: fontProvider)
                print("✅ NotebookEditorViewController: Font metrics provider set")

                // Connects touch input to the editor.
                inputViewOverlay.editor = editor
                print("✅ NotebookEditorViewController: Editor connected to input view")

                // Forces an initial redraw after wiring core objects.
                displayViewModel.refreshDisplay()
                print("✅ NotebookEditorViewController: Initial display refresh called")
            } catch {
                print("❌ NotebookEditorViewController.setupMyScript failed: \(error)")
            }
        }
    }

    private func loadDocument() {
        print("📄 NotebookEditorViewController.loadDocument: Starting")
        guard let editor = displayViewModel.editor else {
            print("❌ NotebookEditorViewController.loadDocument: No editor available")
            return
        }

        Task {
            do {
                // Gets the package from the document handle.
                guard let package = await documentHandle.getPackage() else {
                    print("❌ NotebookEditorViewController.loadDocument: No package available")
                    return
                }
                print("✅ NotebookEditorViewController.loadDocument: Package loaded")

                // Gets the first part or creates one if the package is empty.
                let partCount = await documentHandle.getPartCount()
                print("📄 NotebookEditorViewController.loadDocument: Part count=\(partCount)")
                let part: IINKContentPart?
                if partCount > 0 {
                    part = await documentHandle.getPart(at: 0)
                    print("✅ NotebookEditorViewController.loadDocument: Loaded existing part")
                } else {
                    // Creates a new text part if the package is empty.
                    part = try package.createPart(with: "Text Document")
                    print("✅ NotebookEditorViewController.loadDocument: Created new part")
                }

                // Connects the editor to the loaded part.
                await MainActor.run {
                    print("📄 NotebookEditorViewController: Setting editor.part, current part=\(editor.part != nil ? "YES" : "NO"), new part=\(part != nil ? "YES" : "NO")")
                    if let part = part {
                        print("📄 NotebookEditorViewController: Part type=\(part.type), partCount=\(part.package.partCount())")
                    }
                    editor.part = part
                    print("✅ NotebookEditorViewController.loadDocument: Part assigned to editor, part=\(editor.part != nil ? "YES" : "NO")")
                    if let currentPart = editor.part {
                        print("📄 NotebookEditorViewController: Current part type=\(currentPart.type)")
                    }
                    // Requests a full redraw after part assignment.
                    displayViewModel.refreshDisplay()
                }
            } catch {
                print("❌ NotebookEditorViewController.loadDocument failed: \(error)")
            }
        }
    }
}
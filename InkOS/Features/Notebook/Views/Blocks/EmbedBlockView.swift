//
// EmbedBlockView.swift
// InkOS
//
// SwiftUI view for rendering EmbedContent blocks via WKWebView.
// Supports PhET, Desmos, YouTube, CircuitJS, and generic URL embeds.
//

import SwiftUI
import WebKit

// MARK: - EmbedBlockView

// SwiftUI wrapper for embed content rendering via WebView.
struct EmbedBlockView: View {
  let content: EmbedContent

  @State private var isLoading = true
  @State private var loadError: String?
  @State private var isFullscreen = false

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      ZStack {
        // WebView content.
        EmbedWebView(
          content: content,
          isLoading: $isLoading,
          loadError: $loadError
        )
        .frame(height: calculatedHeight)
        .clipShape(RoundedRectangle(cornerRadius: 8))

        // Loading overlay.
        if isLoading {
          loadingOverlay
        }

        // Error overlay.
        if let error = loadError {
          errorOverlay(error)
        }

        // Fullscreen button.
        if content.allowFullscreen && !isLoading && loadError == nil {
          fullscreenButton
        }
      }
      .frame(height: calculatedHeight)

      // Caption.
      if let caption = content.caption {
        Text(caption)
          .font(.caption)
          .foregroundColor(.secondary)
          .padding(.horizontal, 8)
      }
    }
    .padding(.vertical, 16)
    .fullScreenCover(isPresented: $isFullscreen) {
      FullscreenEmbedView(content: content, isPresented: $isFullscreen)
    }
  }

  // MARK: - Computed Properties

  private var calculatedHeight: CGFloat {
    if let sizing = content.sizing {
      if let height = sizing.height {
        return height
      }
      if let aspectRatio = sizing.aspectRatio {
        let width = UIScreen.main.bounds.width - 32
        return width / aspectRatio
      }
    }
    // Default 16:9 aspect ratio.
    let width = UIScreen.main.bounds.width - 32
    return width / (16.0 / 9.0)
  }

  // MARK: - Subviews

  private var loadingOverlay: some View {
    RoundedRectangle(cornerRadius: 8)
      .fill(Color(.systemGray6))
      .overlay {
        VStack(spacing: 12) {
          ProgressView()
            .scaleEffect(1.2)
          Text("Loading \(content.provider.displayName)...")
            .font(.caption)
            .foregroundColor(.secondary)
        }
      }
  }

  private func errorOverlay(_ message: String) -> some View {
    RoundedRectangle(cornerRadius: 8)
      .fill(Color(.systemGray6))
      .overlay {
        VStack(spacing: 12) {
          Image(systemName: "exclamationmark.triangle")
            .font(.largeTitle)
            .foregroundColor(.orange)
          Text("Failed to load")
            .font(.headline)
          Text(message)
            .font(.caption)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal)
        }
      }
  }

  private var fullscreenButton: some View {
    VStack {
      HStack {
        Spacer()
        Button {
          isFullscreen = true
        } label: {
          Image(systemName: "arrow.up.left.and.arrow.down.right")
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(.white)
            .padding(8)
            .background(Color.black.opacity(0.5))
            .clipShape(Circle())
        }
        .padding(8)
      }
      Spacer()
    }
  }
}

// MARK: - EmbedWebView

// UIViewRepresentable wrapper for WKWebView.
struct EmbedWebView: UIViewRepresentable {
  let content: EmbedContent
  @Binding var isLoading: Bool
  @Binding var loadError: String?

  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }

  func makeUIView(context: Context) -> WKWebView {
    let config = WKWebViewConfiguration()

    // Allow inline media playback (important for YouTube).
    config.allowsInlineMediaPlayback = true
    config.mediaTypesRequiringUserActionForPlayback = []

    // Allow JavaScript.
    config.defaultWebpagePreferences.allowsContentJavaScript = true

    let webView = WKWebView(frame: .zero, configuration: config)
    webView.navigationDelegate = context.coordinator
    webView.allowsBackForwardNavigationGestures = false
    webView.scrollView.isScrollEnabled = true
    webView.scrollView.bounces = false
    webView.isOpaque = false
    webView.backgroundColor = .clear
    webView.scrollView.backgroundColor = .clear

    return webView
  }

  func updateUIView(_ webView: WKWebView, context: Context) {
    // Only load if URL changed or first load.
    guard context.coordinator.currentURL != embedURL else { return }
    context.coordinator.currentURL = embedURL

    if let url = embedURL {
      let request = URLRequest(url: url)
      webView.load(request)
    } else if let html = embedHTML {
      webView.loadHTMLString(html, baseURL: nil)
    } else {
      DispatchQueue.main.async {
        loadError = "Invalid embed configuration"
        isLoading = false
      }
    }
  }

  // MARK: - URL Generation

  private var embedURL: URL? {
    switch content.config {
    case .phet(let config):
      return phetURL(config)
    case .youtube(let config):
      return youtubeURL(config)
    case .desmos(let config):
      return desmosURL(config)
    case .circuitjs(let config):
      return circuitjsURL(config)
    case .url(let config):
      return URL(string: config.src)
    }
  }

  private var embedHTML: String? {
    // For providers that need custom HTML (like Desmos with expressions).
    switch content.config {
    case .desmos(let config):
      if config.expressions != nil {
        return desmosHTML(config)
      }
      return nil
    default:
      return nil
    }
  }

  private func phetURL(_ config: PhETConfig) -> URL? {
    // PhET simulations are hosted at phet.colorado.edu.
    // Format: https://phet.colorado.edu/sims/html/{simulation-id}/latest/{simulation-id}_{locale}.html
    let baseURL = "https://phet.colorado.edu/sims/html/\(config.simulationId)/latest/\(config.simulationId)_\(config.locale).html"
    return URL(string: baseURL)
  }

  private func youtubeURL(_ config: YouTubeConfig) -> URL? {
    // YouTube embed URL with parameters.
    var components = URLComponents(string: "https://www.youtube.com/embed/\(config.videoId)")
    var queryItems: [URLQueryItem] = []

    // Enable JS API for potential future interactions.
    queryItems.append(URLQueryItem(name: "enablejsapi", value: "1"))

    // Playback options.
    queryItems.append(URLQueryItem(name: "playsinline", value: "1"))
    queryItems.append(URLQueryItem(name: "rel", value: "0"))
    queryItems.append(URLQueryItem(name: "modestbranding", value: "1"))

    if config.autoplay {
      queryItems.append(URLQueryItem(name: "autoplay", value: "1"))
    }

    if !config.controls {
      queryItems.append(URLQueryItem(name: "controls", value: "0"))
    }

    if let start = config.startTime {
      queryItems.append(URLQueryItem(name: "start", value: String(start)))
    }

    if let end = config.endTime {
      queryItems.append(URLQueryItem(name: "end", value: String(end)))
    }

    components?.queryItems = queryItems
    return components?.url
  }

  private func desmosURL(_ config: DesmosConfig) -> URL? {
    // Desmos calculator URL based on type.
    let calculatorPath: String
    switch config.calculatorType {
    case .graphing:
      calculatorPath = "calculator"
    case .scientific:
      calculatorPath = "scientific"
    case .fourfunction:
      calculatorPath = "fourfunction"
    case .geometry:
      calculatorPath = "geometry"
    }
    return URL(string: "https://www.desmos.com/\(calculatorPath)")
  }

  private func desmosHTML(_ config: DesmosConfig) -> String {
    // Generate HTML that uses Desmos API to set up expressions.
    let expressionsJSON: String
    if let expressions = config.expressions {
      let encoder = JSONEncoder()
      if let data = try? encoder.encode(expressions),
         let json = String(data: data, encoding: .utf8) {
        expressionsJSON = json
      } else {
        expressionsJSON = "[]"
      }
    } else {
      expressionsJSON = "[]"
    }

    let settingsScript: String
    if let settings = config.settings {
      var settingsCode = ""
      if let showGrid = settings.showGrid {
        settingsCode += "calculator.updateSettings({ showGrid: \(showGrid) });\n"
      }
      if let xRange = settings.xRange, xRange.count == 2,
         let yRange = settings.yRange, yRange.count == 2 {
        settingsCode += "calculator.setMathBounds({ left: \(xRange[0]), right: \(xRange[1]), bottom: \(yRange[0]), top: \(yRange[1]) });\n"
      }
      settingsScript = settingsCode
    } else {
      settingsScript = ""
    }

    return """
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
      <script src="https://www.desmos.com/api/v1.8/calculator.js?apiKey=dcb31709b452b1cf9dc26972add0fda6"></script>
      <style>
        * { margin: 0; padding: 0; }
        html, body { width: 100%; height: 100%; }
        #calculator { width: 100%; height: 100%; }
      </style>
    </head>
    <body>
      <div id="calculator"></div>
      <script>
        var elt = document.getElementById('calculator');
        var calculator = Desmos.GraphingCalculator(elt, {
          expressions: true,
          settingsMenu: false,
          zoomButtons: true,
          lockViewport: false
        });

        var expressions = \(expressionsJSON);
        expressions.forEach(function(expr) {
          calculator.setExpression({
            id: expr.id || Math.random().toString(36),
            latex: expr.latex,
            color: expr.color || Desmos.Colors.BLUE,
            hidden: expr.hidden || false
          });
        });

        \(settingsScript)
      </script>
    </body>
    </html>
    """
  }

  private func circuitjsURL(_ config: CircuitJSConfig) -> URL? {
    // CircuitJS hosted URL.
    var components = URLComponents(string: "https://www.falstad.com/circuit/circuitjs.html")
    var queryItems: [URLQueryItem] = []

    if let circuitData = config.circuitData {
      // Circuit data is passed as a URL-encoded string.
      queryItems.append(URLQueryItem(name: "ctz", value: circuitData))
    }

    if !config.running {
      queryItems.append(URLQueryItem(name: "running", value: "false"))
    }

    if !queryItems.isEmpty {
      components?.queryItems = queryItems
    }

    return components?.url
  }

  // MARK: - Coordinator

  class Coordinator: NSObject, WKNavigationDelegate {
    var parent: EmbedWebView
    var currentURL: URL?

    init(_ parent: EmbedWebView) {
      self.parent = parent
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
      DispatchQueue.main.async {
        self.parent.isLoading = true
        self.parent.loadError = nil
      }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
      DispatchQueue.main.async {
        self.parent.isLoading = false
      }
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
      DispatchQueue.main.async {
        self.parent.isLoading = false
        self.parent.loadError = error.localizedDescription
      }
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
      DispatchQueue.main.async {
        self.parent.isLoading = false
        self.parent.loadError = error.localizedDescription
      }
    }

    // Handle navigation to external links.
    func webView(
      _ webView: WKWebView,
      decidePolicyFor navigationAction: WKNavigationAction,
      decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
      // Allow the initial load and same-origin navigation.
      if navigationAction.navigationType == .other ||
         navigationAction.navigationType == .reload {
        decisionHandler(.allow)
        return
      }

      // For link clicks, check if it's the same domain.
      if let url = navigationAction.request.url,
         let currentHost = currentURL?.host,
         url.host == currentHost {
        decisionHandler(.allow)
      } else {
        // Open external links in Safari.
        if let url = navigationAction.request.url {
          UIApplication.shared.open(url)
        }
        decisionHandler(.cancel)
      }
    }
  }
}

// MARK: - FullscreenEmbedView

// Fullscreen presentation of embed content.
struct FullscreenEmbedView: View {
  let content: EmbedContent
  @Binding var isPresented: Bool

  @State private var isLoading = true
  @State private var loadError: String?

  var body: some View {
    ZStack {
      Color.black.ignoresSafeArea()

      EmbedWebView(
        content: content,
        isLoading: $isLoading,
        loadError: $loadError
      )
      .ignoresSafeArea()

      // Close button.
      VStack {
        HStack {
          Spacer()
          Button {
            isPresented = false
          } label: {
            Image(systemName: "xmark")
              .font(.system(size: 16, weight: .bold))
              .foregroundColor(.white)
              .padding(12)
              .background(Color.black.opacity(0.6))
              .clipShape(Circle())
          }
          .padding()
        }
        Spacer()
      }

      // Loading indicator.
      if isLoading {
        ProgressView()
          .scaleEffect(1.5)
          .tint(.white)
      }
    }
  }
}

// MARK: - EmbedProvider Extension

extension EmbedProvider {
  var displayName: String {
    switch self {
    case .phet: return "PhET Simulation"
    case .circuitjs: return "Circuit"
    case .desmos: return "Desmos"
    case .youtube: return "YouTube"
    case .url: return "Content"
    }
  }
}

// MARK: - Preview

#if DEBUG
struct EmbedBlockView_Previews: PreviewProvider {
  static var previews: some View {
    ScrollView {
      VStack(spacing: 24) {
        // YouTube embed.
        EmbedBlockView(content: .youtube(
          videoId: "dQw4w9WgXcQ",
          startTime: 0
        ))

        // Desmos with expressions.
        EmbedBlockView(content: .desmos(
          expressions: [
            DesmosExpression(latex: "y=x^2", color: "#2196F3"),
            DesmosExpression(latex: "y=\\sin(x)", color: "#4CAF50"),
          ]
        ))

        // PhET simulation.
        EmbedBlockView(content: .phet(
          simulationId: "projectile-motion",
          locale: "en"
        ))
      }
      .padding()
    }
  }
}
#endif

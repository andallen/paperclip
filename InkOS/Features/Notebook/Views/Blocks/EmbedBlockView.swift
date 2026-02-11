//
// EmbedBlockView.swift
// InkOS
//
// SwiftUI view for rendering EmbedContent blocks via WKWebView.
// Loads URLs directly from EmbedContent - no URL construction logic.
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
        .clipShape(RoundedRectangle(cornerRadius: 16))

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

  // Display name for loading indicator.
  private var providerDisplayName: String {
    guard let provider = content.provider else { return "Content" }
    switch provider.lowercased() {
    case "youtube": return "YouTube"
    case "desmos": return "Desmos"
    case "circuitjs": return "Circuit"
    case "phet": return "PhET"
    default: return provider.capitalized
    }
  }

  // MARK: - Subviews

  private var loadingOverlay: some View {
    RoundedRectangle(cornerRadius: 8)
      .fill(Color(.systemGray6))
      .overlay {
        VStack(spacing: 12) {
          ProgressView()
            .scaleEffect(1.2)
          Text("Loading \(providerDisplayName)...")
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
    webView.isOpaque = false
    webView.backgroundColor = .clear
    webView.scrollView.backgroundColor = .clear

    // Gesture isolation strategy depends on provider.
    // PhET uses HTML5 Canvas with custom touch handling that doesn't stop propagation.
    // Disabling scroll entirely for PhET lets its internal gesture handling work.
    let isInteractiveSimulation = content.provider?.lowercased() == "phet" ||
                                   content.provider?.lowercased() == "circuitjs"

    if isInteractiveSimulation {
      // Disable WKWebView scrolling entirely - PhET/CircuitJS handle their own gestures.
      webView.scrollView.isScrollEnabled = false
      webView.scrollView.panGestureRecognizer.isEnabled = false
      webView.scrollView.pinchGestureRecognizer?.isEnabled = false
    } else {
      // Standard embeds (Desmos, YouTube) - normal scroll behavior.
      webView.scrollView.isScrollEnabled = true
      webView.scrollView.bounces = false
      webView.scrollView.delaysContentTouches = false
      webView.scrollView.canCancelContentTouches = false
    }

    return webView
  }

  func updateUIView(_ webView: WKWebView, context: Context) {
    // Parse URL from content.
    guard let url = URL(string: content.url) else {
      DispatchQueue.main.async {
        loadError = "Invalid URL: \(content.url)"
        isLoading = false
      }
      return
    }

    // Only load if URL changed.
    guard context.coordinator.currentURL != url else { return }
    context.coordinator.currentURL = url

    let request = URLRequest(url: url)
    webView.load(request)
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

    func webView(
      _ webView: WKWebView,
      didFailProvisionalNavigation navigation: WKNavigation!,
      withError error: Error
    ) {
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
      if navigationAction.navigationType == .other || navigationAction.navigationType == .reload {
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

// MARK: - Preview

#if DEBUG
  struct EmbedBlockView_Previews: PreviewProvider {
    static var previews: some View {
      ScrollView {
        VStack(spacing: 24) {
          // YouTube embed - uses nocookie domain for privacy-enhanced embedding.
          EmbedBlockView(
            content: EmbedContent.url(
              "https://www.youtube-nocookie.com/embed/CAkMUdeB06o",
              provider: "youtube",
              caption: "YouTube Video"
            ))

          // Desmos calculator.
          EmbedBlockView(
            content: EmbedContent.url(
              "https://www.desmos.com/calculator",
              provider: "desmos",
              caption: "Desmos Graphing Calculator"
            ))
        }
        .padding()
      }
    }
  }
#endif

import UIKit

// MARK: - JIIXPersistenceError

// Errors that can occur during JIIX persistence operations.
enum JIIXPersistenceError: Error, LocalizedError {
  case exportFailed(reason: String)
  case saveFailed(reason: String)
  case loadFailed(reason: String)

  var errorDescription: String? {
    switch self {
    case .exportFailed(let reason):
      return "JIIX export failed: \(reason)"
    case .saveFailed(let reason):
      return "JIIX save failed: \(reason)"
    case .loadFailed(let reason):
      return "JIIX load failed: \(reason)"
    }
  }
}

// MARK: - Notification Names

extension NSNotification.Name {
  // Posted when notebook content is saved successfully.
  static let notebookContentSaved = NSNotification.Name("notebookContentSaved")
}

// MARK: - Editor Export Protocol

// Protocol for exporting JIIX from an editor.
// Implemented by editor view controllers that can export handwriting data.
@MainActor
protocol EditorExportProtocol: AnyObject {
  func exportJIIX() throws -> String
}

// MARK: - JIIX Document Handle Protocol

// Protocol for document file I/O operations.
// Abstracts file system access for JIIX persistence.
protocol JIIXDocumentHandleProtocol: Sendable {
  func saveJIIXData(_ data: Data) async throws
  func loadJIIXData() async throws -> Data
}

// MARK: - PDF Background Renderer Protocol

// Protocol for PDF background rendering.
// Used by the display chain to draw PDF pages behind ink strokes.
protocol PDFBackgroundRendererProtocol: AnyObject {
    // Draw the PDF pages in the given context.
    func draw(in context: CGContext, rect: CGRect, scale: CGFloat)

    // Return which pages are visible in the given viewport rect (in content coordinates).
    // Returns array of (pageIndex, pageFrame) tuples.
    func visiblePages(in viewportRect: CGRect) -> [(Int, CGRect)]

    // Render a specific page at the given scale.
    // Returns nil if the page cannot be rendered.
    func renderPage(at pageIndex: Int, scale: CGFloat) -> CGImage?
}

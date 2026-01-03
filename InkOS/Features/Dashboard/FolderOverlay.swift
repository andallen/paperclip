import SwiftUI
import UIKit

// Displays an expanded folder overlay with notebooks and PDFs inside.
// Uses scale-based animation: renders at full size but scales down to match source position.
// Content is always visible and scales naturally with the container.
struct FolderOverlay: View {
  let folder: FolderMetadata
  let notebooks: [NotebookMetadata]
  let pdfDocuments: [PDFDocumentMetadata]
  // The source card's frame in global coordinates (card portion only, no title).
  let sourceFrame: CGRect
  // Controls scale animation. When true, overlay is at full scale (1.0).
  let isExpanded: Bool
  let onNotebookTap: (NotebookMetadata) -> Void
  let onMoveToRoot: (NotebookMetadata) -> Void
  let onRenameNotebook: (NotebookMetadata, String) -> Void
  let onDeleteNotebook: (NotebookMetadata) -> Void
  let onPDFTap: (PDFDocumentMetadata) -> Void
  let onMovePDFToRoot: (PDFDocumentMetadata) -> Void
  let onRenamePDF: (PDFDocumentMetadata, String) -> Void
  let onDeletePDF: (PDFDocumentMetadata) -> Void
  let onDismiss: () -> Void

  // State for notebook rename alert.
  @State private var renamingNotebook: NotebookMetadata?
  @State private var renameText: String = ""

  // State for notebook delete confirmation alert.
  @State private var deletingNotebook: NotebookMetadata?

  // State for PDF rename alert.
  @State private var renamingPDF: PDFDocumentMetadata?

  // State for PDF delete confirmation alert.
  @State private var deletingPDF: PDFDocumentMetadata?

  // Overlay sizing constants.
  private let overlayWidth: CGFloat = 280
  private let overlayCornerRadius: CGFloat = 24
  private let sourceCornerRadius: CGFloat = 10
  private let contentPadding: CGFloat = 16
  // Header height for animation. Matches padding + text + padding.
  private let headerHeight: CGFloat = 50

  var body: some View {
    GeometryReader { geometry in
      let screenBounds = geometry.frame(in: .global)
      // Calculate the expanded overlay frame (centered on screen).
      let expandedFrame = calculateExpandedFrame(in: screenBounds)

      // Calculate separate X and Y scale factors.
      // This allows the overlay to match the source's exact dimensions when collapsed,
      // then smoothly morph to rectangular shape while expanding.
      let scaleX = isExpanded ? 1.0 : sourceFrame.width / expandedFrame.width
      let scaleY = isExpanded ? 1.0 : sourceFrame.height / expandedFrame.height

      // Position: source center when collapsed, screen center when expanded.
      let positionX = isExpanded ? expandedFrame.midX : sourceFrame.midX
      let positionY = isExpanded ? expandedFrame.midY : sourceFrame.midY

      // Corner radius interpolation for visual effect.
      let currentCornerRadius = isExpanded ? overlayCornerRadius : sourceCornerRadius

      ZStack {
        // Dim background: fades based on expansion state.
        dismissBackground
          .opacity(isExpanded ? 1 : 0)

        // The folder container always rendered at full expanded size.
        // Uses separate X/Y scales to morph from source shape to overlay shape.
        // Fades out as it contracts so it crossfades with the folder card underneath.
        folderContainer(cornerRadius: currentCornerRadius)
          .frame(width: expandedFrame.width, height: expandedFrame.height)
          .clipShape(RoundedRectangle(cornerRadius: currentCornerRadius, style: .continuous))
          .scaleEffect(x: scaleX, y: scaleY)
          .position(x: positionX, y: positionY)
          .shadow(
            color: Color.black.opacity(isExpanded ? 0.2 : 0.14),
            radius: isExpanded ? 16 : 7,
            x: 0,
            y: isExpanded ? 8 : 4
          )
          .opacity(isExpanded ? 1 : 0)
      }
      .frame(width: screenBounds.width, height: screenBounds.height)
    }
    .ignoresSafeArea()
    // Notebook rename alert.
    .alert(
      "Rename Notebook",
      isPresented: Binding(
        get: { renamingNotebook != nil },
        set: { if !$0 { renamingNotebook = nil } }
      )
    ) {
      TextField("Notebook name", text: $renameText)
      Button("Cancel", role: .cancel) {
        renamingNotebook = nil
      }
      Button("Rename") {
        let trimmedName = renameText.trimmingCharacters(in: .whitespaces)
        if let notebook = renamingNotebook, !trimmedName.isEmpty {
          onRenameNotebook(notebook, trimmedName)
        }
        renamingNotebook = nil
      }
    } message: {
      Text("Enter a new name for this notebook.")
    }
    // Notebook delete confirmation alert.
    .alert(
      "Delete Notebook?",
      isPresented: Binding(
        get: { deletingNotebook != nil },
        set: { if !$0 { deletingNotebook = nil } }
      )
    ) {
      Button("Cancel", role: .cancel) {
        deletingNotebook = nil
      }
      Button("Delete", role: .destructive) {
        if let notebook = deletingNotebook {
          onDeleteNotebook(notebook)
        }
        deletingNotebook = nil
      }
    } message: {
      if let notebook = deletingNotebook {
        Text("\"\(notebook.displayName)\" will be permanently deleted. This cannot be undone.")
      }
    }
    // PDF rename alert.
    .alert(
      "Rename PDF",
      isPresented: Binding(
        get: { renamingPDF != nil },
        set: { if !$0 { renamingPDF = nil } }
      )
    ) {
      TextField("PDF name", text: $renameText)
      Button("Cancel", role: .cancel) {
        renamingPDF = nil
      }
      Button("Rename") {
        let trimmedName = renameText.trimmingCharacters(in: .whitespaces)
        if let pdf = renamingPDF, !trimmedName.isEmpty {
          onRenamePDF(pdf, trimmedName)
        }
        renamingPDF = nil
      }
    } message: {
      Text("Enter a new name for this PDF.")
    }
    // PDF delete confirmation alert.
    .alert(
      "Delete PDF?",
      isPresented: Binding(
        get: { deletingPDF != nil },
        set: { if !$0 { deletingPDF = nil } }
      )
    ) {
      Button("Cancel", role: .cancel) {
        deletingPDF = nil
      }
      Button("Delete", role: .destructive) {
        if let pdf = deletingPDF {
          onDeletePDF(pdf)
        }
        deletingPDF = nil
      }
    } message: {
      if let pdf = deletingPDF {
        Text("\"\(pdf.displayName)\" will be permanently deleted. This cannot be undone.")
      }
    }
  }

  // Calculates the expanded overlay frame centered on screen.
  private func calculateExpandedFrame(in screenBounds: CGRect) -> CGRect {
    let gridSpacing: CGFloat = 10
    let cardAspectRatio: CGFloat = 0.72
    let columns = 2

    // Calculate card dimensions matching contentGrid calculations.
    let availableWidth = overlayWidth - contentPadding * 2 - gridSpacing * CGFloat(columns - 1)
    let cardWidth = availableWidth / CGFloat(columns)
    let cardHeight = cardWidth / cardAspectRatio

    // Calculate number of rows based on total items (notebooks + PDFs).
    let totalItems = notebooks.count + pdfDocuments.count
    let rows = max(1, (totalItems + columns - 1) / columns)

    // Calculate total grid height: rows of cards plus spacing between rows.
    let gridHeight = CGFloat(rows) * cardHeight + CGFloat(rows - 1) * gridSpacing

    // Total content height: header + top padding + grid + bottom padding.
    let contentHeight = headerHeight + 8 + gridHeight + contentPadding

    // Minimum height for empty state.
    let minHeight: CGFloat = headerHeight + 160 + contentPadding
    let isEmpty = notebooks.isEmpty && pdfDocuments.isEmpty
    let totalHeight = isEmpty ? minHeight : contentHeight

    return CGRect(
      x: (screenBounds.width - overlayWidth) / 2,
      y: (screenBounds.height - totalHeight) / 2,
      width: overlayWidth,
      height: totalHeight
    )
  }

  // Dim background that dismisses the overlay when tapped.
  private var dismissBackground: some View {
    Color.black.opacity(0.15)
      .contentShape(Rectangle())
      .onTapGesture {
        onDismiss()
      }
  }

  // MARK: - Folder Container

  // The main folder container rendered at full expanded size.
  // Uses scale transform for animation, so layout remains constant throughout.
  // Shows snapshot during scale animation, then crossfades to actual content.
  @ViewBuilder
  private func folderContainer(cornerRadius: CGFloat) -> some View {
    ZStack(alignment: .top) {
      // Glass background.
      glassBackground(cornerRadius: cornerRadius)

      VStack(spacing: 0) {
        // Header with folder name.
        folderHeader

        // Content area containing snapshot (during animation) and content (after).
        contentArea
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
  }

  // Glass background that works with the current corner radius.
  @ViewBuilder
  private func glassBackground(cornerRadius: CGFloat) -> some View {
    if #available(iOS 26.0, *) {
      RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        .fill(Color.clear)
        .glassEffect(.regular.interactive(), in: .rect(cornerRadius: cornerRadius))
    } else {
      RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        .fill(.ultraThinMaterial)
    }
  }

  // MARK: - Folder Content

  // Folder header displayed above the notebook grid.
  // Always visible - scales naturally with the container during animation.
  private var folderHeader: some View {
    Text(folder.displayName)
      .font(.system(size: 18, weight: .semibold))
      .foregroundStyle(Color.ink)
      .lineLimit(1)
      .padding(.horizontal, contentPadding)
      .padding(.top, contentPadding)
      .padding(.bottom, 12)
      .frame(maxWidth: .infinity, alignment: .leading)
      .frame(height: headerHeight, alignment: .top)
  }

  // Content area below the header containing notebooks and PDFs.
  // Always renders content - they scale naturally with the container.
  // No snapshot needed since scale animation doesn't clip content.
  private var contentArea: some View {
    GeometryReader { geo in
      if notebooks.isEmpty && pdfDocuments.isEmpty {
        emptyState
      } else {
        contentGrid(in: geo.size)
      }
    }
  }

  // Empty state when folder has no content.
  private var emptyState: some View {
    VStack(spacing: 12) {
      Image(systemName: "doc.text")
        .font(.system(size: 36, weight: .light))
        .foregroundStyle(Color.inkFaint)

      Text("No items")
        .font(.system(size: 14, weight: .medium))
        .foregroundStyle(Color.inkSubtle)
    }
    .frame(height: 160)
    .frame(maxWidth: .infinity)
    .padding(.bottom, contentPadding)
  }

  // Grid of notebooks and PDFs inside the folder.
  // Calculates explicit card dimensions to prevent compression.
  private func contentGrid(in size: CGSize) -> some View {
    let columns = 2
    let totalItems = notebooks.count + pdfDocuments.count
    let rows = (totalItems + columns - 1) / columns
    let gridSpacing: CGFloat = 10
    let cardAspectRatio: CGFloat = 0.72

    // Calculate card width based on available space minus padding and spacing.
    let availableWidth = size.width - contentPadding * 2 - gridSpacing * CGFloat(columns - 1)
    let cardWidth = availableWidth / CGFloat(columns)
    // Card height from aspect ratio (includes title area).
    let cardHeight = cardWidth / cardAspectRatio

    // Combined items for unified grid layout.
    let allItems: [FolderItem] = notebooks.map { .notebook($0) } + pdfDocuments.map { .pdf($0) }

    return VStack(alignment: .leading, spacing: gridSpacing) {
      ForEach(0..<rows, id: \.self) { row in
        HStack(spacing: gridSpacing) {
          ForEach(0..<columns, id: \.self) { col in
            let index = row * columns + col
            if index < allItems.count {
              folderItemCard(allItems[index], cardWidth: cardWidth, cardHeight: cardHeight)
            } else {
              // Empty spacer for incomplete rows.
              Color.clear
                .frame(width: cardWidth, height: cardHeight)
            }
          }
        }
      }
    }
    .padding(.horizontal, contentPadding)
    .padding(.top, 8)
    .padding(.bottom, contentPadding)
  }

  // Renders a single item card (notebook or PDF) in the folder grid.
  @ViewBuilder
  private func folderItemCard(_ item: FolderItem, cardWidth: CGFloat, cardHeight: CGFloat) -> some View {
    switch item {
    case .notebook(let notebook):
      NotebookCardButton(
        notebook: notebook,
        action: {
          onNotebookTap(notebook)
        },
        onRename: {
          renameText = notebook.displayName
          renamingNotebook = notebook
        },
        onMoveOutOfFolder: {
          onMoveToRoot(notebook)
        },
        onDelete: {
          deletingNotebook = notebook
        }
      )
      .frame(width: cardWidth, height: cardHeight)

    case .pdf(let pdf):
      PDFDocumentCardButton(metadata: pdf) {
        onPDFTap(pdf)
      }
      .contextMenu {
        Button {
          renameText = pdf.displayName
          renamingPDF = pdf
        } label: {
          Label("Rename", systemImage: "pencil")
        }

        Button {
          onMovePDFToRoot(pdf)
        } label: {
          Label("Move Out of Folder", systemImage: "arrow.up.doc")
        }

        Button(role: .destructive) {
          deletingPDF = pdf
        } label: {
          Label("Delete", systemImage: "trash")
        }
      } preview: {
        PDFDocumentCardContextMenuPreview(pdfDocument: pdf)
      }
      .frame(width: cardWidth, height: cardHeight)
    }
  }
}

// Helper enum for unified folder item representation.
private enum FolderItem {
  case notebook(NotebookMetadata)
  case pdf(PDFDocumentMetadata)
}

// MARK: - Glass Overlay Background

// View modifier for the folder overlay glass effect.
extension View {
  func glassOverlayBackground(cornerRadius: CGFloat) -> some View {
    Group {
      if #available(iOS 26.0, *) {
        self
          .background(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
              .fill(Color.clear)
              .glassEffect(.regular.interactive(), in: .rect(cornerRadius: cornerRadius))
          )
      } else {
        // Fallback for older iOS versions.
        self
          .background(
            .ultraThinMaterial,
            in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
          )
      }
    }
  }
}

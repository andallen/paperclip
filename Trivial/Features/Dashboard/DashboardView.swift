import SwiftUI

// The Dashboard is the screen the user sees first.
// It shows a list of Notebooks and provides actions to create, rename, delete, and open Notebooks.
struct DashboardView: View {
  private let columns: [GridItem] = [
    GridItem(.adaptive(minimum: 240, maximum: 360), spacing: 22, alignment: .top)
  ]

  var body: some View {
    ZStack {
      BackgroundWhite()
        .ignoresSafeArea()

      HStack(alignment: .top, spacing: 18) {
        Sidebar()
          .frame(width: 240)

        ScrollView(showsIndicators: false) {
          RightPane(columns: columns)
            .padding(.vertical, 18)
            .padding(.trailing, 22)
            .padding(.leading, 6)
        }
      }
      .padding(.leading, 22)
    }
    .fontDesign(.rounded)
  }
}

// Right pane containing the main content area with the list of Notebooks.
private struct RightPane: View {
  let columns: [GridItem]

  private let notes: [(title: String, subtitle: String, date: String)] = [
    (
      "Linear Algebra — Eigenvectors", "Intuition, geometric meaning, and worked examples…",
      "Dec 18"
    )
  ]

  var body: some View {
    VStack(alignment: .leading, spacing: 18) {
      Text("Notes")
        .font(.system(size: 48, weight: .semibold))
        .foregroundStyle(Color.ink)

      SearchBar()

      Spacer().frame(height: 10)
      Capsule()
        .fill(Color.separator)
        .frame(height: 1)
        .padding(.trailing, 6)
      Spacer().frame(height: 14)

      LazyVGrid(columns: columns, alignment: .leading, spacing: 22) {
        NewNoteCard()

        ForEach(notes, id: \.title) { note in
          NavigationLink(value: note.title) {
            NoteCard(title: note.title, subtitle: note.subtitle, date: note.date)
          }
          .buttonStyle(.plain)
        }
      }
      .navigationDestination(for: String.self) { notebookName in
        NotebookView(notebookName: notebookName)
      }

      Spacer(minLength: 22)
    }
  }
}

// Sidebar component showing navigation options.
private struct Sidebar: View {
  var body: some View {
    VStack(alignment: .leading, spacing: 14) {
      SidebarRow(icon: "tray.full", title: "Notes")

      Spacer(minLength: 0)
    }
    .padding(16)
    .frame(maxHeight: .infinity, alignment: .topLeading)
    .glassBackground(cornerRadius: 18)
  }
}

// Individual row in the sidebar.
private struct SidebarRow: View {
  let icon: String
  let title: String

  var body: some View {
    HStack(spacing: 10) {
      Image(systemName: icon)
        .frame(width: 18)
        .foregroundStyle(Color.inkSubtle)

      Text(title)
        .font(.system(.body))
        .foregroundStyle(Color.ink)

      Spacer()
    }
    .padding(.vertical, 6)
  }
}

// Search bar component.
private struct SearchBar: View {
  var body: some View {
    HStack(spacing: 10) {
      Image(systemName: "magnifyingglass")
        .foregroundStyle(Color.inkSubtle)

      Text("Search")
        .font(.system(.body))
        .foregroundStyle(Color.inkFaint)

      Spacer()
    }
    .padding(.vertical, 11)
    .padding(.horizontal, 12)
    .frame(maxWidth: .infinity)
    .glassBackground(cornerRadius: 12)
  }
}

// Card displaying a Notebook in the grid.
private struct NoteCard: View {
  let title: String
  let subtitle: String
  let date: String

  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      Text(title)
        .font(.system(.title3, weight: .semibold))
        .foregroundStyle(Color.ink)
        .lineLimit(2)

      Text(subtitle)
        .font(.system(.body))
        .foregroundStyle(Color.inkSubtle)
        .lineSpacing(3)
        .lineLimit(3)

      Spacer(minLength: 0)

      Text(date.uppercased())
        .font(.system(.footnote))
        .foregroundStyle(Color.inkFaint)
    }
    .padding(16)
    .frame(maxWidth: .infinity, minHeight: 160, alignment: .topLeading)
    .glassBackground(cornerRadius: 14)
  }
}

// Card for creating a new Notebook.
private struct NewNoteCard: View {
  var body: some View {
    VStack(spacing: 10) {
      Image(systemName: "plus")
        .font(.system(size: 22, weight: .semibold))
        .foregroundStyle(Color.inkSubtle)

      Text("New note")
        .font(.system(.body, weight: .semibold))
        .foregroundStyle(Color.ink)
    }
    .padding(16)
    .frame(maxWidth: .infinity, minHeight: 160)
    .glassBackground(cornerRadius: 14)
  }
}


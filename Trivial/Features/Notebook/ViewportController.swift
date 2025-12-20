import Combine
import CoreGraphics
import Foundation

// The Viewport Controller decides which Ink Items should be loaded into memory.
// It watches the visible area and requests ink data only for items near that region.
// This prevents loading the entire Notebook when only a small portion is visible.
@MainActor
class ViewportController: ObservableObject {
  // The current visible y-range on the canvas (in canvas coordinates, not screen).
  // Updated as the user scrolls.
  private(set) var visibleYMin: CGFloat = 0
  private(set) var visibleYMax: CGFloat = 0

  // Buffer above and below the visible range to preload items before they become visible.
  // This reduces visible loading delays when scrolling.
  let bufferAmount: CGFloat = 500

  // All known Ink Items from the Notebook Model.
  // The viewport uses this to determine which items intersect the visible range.
  private var allItems: [InkItem] = []

  // IDs of items that are currently in the load zone (visible + buffer).
  // These items should have their payloads loaded.
  @Published private(set) var itemsInLoadZone: Set<String> = []

  // Updates the list of all known items.
  // Called when the manifest is refreshed (e.g., after a new commit).
  func updateAllItems(_ items: [InkItem]) {
    allItems = items
    recalculateLoadZone()
  }

  // Updates the visible y-range based on scroll position.
  // Called by the scroll view coordinator when scrolling occurs.
  func updateVisibleRange(yMin: CGFloat, yMax: CGFloat) {
    visibleYMin = yMin
    visibleYMax = yMax
    recalculateLoadZone()
  }

  // Recalculates which items should be loaded based on current visible range.
  private func recalculateLoadZone() {
    let loadZoneMin = visibleYMin - bufferAmount
    let loadZoneMax = visibleYMax + bufferAmount

    var newLoadZone: Set<String> = []

    for item in allItems {
      let itemYMin = item.rectangle.y
      let itemYMax = item.rectangle.y + item.rectangle.height

      // Check if item intersects the load zone.
      if itemYMax >= loadZoneMin && itemYMin <= loadZoneMax {
        newLoadZone.insert(item.id)
      }
    }

    // Only update if the load zone changed to avoid unnecessary updates.
    if newLoadZone != itemsInLoadZone {
      // Find items that were added to the load zone.
      let addedItems = newLoadZone.subtracting(itemsInLoadZone)
      // Find items that were removed from the load zone.
      let removedItems = itemsInLoadZone.subtracting(newLoadZone)

      if !addedItems.isEmpty {
        print("📥 VIEWPORT: Added \(addedItems.count) item(s) to load zone")
      }
      if !removedItems.isEmpty {
        print("📤 VIEWPORT: Removed \(removedItems.count) item(s) from load zone")
      }

      itemsInLoadZone = newLoadZone
    }
  }

  // Returns true if the given item ID is in the current load zone.
  func isItemInLoadZone(_ itemID: String) -> Bool {
    itemsInLoadZone.contains(itemID)
  }

  // Returns the IDs of items that need to be loaded (in zone but not yet loaded).
  func itemsToLoad(currentlyLoaded: Set<String>) -> Set<String> {
    itemsInLoadZone.subtracting(currentlyLoaded)
  }

  // Returns the IDs of items that should be released (loaded but no longer in zone).
  func itemsToRelease(currentlyLoaded: Set<String>) -> Set<String> {
    currentlyLoaded.subtracting(itemsInLoadZone)
  }
}


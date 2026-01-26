//
// NotebookViewModel.swift
// InkOS
//
// State management for the notebook renderer.
// Tracks animation state for each block and Alan's presence state.
// User controls pacing by tapping to advance to the next block.
// Alan's presence indicator reflects current activity (idle/thinking/outputting).
//

import SwiftUI

// MARK: - BlockAnimationState

// Animation state for a single block.
enum BlockAnimationState: Equatable, Sendable {
  // Block is waiting to animate (not yet visible).
  case waiting
  // Block is currently animating in.
  case animating
  // Block animation has completed.
  case complete
}

// MARK: - ActiveInputState

// State for the inline text input shown when user taps the blob.
struct ActiveInputState {
  // Index in the blocks array where the input should appear.
  let insertionIndex: Int
  // Current text in the input field.
  var text: String = ""
}

// MARK: - NotebookViewModel

// Observable state for the notebook canvas renderer.
// User taps to advance through blocks at their own pace.
@MainActor @Observable
final class NotebookViewModel {
  // The notebook document being rendered.
  var document: NotebookDocument

  // Animation state for each block, keyed by block ID.
  var animationState: [BlockID: BlockAnimationState] = [:]

  // Alan's current presence state for the metaball indicator.
  var alanState: AlanPresenceState = .idle

  // The block ID the metaball should be positioned next to.
  // Set immediately on tap so metaball moves before block is revealed.
  var metaballTargetBlockId: BlockID?

  // State for the inline input shown when user taps the blob.
  var activeInput: ActiveInputState?

  // Queue of block IDs waiting to be revealed.
  private var animationQueue: [BlockID] = []

  // Task for thinking delay, cancellable if user taps again.
  private var thinkingTask: Task<Void, Never>?

  // Task for revealing blocks to a checkpoint, cancellable on new tap.
  private var revealTask: Task<Void, Never>?

  // Duration for metaball position movement animation (in milliseconds).
  // Must match the animation duration in NotebookCanvasView (~150ms spring response).
  static let positionMovementDuration: Int = 150

  init(document: NotebookDocument) {
    self.document = document
    // Initialize all blocks as waiting.
    for block in document.blocks {
      animationState[block.id] = .waiting
    }
    // Build the queue of blocks to reveal.
    animationQueue = document.blocks.map { $0.id }
  }

  // Whether there are more blocks to reveal.
  var hasMoreBlocks: Bool {
    !animationQueue.isEmpty
  }

  // Whether any block is currently animating or has been revealed.
  // Used to determine if metaball should move from initial position.
  var hasAnimatingBlock: Bool {
    animationState.values.contains { $0 == .animating || $0 == .complete }
  }

  // Prepares the first block for reveal on user tap.
  // Sets metaball position but doesn't reveal content - user must tap.
  func prepareFirstBlock() {
    guard let firstId = animationQueue.first else { return }
    metaballTargetBlockId = firstId
    alanState = .idle
  }

  // Advances to the next block when user taps.
  // Sequence: metaball moves immediately → thinking during movement → reveal block → outputting.
  func advanceToNextBlock() {
    // Cancel any pending thinking task.
    thinkingTask?.cancel()

    // Mark any currently animating block as complete.
    for (blockId, state) in animationState where state == .animating {
      animationState[blockId] = .complete
    }

    // Check if there are more blocks.
    guard let nextId = animationQueue.first else {
      alanState = .idle
      return
    }

    // Phase 1: Immediately move metaball to next block position.
    metaballTargetBlockId = nextId

    // Enter thinking state (plays during movement).
    alanState = .thinking

    // Get the block to calculate its animation duration.
    let block = document.blocks.first { $0.id == nextId }
    let animationDuration = block?.content.animationDurationMs ?? 300

    thinkingTask = Task {
      // Phase 2: Wait for movement animation to complete.
      try? await Task.sleep(for: .milliseconds(Self.positionMovementDuration))
      guard !Task.isCancelled else { return }

      // Phase 3: Transition to outputting state after movement settles.
      alanState = .outputting

      // Phase 4: Brief pause, then reveal block.
      let revealDelay = Int.random(in: 200...400)
      try? await Task.sleep(for: .milliseconds(revealDelay))
      guard !Task.isCancelled else { return }

      animationQueue.removeFirst()
      animationState[nextId] = .animating

      // Phase 5: Return to idle after content animation completes.
      // Wait for the actual animation duration of this block.
      try? await Task.sleep(for: .milliseconds(animationDuration))
      guard !Task.isCancelled else { return }
      alanState = .idle
    }
  }

  // MARK: - Checkpoint-Based Reveal

  // Advances through blocks until the next checkpoint is reached.
  // Reveals all blocks up to and including the checkpoint, then stops.
  func advanceToNextCheckpoint() {
    // Cancel any pending tasks.
    thinkingTask?.cancel()
    revealTask?.cancel()

    // Mark any currently animating block as complete.
    for (blockId, state) in animationState where state == .animating {
      animationState[blockId] = .complete
    }

    // Find blocks to reveal (up to and including next checkpoint).
    let checkpointIdx = findNextCheckpointIndex() ?? animationQueue.count - 1
    guard checkpointIdx >= 0, !animationQueue.isEmpty else {
      alanState = .idle
      return
    }

    let blocksToReveal = Array(animationQueue.prefix(checkpointIdx + 1))

    revealTask = Task {
      for blockId in blocksToReveal {
        guard !Task.isCancelled else { return }
        await revealSingleBlockAsync(blockId)
      }
    }
  }

  // Reveals a single block with metaball movement and animation.
  // Checkpoints are processed but not visually rendered.
  private func revealSingleBlockAsync(_ blockId: BlockID) async {
    // Move metaball to this block position.
    metaballTargetBlockId = blockId

    // Enter thinking state (plays during movement).
    alanState = .thinking

    // Wait for movement animation to complete.
    try? await Task.sleep(for: .milliseconds(Self.positionMovementDuration))
    guard !Task.isCancelled else { return }

    // Handle checkpoint blocks specially - process but don't render.
    if isCheckpointBlock(blockId) {
      animationQueue.removeFirst()
      animationState[blockId] = .complete
      alanState = .idle
      return
    }

    // Transition to outputting state after movement settles.
    alanState = .outputting

    // Brief pause before revealing content.
    let revealDelay = Int.random(in: 200...400)
    try? await Task.sleep(for: .milliseconds(revealDelay))
    guard !Task.isCancelled else { return }

    // Reveal the block.
    animationQueue.removeFirst()
    animationState[blockId] = .animating

    // Wait for content animation to complete.
    let block = document.blocks.first { $0.id == blockId }
    let duration = block?.content.animationDurationMs ?? 300
    try? await Task.sleep(for: .milliseconds(duration))
    guard !Task.isCancelled else { return }

    alanState = .idle
  }

  // Immediately reveals all remaining blocks.
  func completeAllAnimations() {
    thinkingTask?.cancel()
    revealTask?.cancel()
    animationQueue.removeAll()
    for blockId in animationState.keys {
      animationState[blockId] = .complete
    }
    alanState = .idle
    activeInput = nil
  }

  // Resets all animations to waiting state.
  func resetAnimations() {
    thinkingTask?.cancel()
    revealTask?.cancel()
    animationQueue = document.blocks.map { $0.id }
    for block in document.blocks {
      animationState[block.id] = .waiting
    }
    alanState = .idle
    activeInput = nil
  }

  // MARK: - Checkpoint Helpers

  // Checks if a block is a checkpoint block.
  func isCheckpointBlock(_ id: BlockID) -> Bool {
    guard let block = document.blocks.first(where: { $0.id == id }) else { return false }
    if case .checkpoint = block.content {
      return true
    }
    return false
  }

  // Finds the index of the next checkpoint in the animation queue.
  // Returns nil if there are no checkpoints remaining.
  private func findNextCheckpointIndex() -> Int? {
    for (index, blockId) in animationQueue.enumerated() {
      if isCheckpointBlock(blockId) {
        return index
      }
    }
    return nil
  }

  // MARK: - Tap Handlers

  // Handles tap on content area.
  // Dismisses input if showing, otherwise advances to next checkpoint.
  func handleContentTap() {
    // Dismiss input if showing.
    if activeInput != nil {
      dismissInputBlock()
      return
    }

    // Advance to next checkpoint.
    advanceToNextCheckpoint()
  }

  // Handles tap on the blob.
  // Shows inline input if not already showing.
  func handleBlobTap() {
    // Don't show input during animation.
    guard revealTask == nil || revealTask?.isCancelled == true else { return }

    // Don't show if already showing.
    guard activeInput == nil else { return }

    showInputBlock()
  }

  // MARK: - Inline Input

  // Shows the inline input block after the last revealed block.
  func showInputBlock() {
    // Find the index of the last revealed block.
    let revealedBlocks = document.blocks.enumerated().filter { _, block in
      let state = animationState[block.id] ?? .waiting
      return state == .animating || state == .complete
    }

    // Insert after the last revealed block, or at index 0 if none revealed.
    let insertionIndex = revealedBlocks.last?.offset ?? -1

    activeInput = ActiveInputState(insertionIndex: insertionIndex)
  }

  // Dismisses the inline input block.
  func dismissInputBlock() {
    activeInput = nil
  }

  // Submits the input text.
  // TODO: Send to Alan for processing.
  func submitInput() {
    guard let input = activeInput, !input.text.isEmpty else { return }

    // TODO: Send input.text to Alan.

    dismissInputBlock()
  }
}

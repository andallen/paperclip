//
// NotebookViewModel.swift
// InkOS
//
// State management for the notebook renderer and Alan tutoring loop.
// Connects to OrchestrationActor for live conversations with Alan.
// Handles streaming responses, block insertion, session model updates,
// and memory context injection. User controls pacing by tapping to advance.
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

// MARK: - InputPreview

// A submitted user input displayed on the canvas for confirmation.
struct InputPreview: Identifiable, Sendable {
  let id: String
  let response: InputResponse
  let timestamp: Date

  init(response: InputResponse, timestamp: Date = Date()) {
    self.id = UUID().uuidString
    self.response = response
    self.timestamp = timestamp
  }
}

// MARK: - NotebookViewModel

// Observable state for the notebook canvas and Alan tutoring loop.
@MainActor @Observable
final class NotebookViewModel {
  // The notebook document being rendered.
  var document: NotebookDocument

  // Animation state for each block, keyed by block ID.
  var animationState: [BlockID: BlockAnimationState] = [:]

  // Submitted user inputs displayed on the canvas.
  var inputPreviews: [InputPreview] = []

  // Current session model from Alan (tracks goal, concepts, signals).
  var sessionModel: SessionModel?

  // Whether Alan is currently processing a request.
  var isProcessing = false

  // Current error message for display.
  var errorMessage: String?

  // Queue of block IDs waiting to be revealed.
  private var animationQueue: [BlockID] = []

  // Task for thinking delay, cancellable if user taps again.
  private var thinkingTask: Task<Void, Never>?

  // Task for revealing blocks to a checkpoint, cancellable on new tap.
  private var revealTask: Task<Void, Never>?

  // MARK: - Alan Integration

  // Orchestration actor for communicating with Alan backend.
  private let orchestration: OrchestrationActor

  // Conversation history for multi-turn context.
  private var conversationHistory: [ChatMessage] = []

  // Session data for persistence.
  private var sessionData: SessionData?

  // Session service for saving.
  private var sessionService: SessionService?

  // Blocks queued from Alan (waiting to be revealed by tap-to-advance).
  private var pendingBlocks: [Block] = []

  // MARK: - Initialization

  // Full initializer with session context and services.
  init(
    document: NotebookDocument,
    sessionData: SessionData? = nil,
    sessionService: SessionService? = nil
  ) {
    self.document = document
    self.sessionData = sessionData
    self.sessionService = sessionService
    self.orchestration = OrchestrationActor()

    // Restore session state.
    if let data = sessionData {
      self.sessionModel = data.sessionModel
      self.conversationHistory = data.conversationHistory
    } else {
      self.sessionModel = SessionModel.new(sessionId: document.id.rawValue)
    }

    // Initialize animation states for existing blocks.
    for block in document.blocks {
      animationState[block.id] = .waiting
    }
    animationQueue = document.blocks.map { $0.id }

    // Set up orchestration delegate.
    Task {
      await orchestration.setDelegate(self)
    }
  }

  // Whether there are more blocks to reveal.
  var hasMoreBlocks: Bool {
    !animationQueue.isEmpty
  }

  // MARK: - Block Advancement

  // Advances to the next block when user taps.
  func advanceToNextBlock() {
    thinkingTask?.cancel()

    // Mark any currently animating block as complete.
    for (blockId, state) in animationState where state == .animating {
      animationState[blockId] = .complete
    }

    guard let nextId = animationQueue.first else {
      // No more blocks in queue. Check if there are pending blocks from Alan.
      if !pendingBlocks.isEmpty {
        let block = pendingBlocks.removeFirst()
        appendBlockToDocument(block)
        revealBlock(block.id)
      }
      return
    }

    revealBlock(nextId)
  }

  // Reveals a single block with delay and animation.
  private func revealBlock(_ blockId: BlockID) {
    let block = document.blocks.first { $0.id == blockId }
    let animationDuration = block?.content.animationDurationMs ?? 300

    thinkingTask = Task {
      let revealDelay = Int.random(in: 200...400)
      try? await Task.sleep(for: .milliseconds(revealDelay))
      guard !Task.isCancelled else { return }

      animationQueue.removeAll { $0 == blockId }
      animationState[blockId] = .animating

      try? await Task.sleep(for: .milliseconds(animationDuration))
      guard !Task.isCancelled else { return }
    }
  }

  // MARK: - Checkpoint-Based Reveal

  // Advances through blocks until the next checkpoint is reached.
  func advanceToNextCheckpoint() {
    thinkingTask?.cancel()
    revealTask?.cancel()

    for (blockId, state) in animationState where state == .animating {
      animationState[blockId] = .complete
    }

    let checkpointIdx = findNextCheckpointIndex() ?? animationQueue.count - 1
    guard checkpointIdx >= 0, !animationQueue.isEmpty else {
      // Check pending blocks from Alan.
      if !pendingBlocks.isEmpty {
        flushPendingBlocks()
      }
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

  // Reveals a single block (async version for checkpoint flow).
  private func revealSingleBlockAsync(_ blockId: BlockID) async {
    if isCheckpointBlock(blockId) {
      animationQueue.removeAll { $0 == blockId }
      animationState[blockId] = .complete
      return
    }

    let revealDelay = Int.random(in: 200...400)
    try? await Task.sleep(for: .milliseconds(revealDelay))
    guard !Task.isCancelled else { return }

    animationQueue.removeAll { $0 == blockId }
    animationState[blockId] = .animating

    let block = document.blocks.first { $0.id == blockId }
    let duration = block?.content.animationDurationMs ?? 300
    try? await Task.sleep(for: .milliseconds(duration))
    guard !Task.isCancelled else { return }
  }

  // Immediately reveals all remaining blocks.
  func completeAllAnimations() {
    thinkingTask?.cancel()
    revealTask?.cancel()
    animationQueue.removeAll()
    for blockId in animationState.keys {
      animationState[blockId] = .complete
    }
    // Flush any pending blocks from Alan.
    flushPendingBlocks()
  }

  // Resets all animations to waiting state.
  func resetAnimations() {
    thinkingTask?.cancel()
    revealTask?.cancel()
    animationQueue = document.blocks.map { $0.id }
    for block in document.blocks {
      animationState[block.id] = .waiting
    }
  }

  // MARK: - Checkpoint Helpers

  func isCheckpointBlock(_ id: BlockID) -> Bool {
    guard let block = document.blocks.first(where: { $0.id == id }) else { return false }
    if case .checkpoint = block.content {
      return true
    }
    return false
  }

  private func findNextCheckpointIndex() -> Int? {
    for (index, blockId) in animationQueue.enumerated() where isCheckpointBlock(blockId) {
      return index
    }
    return nil
  }

  // MARK: - Tap Handlers

  func handleContentTap() {
    advanceToNextCheckpoint()
  }

  // MARK: - Canvas Input

  // Submits input from the persistent canvas input and sends to Alan.
  func submitCanvasInput(_ response: InputResponse) {
    guard !response.isEmpty else { return }

    // Create preview for visual confirmation.
    let preview = InputPreview(response: response)
    inputPreviews.append(preview)

    // Build the message text from the input response.
    var messageText = ""

    // If segments exist, build message from segment types.
    if let segments = response.segments, !segments.isEmpty {
      let parts: [String] = segments.compactMap { segment in
        switch segment {
        case .text(let text): return text
        case .drawing: return "[Handwriting submitted]"
        }
      }
      messageText = parts.joined(separator: "\n")
    } else {
      // Existing logic for non-segment responses.
      if let text = response.text, !text.isEmpty {
        messageText = text
      }
      // Append handwriting indicator if any drawing images exist.
      if response.handwritingImageData != nil {
        if !messageText.isEmpty {
          messageText += "\n"
        }
        messageText += "[Handwriting submitted]"
      }
    }

    // Append attachment indicator if no other content was built.
    if messageText.isEmpty, let attachments = response.attachments, !attachments.isEmpty {
      let filenames = attachments.map { $0.filename }.joined(separator: ", ")
      messageText = "[Files attached: \(filenames)]"
    }

    guard !messageText.isEmpty else { return }

    // Send to Alan with attachments.
    sendMessageToAlan(messageText, attachments: response.attachments)
  }

  // Sends a text message to Alan via the orchestration layer.
  // Optionally includes file attachments to upload to the Gemini Files API.
  private func sendMessageToAlan(_ content: String, attachments: [InputAttachment]? = nil) {
    let isFirstMessage = conversationHistory.isEmpty

    isProcessing = true
    errorMessage = nil

    let notebookContext = NotebookContext(
      documentId: document.id.rawValue,
      sessionTopic: document.title
    )

    // Read custom instructions from UserDefaults at call time.
    let customInstructions: String? = {
      let raw = UserDefaults.standard.string(forKey: "customInstructions") ?? ""
      return raw.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : raw
    }()

    Task {
      await orchestration.sendMessage(
        content,
        conversationHistory: conversationHistory,
        notebookContext: notebookContext,
        sessionModel: sessionModel,
        customInstructions: customInstructions,
        attachments: attachments
      )

      // Add to conversation history after sending.
      conversationHistory.append(ChatMessage(role: .user, content: content))
    }

    // TODO: Auto-generate session name after first message once API endpoint is ready.
  }

  // Clears all input previews.
  func clearInputPreviews() {
    inputPreviews.removeAll()
  }

  // MARK: - Block Management

  // Appends a block to the document and sets up animation state.
  private func appendBlockToDocument(_ block: Block) {
    document.appendBlock(block)
    animationState[block.id] = .waiting
    animationQueue.append(block.id)
  }

  // Flushes pending blocks from Alan into the document.
  private func flushPendingBlocks() {
    for block in pendingBlocks {
      appendBlockToDocument(block)
      // Auto-reveal pending blocks so they appear immediately.
      animationState[block.id] = .complete
      animationQueue.removeAll { $0 == block.id }
    }
    pendingBlocks.removeAll()
  }

  // MARK: - Session Persistence

  // Saves the current session state to disk.
  func saveSession() {
    guard var data = sessionData else { return }
    data.document = document
    data.sessionModel = sessionModel
    data.conversationHistory = conversationHistory

    // Update metadata.
    data.metadata = SessionMetadata(
      id: data.metadata.id,
      title: data.metadata.title,
      updatedAt: Date(),
      createdAt: data.metadata.createdAt,
      goalDescription: sessionModel?.goal?.description,
      goalProgress: sessionModel?.goal?.progress ?? 0,
      blockCount: document.blocks.count,
      userRenamed: data.metadata.userRenamed
    )

    sessionData = data
    sessionService?.saveSession(data)
  }

  // MARK: - Adaptive Pacing

  // Adjusts animation timing based on session signals.
  private var pacingMultiplier: Double {
    guard let signals = sessionModel?.signals else { return 1.0 }

    var multiplier = 1.0

    // Slow down when frustrated.
    if signals.frustration == .high {
      multiplier *= 1.3
    } else if signals.frustration == .mild {
      multiplier *= 1.1
    }

    // Adjust for pace.
    switch signals.pace {
    case .slow:
      multiplier *= 1.2
    case .fast:
      multiplier *= 0.8
    case .normal:
      break
    }

    // Speed up when engagement is high.
    if signals.engagement == .high {
      multiplier *= 0.9
    } else if signals.engagement == .low {
      multiplier *= 1.1
    }

    return multiplier
  }
}

// MARK: - OrchestrationDelegate

extension NotebookViewModel: OrchestrationDelegate {
  // Called when a block should be inserted into the notebook.
  func orchestration(_ orchestration: OrchestrationActor, didInsertBlock block: Block) {
    // Add to pending blocks (revealed on tap-to-advance).
    pendingBlocks.append(block)

    // If no blocks are currently waiting to be revealed, auto-append.
    if animationQueue.isEmpty {
      let newBlock = pendingBlocks.removeFirst()
      appendBlockToDocument(newBlock)

      // Auto-reveal with animation.
      revealBlock(newBlock.id)
    }
  }

  // Called when a block should be updated (placeholder replaced with content).
  func orchestration(_ orchestration: OrchestrationActor, didUpdateBlock block: Block) {
    if let index = document.indexOfBlock(withId: block.id) {
      document.updateBlock(at: index, with: block)
    }
  }

  // Called when streaming text is received (for live typing effect).
  func orchestration(_ orchestration: OrchestrationActor, didReceiveStreamingText text: String) {
    // Streaming text is handled by the SSE layer.
    // We can use this for a typing indicator if desired.
  }

  // Called when the session model is updated by Alan.
  func orchestration(_ orchestration: OrchestrationActor, didUpdateSessionModel model: SessionModel) {
    sessionModel = model
  }

  // Called when all processing is complete.
  func orchestrationDidComplete(_ orchestration: OrchestrationActor, tokenMetadata: TokenMetadata?) {
    isProcessing = false

    // Add assistant message to history based on the blocks received.
    let assistantContent = pendingBlocks.isEmpty
      ? "[Response complete]"
      : pendingBlocks.compactMap { block -> String? in
        if case .text(let tc) = block.content {
          return tc.segments.map { segment -> String in
            switch segment {
            case .plain(let text, _): return text
            case .kinetic(let text, _, _, _, _): return text
            case .latex(let latex, _, _): return latex
            case .code(let code, _, _, _): return code
            }
          }.joined()
        }
        return nil
      }.joined(separator: "\n")

    conversationHistory.append(ChatMessage(role: .assistant, content: assistantContent))

    // If there are pending blocks and the user hasn't tapped, queue them.
    if !pendingBlocks.isEmpty && animationQueue.isEmpty {
      for block in pendingBlocks {
        appendBlockToDocument(block)
      }
      pendingBlocks.removeAll()

      // Start revealing the first new block.
      if let firstNew = animationQueue.first {
        revealBlock(firstNew)
      }
    }

    // Auto-save after each response.
    saveSession()
  }

  // Called when an error occurs.
  func orchestration(_ orchestration: OrchestrationActor, didEncounterError error: AlanError) {
    isProcessing = false
    errorMessage = error.localizedDescription
    print("[NotebookViewModel] Alan error: \(error)")
  }
}

//
// ReceiverService.swift
// PaperClipMac
//
// Observable wrapper around the NWListener that receives PNGs from the
// PaperClip iPad app over peer-to-peer Bonjour (AWDL). Writes received
// images to the system clipboard.
//
// Protocol: each message is a 4-byte big-endian UInt32 length header
// followed by that many bytes of raw PNG data. Multiple messages can
// arrive on the same persistent connection.
//

import AppKit
import Network
import os

// Unified log for debugging:
//   log stream --predicate 'subsystem == "me.andy.allen.PaperClipMac"'
private let log = Logger(subsystem: "me.andy.allen.PaperClipMac", category: "ReceiverService")

// Bonjour service type shared between iPad sender and Mac receiver.
private let serviceType = "_paperclip._tcp"

// MARK: - ReceiverState

// Represents the current state of the receiver for UI display.
enum ReceiverState {
  case idle       // Listener not started yet.
  case waiting    // Listening, no iPad connected.
  case connected  // iPad connection active, ready to receive.
  case receiving  // Actively reading a PNG payload.
}

// MARK: - ReceiverService

// Listens for incoming peer-to-peer connections from the PaperClip iPad app
// and writes received PNGs to the system clipboard.
@MainActor @Observable
final class ReceiverService {
  // Current state (drives menu bar icon and status text).
  var state: ReceiverState = .idle

  // Name of the connected iPad, extracted from the connection endpoint.
  var connectedDeviceName: String?

  // Number of PNGs received in this session.
  var receivedCount: Int = 0

  // Timestamp of the most recently received PNG.
  var lastReceivedDate: Date?

  // Raw PNG data of the most recently received image (for thumbnail preview).
  var lastReceivedImage: Data?

  // Capture mode of the most recently received image (crop, viewport, fullCanvas).
  var lastCaptureMode: CaptureMode?

  // The Bonjour listener.
  private var listener: NWListener?

  // The active connection from an iPad.
  private var activeConnection: NWConnection?

  init() {}

  // MARK: - Lifecycle

  // Creates and starts the NWListener with peer-to-peer (AWDL) enabled.
  // Call once when the app launches.
  func start() {
    let parameters = NWParameters.tcp
    // Enable peer-to-peer discovery (AWDL — same transport as AirDrop).
    parameters.includePeerToPeer = true

    let newListener: NWListener
    do {
      newListener = try NWListener(using: parameters)
    } catch {
      log.error("Failed to create listener: \(error.localizedDescription)")
      state = .idle
      return
    }

    // Advertise the service with the Mac's display name.
    let macName = Host.current().localizedName ?? "Mac"
    newListener.service = NWListener.Service(name: macName, type: serviceType)

    newListener.stateUpdateHandler = { [weak self] listenerState in
      Task { @MainActor in
        self?.handleListenerState(listenerState, listener: newListener)
      }
    }

    // Accept each incoming connection and begin reading frames.
    newListener.newConnectionHandler = { [weak self] connection in
      Task { @MainActor in
        log.info("Accepted connection from \(String(describing: connection.endpoint))")
        self?.handleConnection(connection)
      }
    }

    newListener.start(queue: .main)
    listener = newListener
    state = .waiting
    log.info("Receiver started, advertising as \"\(macName)\"")
  }

  // Stops the listener and closes any active connection.
  func stop() {
    activeConnection?.cancel()
    activeConnection = nil
    listener?.cancel()
    listener = nil
    state = .idle
    connectedDeviceName = nil
    log.info("Receiver stopped")
  }

  // MARK: - Listener State

  // Handles listener state transitions.
  private func handleListenerState(_ listenerState: NWListener.State, listener: NWListener) {
    switch listenerState {
    case .ready:
      let port = listener.port?.rawValue ?? 0
      log.info("Listening on port \(port)")
      state = .waiting
    case .failed(let error):
      log.error("Listener failed: \(error.localizedDescription)")
      // Attempt to restart after a brief delay.
      listener.cancel()
      Task {
        try? await Task.sleep(for: .seconds(2))
        start()
      }
    case .cancelled:
      log.info("Listener cancelled")
    default:
      break
    }
  }

  // MARK: - Connection Handling

  // Accepts a new connection from an iPad and begins the frame-reading loop.
  private func handleConnection(_ connection: NWConnection) {
    // Cancel any existing connection (one iPad at a time).
    activeConnection?.cancel()
    activeConnection = connection

    // Device name will be set when the iPad sends its name as the first frame.
    connectedDeviceName = nil

    connection.stateUpdateHandler = { [weak self] connectionState in
      Task { @MainActor in
        self?.handleConnectionState(connectionState, connection: connection)
      }
    }

    connection.start(queue: .main)
  }

  // Handles connection state transitions.
  private func handleConnectionState(_ connectionState: NWConnection.State, connection: NWConnection) {
    switch connectionState {
    case .ready:
      log.info("Connection ready")
      state = .connected
      readFrame(from: connection)
    case .failed(let error):
      log.error("Connection failed: \(error.localizedDescription)")
      connection.cancel()
      cleanupConnection(connection)
    case .cancelled:
      log.info("Connection closed")
      cleanupConnection(connection)
    default:
      break
    }
  }

  // Resets state when a connection closes.
  private func cleanupConnection(_ connection: NWConnection) {
    // Only clean up if this is still the active connection.
    guard activeConnection === connection else { return }
    activeConnection = nil
    connectedDeviceName = nil
    state = .waiting
  }

  // MARK: - Frame Reading

  // Reads one frame (4-byte length + PNG payload), writes the PNG to the
  // clipboard, then loops to read the next frame on the same connection.
  private func readFrame(from connection: NWConnection) {
    // Read the 4-byte length header.
    connection.receive(minimumIncompleteLength: 4, maximumLength: 4) { [weak self] header, _, _, error in
      Task { @MainActor in
        if let error = error {
          log.error("Header read error: \(error.localizedDescription)")
          connection.cancel()
          return
        }
        guard let header = header, header.count == 4 else {
          // Clean disconnect — iPad closed the connection.
          log.info("Connection ended (no header)")
          connection.cancel()
          return
        }

        // Parse big-endian UInt32 payload length.
        let length = header.withUnsafeBytes { $0.load(as: UInt32.self).bigEndian }
        guard length > 0, length < 50_000_000 else {
          log.error("Invalid frame length: \(length)")
          connection.cancel()
          return
        }

        self?.state = .receiving
        self?.readPayload(from: connection, remaining: Int(length), accumulated: Data())
      }
    }
  }

  // Accumulates payload bytes until the full PNG is received. Network.framework
  // may deliver data in chunks smaller than requested, so this reads in a loop.
  private func readPayload(from connection: NWConnection, remaining: Int, accumulated: Data) {
    connection.receive(minimumIncompleteLength: 1, maximumLength: remaining) { [weak self] chunk, _, _, error in
      Task { @MainActor in
        if let error = error {
          log.error("Payload read error: \(error.localizedDescription)")
          connection.cancel()
          return
        }
        guard let chunk = chunk, !chunk.isEmpty else {
          log.error("Connection ended mid-payload (\(accumulated.count) of \(accumulated.count + remaining) bytes)")
          connection.cancel()
          return
        }

        var buffer = accumulated
        buffer.append(chunk)
        let left = remaining - chunk.count

        if left == 0 {
          // Full frame received — check if it's a PNG or a device name.
          self?.handleReceivedFrame(buffer)
          self?.readFrame(from: connection)
        } else {
          // More bytes to read.
          self?.readPayload(from: connection, remaining: left, accumulated: buffer)
        }
      }
    }
  }

  // MARK: - Frame Dispatch

  // PNG files always start with these 8 magic bytes.
  private static let pngMagic: [UInt8] = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]

  // Routes a received frame to the correct handler based on content.
  // PNG data starts with magic bytes; anything else is treated as a
  // UTF-8 device name sent by the iPad on first connect.
  private func handleReceivedFrame(_ data: Data) {
    if data.count >= 8, data.prefix(8).elementsEqual(Self.pngMagic) {
      writeToClipboard(data)
    } else if let name = String(data: data, encoding: .utf8), !name.isEmpty {
      connectedDeviceName = name
      log.info("iPad identified as \"\(name)\"")
    } else {
      log.warning("Received unrecognized frame (\(data.count) bytes)")
    }
  }

  // MARK: - Clipboard

  // Replaces the system clipboard contents with the given PNG data.
  private func writeToClipboard(_ pngData: Data) {
    let pasteboard = NSPasteboard.general
    pasteboard.clearContents()
    pasteboard.setData(pngData, forType: .png)

    receivedCount += 1
    lastReceivedDate = Date()
    lastReceivedImage = pngData
    lastCaptureMode = PNGCaptureMode.captureMode(from: pngData)
    state = .connected

    let total = receivedCount
    log.info("Wrote \(pngData.count) bytes to clipboard (total: \(total))")
  }
}

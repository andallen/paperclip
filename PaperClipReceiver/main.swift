// PaperClipReceiver — Mac-side daemon that receives PNGs from the PaperClip
// iPad app over a peer-to-peer Bonjour connection and places them on the
// system clipboard.
//
// Protocol: each message is a 4-byte big-endian UInt32 length header followed
// by that many bytes of raw PNG data. Multiple messages can arrive on the same
// persistent connection.
//
// Build:  Scripts/buildreceiver
// Install: Scripts/install-receiver (copies binary + launchd plist)

import AppKit    // NSPasteboard
import Network   // NWListener, NWConnection
import os        // Logger

// Unified log destination for debugging:
//   log stream --predicate 'subsystem == "me.andy.allen.PaperClipReceiver"'
private let log = Logger(subsystem: "me.andy.allen.PaperClipReceiver", category: "main")

// Bonjour service type shared between iPad sender and Mac receiver.
private let serviceType = "_paperclip._tcp"

// MARK: - Listener Setup

// Creates and starts an NWListener that advertises over Bonjour with
// peer-to-peer (AWDL) enabled so it works on restricted networks like eduroam.
func startListener() {
  let parameters = NWParameters.tcp
  // Enable peer-to-peer discovery (AWDL — same transport as AirDrop).
  parameters.includePeerToPeer = true

  let listener: NWListener
  do {
    listener = try NWListener(using: parameters)
  } catch {
    log.error("Failed to create listener: \(error.localizedDescription)")
    return
  }

  // Advertise the service with the Mac's name so the iPad can display it.
  let macName = Host.current().localizedName ?? "Mac"
  listener.service = NWListener.Service(name: macName, type: serviceType)

  listener.stateUpdateHandler = { state in
    switch state {
    case .ready:
      let port = listener.port?.rawValue ?? 0
      log.info("Listening on port \(port) as \"\(macName)\"")
      // Also print to stdout for scripts that capture output.
      print("PAPERCLIP_PORT=\(port)")
      fflush(stdout)
    case .failed(let error):
      log.error("Listener failed: \(error.localizedDescription)")
      // Attempt to restart after a brief delay.
      DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
        listener.cancel()
        startListener()
      }
    case .cancelled:
      log.info("Listener cancelled")
    default:
      break
    }
  }

  // Accept each incoming connection and begin reading frames.
  listener.newConnectionHandler = { connection in
    log.info("Accepted connection from \(String(describing: connection.endpoint))")
    handleConnection(connection)
  }

  listener.start(queue: .main)
}

// MARK: - Connection Handling

// Monitors connection state and kicks off the frame-reading loop once ready.
func handleConnection(_ connection: NWConnection) {
  connection.stateUpdateHandler = { state in
    switch state {
    case .ready:
      log.info("Connection ready")
      readFrame(from: connection)
    case .failed(let error):
      log.error("Connection failed: \(error.localizedDescription)")
      connection.cancel()
    case .cancelled:
      log.info("Connection closed")
    default:
      break
    }
  }
  connection.start(queue: .main)
}

// MARK: - Frame Reading

// Reads one frame (4-byte length + PNG payload), writes the PNG to the
// clipboard, then loops to read the next frame on the same connection.
func readFrame(from connection: NWConnection) {
  // Step 1: Read the 4-byte length header.
  connection.receive(minimumIncompleteLength: 4, maximumLength: 4) { header, _, _, error in
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

    // Step 2: Read exactly `length` bytes of PNG data.
    readPayload(from: connection, remaining: Int(length), accumulated: Data())
  }
}

// Accumulates payload bytes until the full PNG is received. Network.framework
// may deliver data in chunks smaller than requested, so this reads in a loop.
func readPayload(from connection: NWConnection, remaining: Int, accumulated: Data) {
  connection.receive(minimumIncompleteLength: 1, maximumLength: remaining) { chunk, _, _, error in
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
      // Full PNG received — write to clipboard and read next frame.
      writeToClipboard(buffer)
      readFrame(from: connection)
    } else {
      // More bytes to read.
      readPayload(from: connection, remaining: left, accumulated: buffer)
    }
  }
}

// MARK: - Clipboard

// Replaces the system clipboard contents with the given PNG data.
func writeToClipboard(_ pngData: Data) {
  let pasteboard = NSPasteboard.general
  pasteboard.clearContents()
  pasteboard.setData(pngData, forType: .png)
  log.info("Wrote \(pngData.count) bytes to clipboard")
}

// MARK: - Entry Point

log.info("PaperClipReceiver starting")
startListener()
dispatchMain()

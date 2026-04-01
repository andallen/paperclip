//
// TransferService.swift
// PaperClip
//
// Manages peer-to-peer discovery and image transfer to a Mac running
// PaperClipReceiver. Uses Network.framework with Bonjour and AWDL
// (peer-to-peer) so it works on restricted networks like eduroam.
//
// Protocol: each message is a 4-byte big-endian UInt32 length header
// followed by that many bytes of raw PNG data. The connection is
// persistent — established once on discovery and reused for every send.
//

import Foundation
import Network
import SwiftUI
import os

// Unified log for debugging:
//   log stream --predicate 'subsystem == "me.andy.allen.PaperClip.transfer"'
private let log = Logger(subsystem: "me.andy.allen.PaperClip.transfer", category: "TransferService")

// Bonjour service type shared between iPad sender and Mac receiver.
private let serviceType = "_paperclip._tcp"

// MARK: - TransferError

// Errors that can occur during a peer-to-peer send.
enum TransferError: Error, LocalizedError {
  case noConnection
  case sendFailed(String)

  var errorDescription: String? {
    switch self {
    case .noConnection:
      return "No Mac found on network"
    case .sendFailed(let detail):
      return "Transfer failed: \(detail)"
    }
  }
}

// MARK: - ConnectionState

// Represents the current state of the peer-to-peer link.
enum ConnectionState {
  case searching   // NWBrowser is looking for a Mac receiver.
  case connected   // A connection is active and ready to send.
  case unavailable // Bonjour or network unavailable.
}

// MARK: - TransferService

// Discovers a Mac running PaperClipReceiver via Bonjour and maintains a
// persistent connection for sending PNG images.
@MainActor @Observable
final class TransferService {
  // Current connection state (drives UI indicators).
  var connectionState: ConnectionState = .searching

  // Display name of the connected Mac (from Bonjour advertisement).
  var connectedMacName: String?

  // The Bonjour browser that discovers Mac receivers.
  private var browser: NWBrowser?

  // The active peer-to-peer connection to the Mac.
  private var connection: NWConnection?

  // The endpoint currently connected to (used to avoid duplicate connections).
  private var currentEndpoint: NWEndpoint?

  init() {}

  // MARK: - Lifecycle

  // Starts the Bonjour browser. Call once on app launch.
  func start() {
    startBrowsing()
  }

  // MARK: - Browsing

  // Creates and starts an NWBrowser that looks for _paperclip._tcp services
  // with peer-to-peer (AWDL) enabled.
  private func startBrowsing() {
    // TCP parameters with peer-to-peer for AWDL discovery.
    let parameters = NWParameters()
    parameters.includePeerToPeer = true

    let descriptor = NWBrowser.Descriptor.bonjour(type: serviceType, domain: nil)
    let newBrowser = NWBrowser(for: descriptor, using: parameters)

    newBrowser.stateUpdateHandler = { [weak self] state in
      Task { @MainActor in
        self?.handleBrowserState(state)
      }
    }

    newBrowser.browseResultsChangedHandler = { [weak self] results, _ in
      Task { @MainActor in
        self?.handleBrowserResults(results)
      }
    }

    newBrowser.start(queue: .main)
    browser = newBrowser
    connectionState = .searching
    log.info("Started browsing for Mac receivers")
  }

  // Handles browser state transitions.
  private func handleBrowserState(_ state: NWBrowser.State) {
    switch state {
    case .ready:
      log.info("Browser ready")
    case .failed(let error):
      log.error("Browser failed: \(error.localizedDescription)")
      connectionState = .unavailable
      // Restart after a delay.
      Task {
        try? await Task.sleep(for: .seconds(2))
        browser?.cancel()
        startBrowsing()
      }
    case .cancelled:
      log.info("Browser cancelled")
    default:
      break
    }
  }

  // Called when the set of discovered services changes. Connects to the
  // first available Mac receiver.
  private func handleBrowserResults(_ results: Set<NWBrowser.Result>) {
    // Find the first result that has a Bonjour endpoint with a name.
    let candidate = results.first { result in
      if case .service = result.endpoint { return true }
      return false
    }

    guard let candidate = candidate else {
      // No Mac receivers found. If we had a connection, it may have gone away.
      if connection == nil {
        connectionState = .searching
        connectedMacName = nil
        log.info("No Mac receivers found")
      }
      return
    }

    // Extract the display name from the Bonjour endpoint.
    let name: String
    if case .service(let serviceName, _, _, _) = candidate.endpoint {
      name = serviceName
    } else {
      name = "Mac"
    }

    // Skip if already connected to this endpoint.
    if currentEndpoint == candidate.endpoint, connection != nil {
      return
    }

    log.info("Found Mac receiver: \(name)")
    connectToEndpoint(candidate.endpoint, name: name)
  }

  // MARK: - Connection

  // Establishes a persistent TCP connection to the discovered Mac.
  private func connectToEndpoint(_ endpoint: NWEndpoint, name: String) {
    // Cancel any existing connection.
    connection?.cancel()

    // TCP parameters with peer-to-peer enabled for AWDL.
    let parameters = NWParameters.tcp
    parameters.includePeerToPeer = true

    let newConnection = NWConnection(to: endpoint, using: parameters)

    newConnection.stateUpdateHandler = { [weak self] state in
      Task { @MainActor in
        self?.handleConnectionState(state, name: name, endpoint: endpoint)
      }
    }

    newConnection.start(queue: .main)
    connection = newConnection
    currentEndpoint = endpoint
  }

  // Handles connection state transitions.
  private func handleConnectionState(_ state: NWConnection.State, name: String, endpoint: NWEndpoint) {
    switch state {
    case .ready:
      connectionState = .connected
      connectedMacName = name
      log.info("Connected to \(name)")
      sendDeviceName()

    case .failed(let error):
      log.error("Connection to \(name) failed: \(error.localizedDescription)")
      cleanupConnection()
      // The browser is still running and will re-discover the endpoint.

    case .cancelled:
      log.info("Connection to \(name) cancelled")
      cleanupConnection()

    case .waiting(let error):
      log.info("Connection waiting: \(error.localizedDescription)")

    default:
      break
    }
  }

  // Resets connection state so the browser can reconnect.
  private func cleanupConnection() {
    connection = nil
    currentEndpoint = nil
    connectionState = .searching
    connectedMacName = nil
  }

  // MARK: - Sending

  // Sends the iPad's device name as the first frame after connecting.
  // The Mac distinguishes this from PNG data by checking for PNG magic bytes.
  private func sendDeviceName() {
    guard let connection = connection else { return }
    let name = UIDevice.current.name
    guard let nameData = name.data(using: .utf8) else { return }

    // Same 4-byte length-prefixed framing as PNG sends.
    var frame = Data(capacity: 4 + nameData.count)
    var length = UInt32(nameData.count).bigEndian
    frame.append(Data(bytes: &length, count: 4))
    frame.append(nameData)

    connection.send(content: frame, completion: .contentProcessed { error in
      if let error = error {
        log.error("Failed to send device name: \(error.localizedDescription)")
      } else {
        log.info("Sent device name: \(name)")
      }
    })
  }

  // Sends a PNG image to the connected Mac. The data is framed as a 4-byte
  // big-endian length header followed by the raw PNG bytes.
  // Throws TransferError if no connection is available or the send fails.
  func send(_ pngData: Data) async throws {
    guard let connection = connection, connectionState == .connected else {
      throw TransferError.noConnection
    }

    // Build the frame: [4-byte length][PNG data].
    var frame = Data(capacity: 4 + pngData.count)
    var length = UInt32(pngData.count).bigEndian
    frame.append(Data(bytes: &length, count: 4))
    frame.append(pngData)

    // Send the frame on the existing connection.
    try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
      connection.send(content: frame, completion: .contentProcessed { error in
        if let error = error {
          continuation.resume(throwing: TransferError.sendFailed(error.localizedDescription))
        } else {
          log.info("Sent \(pngData.count) bytes to Mac")
          continuation.resume()
        }
      })
    }
  }
}

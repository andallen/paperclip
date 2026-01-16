//
// MemoryAPIClient.swift
// InkOS
//
// HTTP client for the memory update endpoint.
// Sends session data to the memory subagent and receives updates.
//

import Foundation

// MARK: - MemoryAPIClient

// Client for communicating with the memory update Firebase function.
final class MemoryAPIClient: MemoryAPIClientProtocol, Sendable {
  private let session: URLSession
  private let baseURL: URL
  private let decoder: JSONDecoder
  private let encoder: JSONEncoder

  init(
    session: URLSession = .shared,
    baseURL: URL = AlanEndpoints.current.baseURL
  ) {
    self.session = session
    self.baseURL = baseURL

    self.decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601

    self.encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
  }

  // Memory update endpoint URL.
  private var memoryUpdateURL: URL {
    baseURL.appendingPathComponent("memoryUpdate")
  }

  // Calls the memory update endpoint.
  func updateMemory(request: MemoryUpdateRequest) async throws -> MemoryUpdateResponse {
    var urlRequest = URLRequest(url: memoryUpdateURL)
    urlRequest.httpMethod = "POST"
    urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
    urlRequest.timeoutInterval = AlanEndpoints.defaultTimeoutInterval

    // Encode request body.
    urlRequest.httpBody = try encoder.encode(request)

    // Make request.
    let (data, response) = try await session.data(for: urlRequest)

    // Check response status.
    guard let httpResponse = response as? HTTPURLResponse else {
      throw MemoryAPIError.invalidResponse
    }

    // Handle error responses.
    if httpResponse.statusCode != 200 {
      if let errorResponse = try? decoder.decode(MemoryUpdateError.self, from: data) {
        throw MemoryAPIError.serverError(
          statusCode: httpResponse.statusCode,
          message: errorResponse.error,
          details: errorResponse.details
        )
      }
      throw MemoryAPIError.httpError(statusCode: httpResponse.statusCode)
    }

    // Decode successful response.
    do {
      return try decoder.decode(MemoryUpdateResponse.self, from: data)
    } catch {
      throw MemoryAPIError.decodingError(error)
    }
  }
}

// MARK: - MemoryAPIError

// Errors from the memory API.
enum MemoryAPIError: Error, LocalizedError {
  case invalidResponse
  case httpError(statusCode: Int)
  case serverError(statusCode: Int, message: String, details: String?)
  case decodingError(Error)

  var errorDescription: String? {
    switch self {
    case .invalidResponse:
      return "Invalid response from memory service"
    case .httpError(let statusCode):
      return "Memory service returned status \(statusCode)"
    case .serverError(_, let message, let details):
      if let details = details {
        return "\(message): \(details)"
      }
      return message
    case .decodingError(let error):
      return "Failed to decode response: \(error.localizedDescription)"
    }
  }
}

// MARK: - MemoryAPIClient Convenience

extension MemoryAPIClient {
  // Creates a client using the current environment's endpoints.
  static var current: MemoryAPIClient {
    MemoryAPIClient(baseURL: AlanEndpoints.current.baseURL)
  }

  // Creates a client for the local emulator.
  static var localEmulator: MemoryAPIClient {
    MemoryAPIClient(baseURL: AlanEndpoints.localEmulator.baseURL)
  }

  // Creates a client for production.
  static var production: MemoryAPIClient {
    MemoryAPIClient(baseURL: AlanEndpoints.production.baseURL)
  }
}

//
// AlanAPIClient.swift
// InkOS
//
// Actor-based API client for communicating with Alan and subagent endpoints.
// Supports SSE streaming for real-time responses.
//

import Foundation

// MARK: - AlanAPIClient

// API client for Alan and subagent communication.
// Uses Swift concurrency with actor isolation for thread-safe access.
actor AlanAPIClient {
  // Endpoint configuration.
  private let endpoints: AlanEndpoints

  // URL session for requests.
  private let session: URLSession

  // JSON encoder with standard configuration.
  private let encoder: JSONEncoder = {
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    encoder.keyEncodingStrategy = .convertToSnakeCase
    return encoder
  }()

  // JSON decoder with standard configuration.
  private let decoder: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return decoder
  }()

  // Creates a client with the specified endpoints.
  init(endpoints: AlanEndpoints = .current) {
    self.endpoints = endpoints

    let config = URLSessionConfiguration.default
    config.timeoutIntervalForRequest = AlanEndpoints.defaultTimeoutInterval
    config.timeoutIntervalForResource = AlanEndpoints.streamingTimeoutInterval
    self.session = URLSession(configuration: config)
  }

  // MARK: - File Upload

  // Request body for the uploadFile endpoint.
  private struct UploadFileRequest: Encodable {
    let base64Data: String
    let mimeType: String
    let displayName: String
  }

  // Response from the uploadFile endpoint.
  private struct UploadFileResponse: Decodable {
    let fileUri: String
    let mimeType: String
    let name: String
    let expiresAt: String?
  }

  // Uploads a file attachment to the Gemini Files API via the backend proxy.
  // Returns a FileReference that can be included in an AlanRequest.
  func uploadFile(attachment: InputAttachment) async throws -> FileReference {
    let base64 = attachment.data.base64EncodedString()
    let uploadRequest = UploadFileRequest(
      base64Data: base64,
      mimeType: attachment.mimeType,
      displayName: attachment.filename
    )

    var urlRequest = URLRequest(url: endpoints.uploadFileURL)
    urlRequest.httpMethod = "POST"
    urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
    urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
    // Allow extra time for large file processing.
    urlRequest.timeoutInterval = 120

    do {
      urlRequest.httpBody = try encoder.encode(uploadRequest)
    } catch {
      throw AlanError.decodingError(context: "Failed to encode upload request: \(error)")
    }

    let (data, response) = try await session.data(for: urlRequest)

    guard let httpResponse = response as? HTTPURLResponse else {
      throw AlanError.invalidResponse(reason: "Not an HTTP response")
    }

    guard httpResponse.statusCode == 200 else {
      // Try to extract error message from response body.
      let errorMessage: String
      if let body = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
        let msg = body["error"] as? String
      {
        errorMessage = msg
      } else {
        errorMessage = "Status \(httpResponse.statusCode)"
      }
      throw AlanError.uploadFailed(filename: attachment.filename, reason: errorMessage)
    }

    do {
      let uploadResponse = try decoder.decode(UploadFileResponse.self, from: data)
      return FileReference(
        fileUri: uploadResponse.fileUri,
        mimeType: uploadResponse.mimeType,
        displayName: attachment.filename
      )
    } catch {
      throw AlanError.decodingError(context: "Failed to decode upload response: \(error)")
    }
  }

  // MARK: - Alan Chat

  // Sends a message to Alan and returns a stream of events.
  // The stream yields events as they arrive via SSE.
  func sendMessage(
    messages: [ChatMessage],
    notebookContext: NotebookContext,
    sessionModel: SessionModel? = nil,
    memoryContext: String? = nil,
    customInstructions: String? = nil,
    fileReferences: [FileReference]? = nil
  ) -> AsyncThrowingStream<AlanStreamEvent, Error> {
    AsyncThrowingStream { continuation in
      Task {
        do {
          let request = AlanRequest(
            messages: messages,
            notebookContext: notebookContext,
            sessionModel: sessionModel,
            memoryContext: memoryContext,
            customInstructions: customInstructions,
            fileReferences: fileReferences
          )
          let urlRequest = try buildRequest(
            url: endpoints.alanURL,
            body: request,
            acceptSSE: true
          )

          let (bytes, response) = try await session.bytes(for: urlRequest)

          guard let httpResponse = response as? HTTPURLResponse else {
            throw AlanError.invalidResponse(reason: "Not an HTTP response")
          }

          guard httpResponse.statusCode == 200 else {
            throw AlanError.serverError(
              statusCode: httpResponse.statusCode,
              message: "Alan request failed"
            )
          }

          var lineBuffer = SSELineBuffer()

          for try await chunk in bytes {
            let data = Data([chunk])
            let lines = lineBuffer.append(data)

            for line in lines {
              if let event = SSEParser.parse(line: line) {
                continuation.yield(event)

                // Check for terminal events.
                if case .done = event {
                  continuation.finish()
                  return
                }
                if case .error(let code, let message) = event {
                  throw AlanError.serverError(statusCode: 0, message: "[\(code)] \(message)")
                }
              }
            }
          }

          // Stream ended without done event.
          continuation.finish()
        } catch let error as AlanError {
          continuation.finish(throwing: error)
        } catch let urlError as URLError {
          continuation.finish(throwing: AlanError.from(urlError))
        } catch {
          continuation.finish(throwing: AlanError.networkError(message: error.localizedDescription))
        }
      }
    }
  }

  // MARK: - Subagent Execution

  // Executes a single subagent request and returns the response.
  func executeSubagent(_ request: SubagentRequest) async throws -> SubagentResponse {
    try await executeWithRetry {
      let urlRequest = try self.buildRequest(
        url: self.endpoints.subagentURL,
        body: request,
        acceptSSE: false
      )

      let (data, response) = try await self.session.data(for: urlRequest)

      guard let httpResponse = response as? HTTPURLResponse else {
        throw AlanError.invalidResponse(reason: "Not an HTTP response")
      }

      guard httpResponse.statusCode == 200 else {
        throw AlanError.serverError(
          statusCode: httpResponse.statusCode,
          message: "Subagent request failed"
        )
      }

      do {
        return try self.decoder.decode(SubagentResponse.self, from: data)
      } catch {
        throw AlanError.decodingError(context: "Failed to decode SubagentResponse: \(error)")
      }
    }
  }

  // Executes multiple subagent requests in parallel.
  func executeSubagentBatch(
    _ requests: [SubagentRequest]
  ) async -> [(SubagentRequestID, Result<SubagentResponse, Error>)] {
    await withTaskGroup(
      of: (SubagentRequestID, Result<SubagentResponse, Error>).self
    ) { group in
      for request in requests {
        group.addTask {
          do {
            let response = try await self.executeSubagent(request)
            return (request.id, .success(response))
          } catch {
            return (request.id, .failure(error))
          }
        }
      }

      var results: [(SubagentRequestID, Result<SubagentResponse, Error>)] = []
      for await result in group {
        results.append(result)
      }
      return results
    }
  }

  // MARK: - Request Building

  // Builds a URLRequest with JSON body.
  private func buildRequest<T: Encodable>(
    url: URL,
    body: T,
    acceptSSE: Bool
  ) throws -> URLRequest {
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    if acceptSSE {
      request.setValue("text/event-stream", forHTTPHeaderField: "Accept")
    } else {
      request.setValue("application/json", forHTTPHeaderField: "Accept")
    }

    do {
      request.httpBody = try encoder.encode(body)
    } catch {
      throw AlanError.decodingError(context: "Failed to encode request body: \(error)")
    }

    return request
  }

  // MARK: - Retry Logic

  // Executes an operation with retry logic for transient failures.
  private func executeWithRetry<T>(
    maxAttempts: Int = AlanEndpoints.maxRetryAttempts,
    operation: @escaping () async throws -> T
  ) async throws -> T {
    var lastError: Error?

    for attempt in 1...maxAttempts {
      do {
        return try await operation()
      } catch let error as AlanError {
        lastError = error

        // Do not retry non-retryable errors.
        guard error.isRetryable else {
          throw error
        }

        // Exponential backoff.
        if attempt < maxAttempts {
          let delay = AlanEndpoints.retryBaseDelay * pow(2.0, Double(attempt - 1))
          try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        }
      } catch {
        lastError = error

        // Exponential backoff for other errors.
        if attempt < maxAttempts {
          let delay = AlanEndpoints.retryBaseDelay * pow(2.0, Double(attempt - 1))
          try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        }
      }
    }

    throw lastError ?? AlanError.timeout(operation: "executeWithRetry")
  }
}

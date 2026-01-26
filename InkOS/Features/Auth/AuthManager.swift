//
// AuthManager.swift
// InkOS
//
// Manages user authentication via Sign in with Apple and Firebase.
// Provides user identity for Firestore access and memory persistence.
//

import AuthenticationServices
import CryptoKit
import FirebaseAuth
import Foundation

// MARK: - AuthState

// Current authentication state.
enum AuthState: Equatable {
  case unknown
  case signedOut
  case signingIn
  case signedIn(userId: String)

  var isSignedIn: Bool {
    if case .signedIn = self { return true }
    return false
  }

  var userId: String? {
    if case .signedIn(let userId) = self { return userId }
    return nil
  }
}

// MARK: - AuthError

// Errors from authentication operations.
enum AuthError: Error, LocalizedError {
  case signInCancelled
  case signInFailed(String)
  case noCredential
  case firebaseNotConfigured
  case userNotFound

  var errorDescription: String? {
    switch self {
    case .signInCancelled:
      return "Sign in was cancelled"
    case .signInFailed(let message):
      return "Sign in failed: \(message)"
    case .noCredential:
      return "No credential received"
    case .firebaseNotConfigured:
      return "Firebase is not configured"
    case .userNotFound:
      return "User not found"
    }
  }
}

// MARK: - AuthManagerProtocol

// Protocol for authentication manager.
@MainActor
protocol AuthManagerProtocol: AnyObject {
  var state: AuthState { get }
  var statePublisher: AsyncStream<AuthState> { get }

  func signInWithApple() async throws
  func signOut() throws
  func refreshAuthState()
}

// MARK: - AuthConfiguration

// Configuration for authentication mode.
enum AuthConfiguration {
  // Use this for development without Apple Developer account.
  // Set to false when you have a Developer account and want real auth.
  static let useDevelopmentMode = true

  // Test user ID for development mode.
  static let developmentUserId = "dev-test-user-001"
}

// MARK: - DevAuthManager

// Development auth manager that uses a hardcoded test user ID.
// Use this when you don't have an Apple Developer account.
@MainActor
final class DevAuthManager: AuthManagerProtocol {
  private(set) var state: AuthState = .unknown
  private var stateContinuation: AsyncStream<AuthState>.Continuation?

  var statePublisher: AsyncStream<AuthState> {
    AsyncStream { continuation in
      self.stateContinuation = continuation
      continuation.yield(self.state)
    }
  }

  init() {
    // Auto sign-in with dev user.
    state = .signedIn(userId: AuthConfiguration.developmentUserId)
  }

  func signInWithApple() async throws {
    // In dev mode, just sign in immediately with test user.
    state = .signedIn(userId: AuthConfiguration.developmentUserId)
    stateContinuation?.yield(state)
  }

  func signOut() throws {
    state = .signedOut
    stateContinuation?.yield(state)
  }

  func refreshAuthState() {
    // In dev mode, always signed in.
    state = .signedIn(userId: AuthConfiguration.developmentUserId)
    stateContinuation?.yield(state)
  }
}

// MARK: - AuthManager

// Manages Sign in with Apple and Firebase Auth integration.
@MainActor
final class AuthManager: AuthManagerProtocol {
  // Current authentication state.
  private(set) var state: AuthState = .unknown

  // Stream for state changes.
  private var stateContinuation: AsyncStream<AuthState>.Continuation?

  // Nonce for Sign in with Apple.
  private var currentNonce: String?

  // Continuation for async Sign in with Apple flow.
  private var signInContinuation: CheckedContinuation<ASAuthorizationAppleIDCredential, Error>?

  // Delegate helper for ASAuthorizationController callbacks.
  private var delegateHelper: AuthControllerDelegate?

  // State publisher.
  var statePublisher: AsyncStream<AuthState> {
    AsyncStream { continuation in
      self.stateContinuation = continuation
      continuation.yield(self.state)
    }
  }

  init() {
    refreshAuthState()
  }

  // MARK: - Sign In with Apple

  // Initiates Sign in with Apple flow.
  func signInWithApple() async throws {
    updateState(.signingIn)

    // Generate nonce for security.
    let nonce = randomNonceString()
    currentNonce = nonce

    // Create Apple ID request.
    let appleIDProvider = ASAuthorizationAppleIDProvider()
    let request = appleIDProvider.createRequest()
    request.requestedScopes = [.fullName, .email]
    request.nonce = sha256(nonce)

    // Present authorization using delegate helper.
    let credential = try await withCheckedThrowingContinuation {
      (continuation: CheckedContinuation<ASAuthorizationAppleIDCredential, Error>) in
      self.signInContinuation = continuation

      // Create delegate helper to handle callbacks.
      let helper = AuthControllerDelegate(
        onSuccess: { [weak self] credential in
          self?.signInContinuation?.resume(returning: credential)
          self?.signInContinuation = nil
        },
        onError: { [weak self] error in
          if let authError = error as? ASAuthorizationError,
            authError.code == .canceled
          {
            self?.signInContinuation?.resume(throwing: AuthError.signInCancelled)
          } else {
            self?.signInContinuation?.resume(throwing: AuthError.signInFailed(error.localizedDescription))
          }
          self?.signInContinuation = nil
          Task { @MainActor in
            self?.updateState(.signedOut)
          }
        }
      )
      self.delegateHelper = helper

      let authController = ASAuthorizationController(authorizationRequests: [request])
      authController.delegate = helper
      authController.presentationContextProvider = helper
      authController.performRequests()
    }

    // Authenticate with Firebase using Apple credential.
    try await authenticateWithFirebase(credential: credential, nonce: nonce)
  }

  // Signs out the current user.
  func signOut() throws {
    do {
      try Auth.auth().signOut()
    } catch {
      throw AuthError.signInFailed(error.localizedDescription)
    }

    updateState(.signedOut)
  }

  // Refreshes the current authentication state.
  func refreshAuthState() {
    if let user = Auth.auth().currentUser {
      updateState(.signedIn(userId: user.uid))
    } else {
      updateState(.signedOut)
    }
  }

  // MARK: - Firebase Authentication

  private func authenticateWithFirebase(
    credential: ASAuthorizationAppleIDCredential,
    nonce: String
  ) async throws {
    guard let identityToken = credential.identityToken,
      let tokenString = String(data: identityToken, encoding: .utf8)
    else {
      throw AuthError.noCredential
    }

    let oauthCredential = OAuthProvider.appleCredential(
      withIDToken: tokenString,
      rawNonce: nonce,
      fullName: credential.fullName
    )

    do {
      let result = try await Auth.auth().signIn(with: oauthCredential)
      updateState(.signedIn(userId: result.user.uid))
    } catch {
      updateState(.signedOut)
      throw AuthError.signInFailed(error.localizedDescription)
    }
  }

  // MARK: - State Management

  private func updateState(_ newState: AuthState) {
    state = newState
    stateContinuation?.yield(newState)
  }

  // MARK: - Nonce Generation

  private func randomNonceString(length: Int = 32) -> String {
    precondition(length > 0)
    var randomBytes = [UInt8](repeating: 0, count: length)
    let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
    if errorCode != errSecSuccess {
      fatalError("Unable to generate nonce: \(errorCode)")
    }

    let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
    return String(randomBytes.map { byte in charset[Int(byte) % charset.count] })
  }

  private func sha256(_ input: String) -> String {
    let inputData = Data(input.utf8)
    let hashedData = SHA256.hash(data: inputData)
    return hashedData.compactMap { String(format: "%02x", $0) }.joined()
  }
}

// MARK: - AuthControllerDelegate

// Private helper class for ASAuthorizationController delegate conformance.
// Kept private so it doesn't get exported to Objective-C bridging header.
private class AuthControllerDelegate: NSObject,
  ASAuthorizationControllerDelegate,
  ASAuthorizationControllerPresentationContextProviding
{
  // Callback when authorization succeeds.
  private let onSuccess: (ASAuthorizationAppleIDCredential) -> Void

  // Callback when authorization fails.
  private let onError: (Error) -> Void

  init(
    onSuccess: @escaping (ASAuthorizationAppleIDCredential) -> Void,
    onError: @escaping (Error) -> Void
  ) {
    self.onSuccess = onSuccess
    self.onError = onError
    super.init()
  }

  func authorizationController(
    controller: ASAuthorizationController,
    didCompleteWithAuthorization authorization: ASAuthorization
  ) {
    if let credential = authorization.credential as? ASAuthorizationAppleIDCredential {
      onSuccess(credential)
    } else {
      onError(AuthError.noCredential)
    }
  }

  func authorizationController(
    controller: ASAuthorizationController,
    didCompleteWithError error: Error
  ) {
    onError(error)
  }

  func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
    // Return the key window for presentation.
    #if os(iOS)
      return UIApplication.shared.connectedScenes
        .compactMap { $0 as? UIWindowScene }
        .flatMap { $0.windows }
        .first { $0.isKeyWindow } ?? UIWindow()
    #else
      return NSApplication.shared.keyWindow ?? NSWindow()
    #endif
  }
}

// MARK: - AuthManagerFactory

// Factory to create the appropriate auth manager based on configuration.
enum AuthManagerFactory {
  @MainActor
  static func create() -> AuthManagerProtocol {
    if AuthConfiguration.useDevelopmentMode {
      return DevAuthManager()
    } else {
      return AuthManager()
    }
  }
}

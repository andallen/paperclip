//
//  PaperClipApp.swift
//  PaperClip
//
//  Created by Andrew Allen on 12/18/25.
//

import SwiftUI

@main
struct PaperClipApp: App {
  // Tracks whether the user has completed the onboarding flow.
  @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

  var body: some Scene {
    WindowGroup {
      if hasCompletedOnboarding {
        AppRootView()
      } else {
        OnboardingView {
          hasCompletedOnboarding = true
        }
      }
    }
  }
}

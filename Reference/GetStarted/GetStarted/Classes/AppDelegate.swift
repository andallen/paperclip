// Copyright @ MyScript. All rights reserved.

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    print("MY BUNDLE ID IS: \(Bundle.main.bundleIdentifier ?? "Unknown")")
    return true
  }
}

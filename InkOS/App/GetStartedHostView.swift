import SwiftUI
import UIKit

struct GetStartedHostView: UIViewControllerRepresentable {
  func makeUIViewController(context: Context) -> UIViewController {
    let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
    return storyboard.instantiateInitialViewController() ?? UIViewController()
  }

  func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

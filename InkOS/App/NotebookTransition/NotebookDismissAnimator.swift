import UIKit

// Handles the dismissal animation for the notebook hero transition.
// Morphs a snapshot from full screen back to the source card position.
class NotebookDismissAnimator: NSObject, UIViewControllerAnimatedTransitioning {

  // MARK: - Properties

  // The target card's frame in window coordinates.
  private let targetFrame: CGRect

  // The preview image to display during the morph animation.
  private let previewImage: UIImage?

  // Corner radius of the target card.
  private let targetCornerRadius: CGFloat = 10

  // Inset to crop out the thin black line on the right edge of the canvas capture.
  // The image view extends beyond the clipped snapshot bounds to hide this edge.
  static let previewEdgeInset: CGFloat = 2

  // MARK: - Initialization

  init(targetFrame: CGRect, previewImage: UIImage?) {
    self.targetFrame = targetFrame
    self.previewImage = previewImage
    super.init()
  }

  // MARK: - UIViewControllerAnimatedTransitioning

  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return 0.38
  }

  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    guard let fromView = transitionContext.view(forKey: .from),
      let toView = transitionContext.view(forKey: .to),
      let toViewController = transitionContext.viewController(forKey: .to)
    else {
      transitionContext.completeTransition(false)
      return
    }

    let containerView = transitionContext.containerView
    let finalFrame = transitionContext.finalFrame(for: toViewController)
    let duration = transitionDuration(using: transitionContext)

    // Ensure containerView has white background for consistency.
    containerView.backgroundColor = .white

    // Add toView behind the snapshot during morph.
    toView.frame = finalFrame
    containerView.insertSubview(toView, at: 0)

    // Create blur overlay for the dashboard background. Starts fully blurred.
    let blurComponents = createBlurOverlay(frame: containerView.bounds)
    containerView.insertSubview(blurComponents.overlay, aboveSubview: toView)

    // Hide fromView immediately so it's invisible during the transition.
    fromView.alpha = 0

    // Create the snapshot view that will morph from fullscreen to card.
    // Convert targetFrame from global (window) coordinates to containerView's coordinate space.
    let snapshotView = createSnapshotView()
    snapshotView.frame = containerView.bounds

    // Manually set subview frames since autoresizingMask doesn't apply when
    // manually setting frame (only during layout passes).
    // Extend the image view beyond the right edge to crop out the black line.
    let inset = Self.previewEdgeInset
    for subview in snapshotView.subviews {
      subview.frame = snapshotView.bounds.inset(
        by: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -inset)
      )
    }

    containerView.addSubview(snapshotView)

    let convertedTargetFrame = containerView.convert(targetFrame, from: nil)

    // Animate blur from full to none as the snapshot contracts.
    animateBlurOut(animator: blurComponents.animator, duration: duration)

    // Animate the snapshot morphing back to the card position.
    UIView.animate(
      withDuration: duration,
      delay: 0,
      usingSpringWithDamping: 0.88,
      initialSpringVelocity: 0.1,
      options: [.curveEaseOut]
    ) {
      snapshotView.frame = convertedTargetFrame
      snapshotView.layer.cornerRadius = self.targetCornerRadius

      // Manually resize all subviews to match the animating snapshot frame.
      // autoresizingMask doesn't apply during manual frame animations.
      // Extend the image view beyond the right edge to maintain the inset.
      for subview in snapshotView.subviews {
        subview.frame = snapshotView.bounds.inset(
          by: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -inset)
        )
      }
    }

    // Complete the transition after animations finish.
    DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
      // Clean up transition views.
      snapshotView.removeFromSuperview()
      blurComponents.overlay.removeFromSuperview()

      // Stop the blur animator and release resources.
      blurComponents.animator.stopAnimation(true)

      transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
    }
  }

  // MARK: - Helpers

  // Creates a blur overlay with an animator for controlling blur intensity.
  // The overlay starts fully blurred so it can animate to clear.
  private func createBlurOverlay(frame: CGRect) -> (overlay: UIVisualEffectView, animator: UIViewPropertyAnimator) {
    // Create a visual effect view without an effect initially.
    let blurView = UIVisualEffectView(effect: nil)
    blurView.frame = frame
    blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

    // Create an animator that will apply blur when its fractionComplete increases.
    let animator = UIViewPropertyAnimator(duration: 1, curve: .linear) {
      blurView.effect = UIBlurEffect(style: .regular)
    }
    // Start fully blurred by setting fractionComplete to 1.
    animator.fractionComplete = 1
    // Pause the animator so fractionComplete can be set manually.
    animator.pausesOnCompletion = true

    return (blurView, animator)
  }

  // Animates the blur overlay from blurred to clear.
  private func animateBlurOut(animator: UIViewPropertyAnimator, duration: TimeInterval) {
    // Animate the blur fraction from 1 to 0 over most of the transition.
    let blurDuration = duration * 0.85
    let startTime = CACurrentMediaTime()

    // Use a display link for smooth blur animation.
    let displayLink = CADisplayLink(target: BlurAnimationHelper(
      animator: animator,
      startTime: startTime,
      duration: blurDuration,
      fromValue: 1,
      toValue: 0
    ), selector: #selector(BlurAnimationHelper.update))
    displayLink.add(to: .main, forMode: .common)
  }

  // Creates the snapshot view used during the morph animation.
  private func createSnapshotView() -> UIView {
    let snapshotView = UIView()
    snapshotView.backgroundColor = .white
    snapshotView.clipsToBounds = true
    snapshotView.layer.cornerRadius = 0

    // Add the preview image if available.
    if let previewImage = previewImage {
      let imageView = UIImageView(image: previewImage)
      imageView.contentMode = .scaleAspectFill
      imageView.clipsToBounds = true
      imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
      imageView.frame = snapshotView.bounds
      snapshotView.addSubview(imageView)
    }

    // Add a subtle shadow.
    snapshotView.layer.shadowColor = UIColor.black.cgColor
    snapshotView.layer.shadowOpacity = 0.25
    snapshotView.layer.shadowRadius = 16
    snapshotView.layer.shadowOffset = CGSize(width: 0, height: 8)

    return snapshotView
  }
}

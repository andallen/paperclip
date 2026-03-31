import SwiftUI
import UIKit

// Shared UI components used across multiple features.

// MARK: - Liquid Glass Effects

// Style variants for liquid glass effects.
// Use these presets for consistent glass appearance across the app.
enum LiquidGlassStyle {
  // Standard glass for overlays, panels, and cards.
  // Non-interactive - no shimmer on tap.
  case regular

  // Interactive glass that responds to touch with shimmer effect.
  // Use for buttons and tappable elements.
  case interactive

  // Clear glass with more transparency.
  // Use for subtle floating elements that shouldn't dominate visually.
  case clear

}

// View modifier that applies a liquid glass background effect.
// Uses iOS 26 glassEffect with ultraThinMaterial fallback.
private struct LiquidGlassBackgroundModifier: ViewModifier {
  let cornerRadius: CGFloat
  let style: LiquidGlassStyle

  func body(content: Content) -> some View {
    if #available(iOS 26.0, *) {
      content
        .background(
          RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(Color.clear)
            .glassEffect(glassForStyle, in: .rect(cornerRadius: cornerRadius))
        )
    } else {
      content
        .background(
          .ultraThinMaterial,
          in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        )
    }
  }

  @available(iOS 26.0, *)
  private var glassForStyle: Glass {
    switch style {
    case .regular:
      return .regular
    case .interactive:
      return .regular.interactive()
    case .clear:
      return .clear
    }
  }
}

// View modifier that applies liquid glass directly to the view shape.
// Use when the view itself should be the glass element, not just have a background.
private struct LiquidGlassModifier: ViewModifier {
  let cornerRadius: CGFloat
  let style: LiquidGlassStyle

  func body(content: Content) -> some View {
    if #available(iOS 26.0, *) {
      content
        .glassEffect(glassForStyle, in: .rect(cornerRadius: cornerRadius))
    } else {
      content
        .background(
          .ultraThinMaterial,
          in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        )
    }
  }

  @available(iOS 26.0, *)
  private var glassForStyle: Glass {
    switch style {
    case .regular:
      return .regular
    case .interactive:
      return .regular.interactive()
    case .clear:
      return .clear
    }
  }
}

// Convenience view modifiers for liquid glass effects.
extension View {
  // Applies a liquid glass background with the specified corner radius and style.
  // Default style is .regular (non-interactive).
  func liquidGlassBackground(
    cornerRadius: CGFloat,
    style: LiquidGlassStyle = .regular
  ) -> some View {
    modifier(LiquidGlassBackgroundModifier(cornerRadius: cornerRadius, style: style))
  }

  // Applies liquid glass directly to the view.
  // Use when the view should be the glass element.
  func liquidGlass(
    cornerRadius: CGFloat,
    style: LiquidGlassStyle = .regular
  ) -> some View {
    modifier(LiquidGlassModifier(cornerRadius: cornerRadius, style: style))
  }

  // Legacy compatibility - applies a glass background effect.
  // Prefer liquidGlassBackground for new code.
  func glassBackground(cornerRadius: CGFloat) -> some View {
    liquidGlassBackground(cornerRadius: cornerRadius, style: .interactive)
  }
}

// MARK: - UIKit Liquid Glass Helpers

// Applies liquid glass effect to a UIVisualEffectView.
// Use this in UIKit view controllers for consistent glass appearance.
func applyLiquidGlassEffect(
  to visualEffectView: UIVisualEffectView,
  style: LiquidGlassStyle = .regular
) {
  if #available(iOS 26.0, *) {
    let glassEffect = UIGlassEffect(style: .regular)
    switch style {
    case .regular:
      glassEffect.isInteractive = false
    case .interactive:
      glassEffect.isInteractive = true
    case .clear:
      glassEffect.isInteractive = false
    }
    visualEffectView.effect = glassEffect
  } else {
    visualEffectView.effect = UIBlurEffect(style: .systemThinMaterial)
  }
}

// Creates a configured UIVisualEffectView with liquid glass effect.
func makeLiquidGlassView(
  cornerRadius: CGFloat,
  style: LiquidGlassStyle = .regular
) -> UIVisualEffectView {
  let glassView = UIVisualEffectView()
  glassView.layer.cornerRadius = cornerRadius
  glassView.layer.cornerCurve = .continuous
  glassView.clipsToBounds = true
  applyLiquidGlassEffect(to: glassView, style: style)
  return glassView
}

// Shared color definitions.
extension Color {
  static let rule = Color.black.opacity(0.10)
  static let separator = Color.black.opacity(0.14)

  // Matches the navigation bar icon tint.
  static let offBlack = Color(red: 0.20, green: 0.20, blue: 0.20)

  static let ink = Color.black.opacity(0.88)
  static let inkSubtle = Color.black.opacity(0.62)
  static let inkFaint = Color.black.opacity(0.40)
}

// MARK: - Animated Blur View

// UIViewRepresentable that wraps a UIVisualEffectView for smooth blur animation.
// Uses UIViewPropertyAnimator with CADisplayLink for smooth interpolation.
// Animates smoothly between clear (0) and fully blurred (1).
struct AnimatedBlurView: UIViewRepresentable {
  // Target blur intensity from 0 (clear) to 1 (full blur).
  let blurFraction: CGFloat
  // Duration for blur animation.
  let animationDuration: TimeInterval
  // Style of blur effect to use.
  let style: UIBlurEffect.Style

  init(
    blurFraction: CGFloat,
    animationDuration: TimeInterval = 0.35,
    style: UIBlurEffect.Style = .regular
  ) {
    self.blurFraction = blurFraction
    self.animationDuration = animationDuration
    self.style = style
  }

  func makeUIView(context: Context) -> UIVisualEffectView {
    let blurView = UIVisualEffectView(effect: nil)
    // Create an animator that applies blur when its fractionComplete increases.
    let animator = UIViewPropertyAnimator(duration: 1, curve: .linear) {
      blurView.effect = UIBlurEffect(style: self.style)
    }
    animator.pausesOnCompletion = true
    animator.fractionComplete = 0
    context.coordinator.animator = animator
    context.coordinator.currentFraction = 0
    // Start animation to target if not zero.
    if blurFraction > 0 {
      context.coordinator.animateTo(blurFraction, duration: animationDuration)
    }
    return blurView
  }

  func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
    // Animate to new target fraction if different from current target.
    let target = blurFraction
    if abs(context.coordinator.targetFraction - target) > 0.001 {
      context.coordinator.animateTo(target, duration: animationDuration)
    }
  }

  func makeCoordinator() -> Coordinator {
    Coordinator()
  }

  class Coordinator {
    var animator: UIViewPropertyAnimator?
    var displayLink: CADisplayLink?
    var currentFraction: CGFloat = 0
    var targetFraction: CGFloat = 0
    var animationStartTime: CFTimeInterval = 0
    var animationStartFraction: CGFloat = 0
    var animationDuration: TimeInterval = 0.35

    // Starts a smooth animation from current fraction to target.
    func animateTo(_ target: CGFloat, duration: TimeInterval) {
      targetFraction = target
      animationStartFraction = currentFraction
      animationDuration = duration
      animationStartTime = CACurrentMediaTime()

      // Cancel existing display link.
      displayLink?.invalidate()

      // Create new display link for animation.
      let link = CADisplayLink(target: self, selector: #selector(updateAnimation))
      link.add(to: .main, forMode: .common)
      displayLink = link
    }

    @objc func updateAnimation() {
      let elapsed = CACurrentMediaTime() - animationStartTime
      var progress = min(1.0, elapsed / animationDuration)

      // Apply ease-out cubic for smooth deceleration.
      progress = easeOutCubic(progress)

      // Interpolate between start and target.
      let newFraction = animationStartFraction + (targetFraction - animationStartFraction) * progress
      currentFraction = newFraction
      animator?.fractionComplete = newFraction

      // Stop animation when complete.
      if progress >= 1.0 {
        displayLink?.invalidate()
        displayLink = nil
      }
    }

    // Ease out cubic for a smooth deceleration.
    private func easeOutCubic(_ t: CGFloat) -> CGFloat {
      let adjusted = t - 1
      return adjusted * adjusted * adjusted + 1
    }

    deinit {
      displayLink?.invalidate()
      animator?.stopAnimation(true)
    }
  }
}

// MARK: - Rounded Corner Shape

// Rounded rectangle with individually rounded corners.
struct RoundedCornerShape: Shape {
  struct Corner: OptionSet {
    let rawValue: Int

    static let topLeft = Corner(rawValue: 1 << 0)
    static let topRight = Corner(rawValue: 1 << 1)
    static let bottomLeft = Corner(rawValue: 1 << 2)
    static let bottomRight = Corner(rawValue: 1 << 3)
  }

  var radius: CGFloat
  let corners: Corner

  var animatableData: CGFloat {
    get { radius }
    set { radius = newValue }
  }

  func path(in rect: CGRect) -> SwiftUI.Path {
    let clampedRadius = min(radius, min(rect.width, rect.height) * 0.5)
    let topLeft = corners.contains(.topLeft) ? clampedRadius : 0
    let topRight = corners.contains(.topRight) ? clampedRadius : 0
    let bottomLeft = corners.contains(.bottomLeft) ? clampedRadius : 0
    let bottomRight = corners.contains(.bottomRight) ? clampedRadius : 0

    var path = SwiftUI.Path()
    path.move(to: CGPoint(x: rect.minX + topLeft, y: rect.minY))
    path.addLine(to: CGPoint(x: rect.maxX - topRight, y: rect.minY))
    if topRight > 0 {
      path.addArc(
        center: CGPoint(x: rect.maxX - topRight, y: rect.minY + topRight),
        radius: topRight,
        startAngle: .degrees(-90),
        endAngle: .degrees(0),
        clockwise: false
      )
    }
    path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - bottomRight))
    if bottomRight > 0 {
      path.addArc(
        center: CGPoint(x: rect.maxX - bottomRight, y: rect.maxY - bottomRight),
        radius: bottomRight,
        startAngle: .degrees(0),
        endAngle: .degrees(90),
        clockwise: false
      )
    }
    path.addLine(to: CGPoint(x: rect.minX + bottomLeft, y: rect.maxY))
    if bottomLeft > 0 {
      path.addArc(
        center: CGPoint(x: rect.minX + bottomLeft, y: rect.maxY - bottomLeft),
        radius: bottomLeft,
        startAngle: .degrees(90),
        endAngle: .degrees(180),
        clockwise: false
      )
    }
    path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + topLeft))
    if topLeft > 0 {
      path.addArc(
        center: CGPoint(x: rect.minX + topLeft, y: rect.minY + topLeft),
        radius: topLeft,
        startAngle: .degrees(180),
        endAngle: .degrees(270),
        clockwise: false
      )
    }
    path.closeSubpath()
    return path
  }
}


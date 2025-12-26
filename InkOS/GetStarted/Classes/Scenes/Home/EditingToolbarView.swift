import UIKit

final class EditingToolbarView: UIView {
  // Notifies the host when undo is tapped.
  var undoTapped: (() -> Void)?
  // Notifies the host when redo is tapped.
  var redoTapped: (() -> Void)?
  // Notifies the host when clear is tapped.
  var clearTapped: (() -> Void)?

  // Defines the shared tint used for the toolbar icons.
  private let accentColor: UIColor
  // Sets the toolbar height to align with navigation bar sizing.
  private let toolbarHeight: CGFloat = 44
  // Hosts the icons inside a real toolbar.
  private let toolbar = UIToolbar()
  // Stores the width constraint so it can animate in and out.
  private var widthConstraint: NSLayoutConstraint?
  // Tracks whether the toolbar is collapsed.
  private var isCollapsed = false
  // Stores the undo item.
  private lazy var undoItem = makeBarButtonItem(
    imageName: "Undo",
    systemImageName: "arrow.uturn.backward",
    accessibilityLabel: "Undo",
    action: #selector(undoPressed)
  )
  // Stores the redo item.
  private lazy var redoItem = makeBarButtonItem(
    imageName: "Redo",
    systemImageName: "arrow.uturn.forward",
    accessibilityLabel: "Redo",
    action: #selector(redoPressed)
  )
  // Stores the clear item.
  private lazy var clearItem = makeBarButtonItem(
    imageName: "Clear",
    systemImageName: "trash",
    accessibilityLabel: "Clear",
    action: #selector(clearPressed)
  )

  init(accentColor: UIColor) {
    self.accentColor = accentColor
    super.init(frame: .zero)
    configureView()
  }

  required init?(coder: NSCoder) {
    self.accentColor = UIColor.label
    super.init(coder: coder)
    configureView()
  }

  // Computes the width for the fixed toolbar size.
  private var toolbarWidth: CGFloat {
    toolbar.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: toolbarHeight))
      .width
  }

  // The fully collapsed width hides the toolbar entirely.
  private var collapsedWidth: CGFloat { 0 }

  // Builds the view hierarchy and initial layout.
  private func configureView() {
    translatesAutoresizingMaskIntoConstraints = false
    backgroundColor = UIColor.clear
    layer.cornerRadius = toolbarHeight / 2
    layer.masksToBounds = true

    toolbar.translatesAutoresizingMaskIntoConstraints = false
    toolbar.isTranslucent = true
    toolbar.tintColor = accentColor
    toolbar.backgroundColor = .clear
    toolbar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
    toolbar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .compact)
    toolbar.setShadowImage(UIImage(), forToolbarPosition: .any)
    toolbar.items = makeToolbarItems()
    toolbar.sizeToFit()

    addSubview(toolbar)

    // Anchors the toolbar to fill the container.
    toolbar.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
    toolbar.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    toolbar.topAnchor.constraint(equalTo: topAnchor).isActive = true
    toolbar.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

    // Locks the size to prevent clipping inside the navigation layout.
    heightAnchor.constraint(equalToConstant: toolbarHeight).isActive = true
    let widthConstraint = widthAnchor.constraint(equalToConstant: toolbarWidth)
    widthConstraint.isActive = true
    self.widthConstraint = widthConstraint

    setCollapsed(false, animated: false)
  }

  // Creates bar button items that mimic the top bar style.
  private func makeBarButtonItem(
    imageName: String,
    systemImageName: String,
    accessibilityLabel: String,
    action: Selector
  ) -> UIBarButtonItem {
    let namedImage = UIImage(named: imageName)
    let systemImage = UIImage(systemName: systemImageName)
    let image = namedImage ?? systemImage
    let barButtonItem = UIBarButtonItem(
      image: image?.withRenderingMode(.alwaysTemplate),
      style: .plain,
      target: self,
      action: action
    )
    barButtonItem.accessibilityLabel = accessibilityLabel
    barButtonItem.tintColor = accentColor
    return barButtonItem
  }

  // Builds the toolbar with standard Apple spacing between icons.
  private func makeToolbarItems() -> [UIBarButtonItem] {
    let spacer = makeFixedSpace()
    return [undoItem, spacer, redoItem, spacer, clearItem]
  }

  // Creates a consistent fixed space item so the icons do not crowd each other.
  private func makeFixedSpace() -> UIBarButtonItem {
    let spacer = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
    spacer.width = 16
    return spacer
  }

  // Expands or collapses the toolbar with optional animation.
  func setCollapsed(_ collapsed: Bool, animated: Bool) {
    guard collapsed != isCollapsed else { return }
    isCollapsed = collapsed
    superview?.layoutIfNeeded()
    if collapsed {
      prepareForCollapse()
    } else {
      prepareForExpand()
    }
    updateWidthForState(collapsed: collapsed)

    let targetAlpha: CGFloat = collapsed ? 0 : 1
    let animations = { [weak self] in
      guard let self = self else { return }
      self.superview?.layoutIfNeeded()
      self.toolbar.alpha = targetAlpha
    }

    let completion: (Bool) -> Void = { [weak self] _ in
      guard let self = self else { return }
      if collapsed {
        self.toolbar.isHidden = true
      }
    }

    if animated {
      UIView.animate(
        withDuration: 0.22,
        delay: 0,
        options: [.curveEaseInOut],
        animations: animations,
        completion: completion
      )
    } else {
      animations()
      completion(true)
    }
  }

  // Enables taps and accessibility for the toolbar buttons when expanding.
  private func prepareForExpand() {
    toolbar.isHidden = false
    toolbar.alpha = 0
    toolbar.items?.forEach { item in
      item.isEnabled = true
    }
    toolbar.isUserInteractionEnabled = true
  }

  // Disables taps and accessibility for the toolbar buttons when collapsing.
  private func prepareForCollapse() {
    toolbar.items?.forEach { item in
      item.isEnabled = false
    }
    toolbar.isUserInteractionEnabled = false
  }

  // Updates the width constraint to match the collapsed or expanded state.
  private func updateWidthForState(collapsed: Bool) {
    widthConstraint?.constant = collapsed ? collapsedWidth : toolbarWidth
  }

  // Handles undo taps.
  @objc private func undoPressed() {
    undoTapped?()
  }

  // Handles redo taps.
  @objc private func redoPressed() {
    redoTapped?()
  }

  // Handles clear taps.
  @objc private func clearPressed() {
    clearTapped?()
  }
}

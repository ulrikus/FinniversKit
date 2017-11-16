//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

public protocol ToastViewDelegate: NSObjectProtocol {
    func didTapActionButton(button: UIButton, in toastView: ToastView)
    func didTap(toastView: ToastView)
    func didSwipeDown(on toastView: ToastView)
}

public extension ToastViewDelegate {
    func didTapActionButton(button: UIButton, in toastView: ToastView) {
        // Default nothing happens
    }

    func didTap(toastView: ToastView) {
        // Default nothing happens
    }

    func didSwipeDown(on toastView: ToastView) {
        toastView.dismissToast()
    }
}

public enum ToastType {
    case success
    case sucesssImage
    case error
    case successButton
    case errorButton

    var color: UIColor {
        switch self {
        case .error, .errorButton: return .salmon
        default: return .mint
        }
    }

    var imageBackgroundColor: UIColor {
        switch self {
        case .sucesssImage: return .milk
        default: return .clear
        }
    }
}

public class ToastView: UIView {

    // MARK: - Internal properties

    private let animationDuration: Double = 0.3
    private let imageSizeAllowedMin = CGSize(width: 18, height: 18)
    private let imageSizeAllowedMax = CGSize(width: 26, height: 26)

    private lazy var messageTitle: Label = {
        let label = Label()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.style = .body(.licorice)
        return label
    }()

    private lazy var actionButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.primaryBlue, for: .normal)
        button.layer.masksToBounds = true
        button.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 751), for: UILayoutConstraintAxis.horizontal)
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        return button
    }()

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private var imageThumbnail: UIImage {
        guard let model = model else {
            return UIImage(frameworkImageNamed: "success")!
        }

        switch model.type {
        case .error, .errorButton:
            return UIImage(frameworkImageNamed: "error")!
        case .sucesssImage:
            if let image = model.imageThumbnail {
                return image
            } else {
                return UIImage(frameworkImageNamed: "NoImage")!
            }
        default:
            return UIImage(frameworkImageNamed: "success")!
        }
    }

    private weak var delegate: ToastViewDelegate?

    // MARK: - External properties

    // MARK: - Setup

    public init(frame: CGRect = .zero, delegate: ToastViewDelegate) {
        super.init(frame: frame)

        self.delegate = delegate

        setup()
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        isAccessibilityElement = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction))
        swipeGesture.direction = .down
        gestureRecognizers = [tapGesture, swipeGesture]

        addSubview(imageView)
        addSubview(messageTitle)
        addSubview(actionButton)
    }

    // MARK: - Superclass Overrides

    // MARK: - Layout

    public override func layoutSubviews() {
        super.layoutSubviews()

        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: CGFloat.mediumLargeSpacing),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            imageView.widthAnchor.constraint(lessThanOrEqualToConstant: imageSizeAllowedMax.width),
            imageView.heightAnchor.constraint(lessThanOrEqualToConstant: imageSizeAllowedMax.height),
            imageView.widthAnchor.constraint(greaterThanOrEqualToConstant: imageSizeAllowedMin.width),
            imageView.heightAnchor.constraint(greaterThanOrEqualToConstant: imageSizeAllowedMin.height),

            messageTitle.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: CGFloat.mediumLargeSpacing),
            messageTitle.topAnchor.constraint(equalTo: topAnchor, constant: CGFloat.mediumLargeSpacing),
            messageTitle.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -CGFloat.mediumLargeSpacing),
        ])

        if let model = model, model.actionButtonTitle != nil {
            actionButton.isHidden = false

            NSLayoutConstraint.activate([
                messageTitle.trailingAnchor.constraint(lessThanOrEqualTo: actionButton.leadingAnchor, constant: -CGFloat.mediumLargeSpacing),
                actionButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -CGFloat.mediumLargeSpacing),
                actionButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            ])
        } else {
            actionButton.isHidden = true
            messageTitle.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -CGFloat.mediumLargeSpacing).isActive = true
        }
    }

    // MARK: - Dependency injection

    public var model: ToastModel? {
        didSet {
            messageTitle.text = model?.messageTitle
            accessibilityLabel = model?.accessibilityLabel
            backgroundColor = model?.type.color
            actionButton.setTitle(model?.actionButtonTitle, for: .normal)
            imageView.backgroundColor = model?.type.imageBackgroundColor
            imageView.image = imageThumbnail
        }
    }

    // MARK: - Actions

    @objc private func buttonAction() {
        delegate?.didTapActionButton(button: actionButton, in: self)
    }

    @objc private func tapAction() {
        delegate?.didTap(toastView: self)
    }

    @objc private func swipeAction() {
        delegate?.didSwipeDown(on: self)
    }

    public func presentFromBottom(view: UIView, animateOffset: CGFloat, timeOut: Double? = nil) {
        setupToastConstraint(for: view)

        UIView.animate(withDuration: animationDuration, delay: 0, options: .curveEaseInOut, animations: {
            self.transform = self.transform.translatedBy(x: 0, y: -(self.frame.height + animateOffset))
        })
        if let timeOut = timeOut {
            dismissToast(after: timeOut)
        }
    }

    public func dismissToast(after delay: Double = 0.0) {
        // Uses asyncAfter instead of animate delay because then it can be dismissed by swipe before the timeout if needed
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delay) {
            UIView.animate(withDuration: self.animationDuration, delay: 0, options: .curveEaseInOut, animations: {
                self.transform = CGAffineTransform.identity
            }) { _ in
                self.removeFromSuperview()
            }
        }
    }

    private func setupToastConstraint(for view: UIView) {
        view.addSubview(self)

        translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        view.layoutIfNeeded()
    }
}

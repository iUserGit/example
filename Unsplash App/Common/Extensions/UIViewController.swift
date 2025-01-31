import UIKit
import RIBs
import SwiftMessages

public extension UIViewController {
    enum Position {
        case top
        case bottom
    }

    struct RetryAction {
        public let buttonTitle: String
        public let buttonAction: () -> Void
        public init(buttonTitle: String, buttonAction: @escaping (() -> Void)) {
            self.buttonTitle = buttonTitle
            self.buttonAction = buttonAction
        }
    }
    
    var topScreenSafeArea: UIEdgeInsets {
            let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
            return keyWindow?.safeAreaInsets ?? .zero
    }

    
    func hapticFeedback() {
        hapticFeedbackStyle()
    }
    
    func endEditing() {
        view.endEditing(true)
    }
    
    func hapticFeedbackStyle(style: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
        let impactFeedbackGenerator: UIImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: style)
        impactFeedbackGenerator.prepare()
        impactFeedbackGenerator.impactOccurred()
    }
}

public protocol Presentable_ext: Presentable {
    func startLoading()
    func stopLoading()
    func hapticFeedback()
    func willResignActive()
    func endEditing()
}
    
@objc extension UIViewController {
    public func updateColorSubscribe() {
        guard updateColorSchemeObserver == nil else {
            return
        }
        updateColorSchemeObserver = NotificationCenter.default.addObserver(forName: .colorSchemeWasChanged, object: nil, queue: .main) { [weak self] _ in
            guard let self = self else {
                return
            }
            self.setNeedsStatusBarAppearanceUpdate()
            self.updateColor()
        }
    }
    
    public func updateColorUnsubscribe() {
        if let observer = updateColorSchemeObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    open func updateColor() { }
    
    public func topPresentedVC(for vc: UIViewController) -> UIViewController {
        if let vc = vc.presentedViewController {
            return topPresentedVC(for: vc)
        }
        return vc
    }
    
    @nonobjc
    func displayNotification(title: String, message: String, iconText: String = "👋", position: Position = .top, retry: RetryAction? = nil, duration: TimeInterval? = 5, topOffset: CGFloat = 0) {
   
        display(id: "info-notification", iconText: iconText, iconImage: nil, title: title, message: message, position: position, retry: retry, duration: duration, topOffset: topOffset)
    }

    @nonobjc
    func displaySuccess(title: String, message: String, position: Position = .top, retry: RetryAction? = nil, duration: TimeInterval? = 5, topOffset: CGFloat = 0) {
        display(id: nil, iconText: nil, iconImage: UIImage(systemName: "xmark"), title: title, message: message, position: position, retry: retry, duration: duration, topOffset: topOffset)
    }

    @nonobjc
    func displayError(title: String, message: String, position: Position = .top, retry: RetryAction? = nil, duration: TimeInterval? = 5, topOffset: CGFloat = 0) {
        display(id: nil, iconText: "✗", iconImage: nil, title: title, message: message, position: position, retry: retry, duration: duration, topOffset:   topOffset)
    }
    
    func hideAllMessages() {
        SwiftMessages.hideAll()
    }
    
    
    @nonobjc
    private func display(id: String?, iconText: String?, iconImage: UIImage?, title: String, message: String, position: Position = .bottom, retry: RetryAction? = nil, duration: TimeInterval?, topOffset: CGFloat) {
        var config = SwiftMessages.Config()
        
        var topOffset = topOffset
        
        switch position {
        case .top:
            config.presentationStyle = .top
        case .bottom:
            config.presentationStyle = .bottom
        }

        // Disable the default auto-hiding behavior.
        config.duration = .forever
        if let duration = duration {
            config.duration = .seconds(seconds: duration)
        }

        config.interactiveHide = true

        SwiftMessages.show(config: config) {
            let view = MessageView.viewFromNib(layout: .cardView)
            view.id = id ?? UUID().uuidString
            
            view.configureContent(title: title, body: message)
            view.configureTheme(backgroundColor: .clear, foregroundColor: ColorScheme.current.text, iconImage: iconImage, iconText: iconText)
            
            
            let borderView = UIView()
            view.backgroundView.addSubview(borderView)
            borderView.isUserInteractionEnabled = false
            borderView.backgroundColor = ColorScheme.current.background
//            borderView.borderColor = ColorScheme.current.active.withAlphaComponent(0.5)
            borderView.layer.borderWidth = 1
            borderView.layer.cornerRadius = 12
            
            borderView.snp.makeConstraints { make in
                make.edges.equalToSuperview().inset(UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1))
            }
            
            view.clipsToBounds = true
            view.tapHandler = { _ in SwiftMessages.hide(id: view.id) }

            view.iconLabel?.font = UIFont.boldSystemFont(ofSize: 12)
            view.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
            view.bodyLabel?.font = UIFont.boldSystemFont(ofSize: 12)

            if let action = retry {
                view.button?.setTitle(action.buttonTitle, for: .normal)
                view.buttonTapHandler = { _ in
                    SwiftMessages.hide(id: view.id)
                    // execute action
                    action.buttonAction()
                }
            } else {
                view.button?.isHidden = true
            }
            
            view.backgroundView.sendSubviewToBack(borderView)
            return view
        }
    }
}

fileprivate extension UIViewController {
    private static let associationUpdateColorSchemeObserver = ObjectAssociation<NSObjectProtocol>()

    var updateColorSchemeObserver: NSObjectProtocol? {
        get { return UIViewController.associationUpdateColorSchemeObserver[self] }
        set { UIViewController.associationUpdateColorSchemeObserver[self] = newValue }
    }
}

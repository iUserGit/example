import UIKit

@objc extension UIView {
    public func updateColorSubscribe() {
        guard updateColorSchemeObserver == nil else {
            return
        }
        updateColorSchemeObserver = NotificationCenter.default.addObserver(forName: .colorSchemeWasChanged, object: nil, queue: .main) { [weak self] _ in
            guard let self = self else {
                return
            }
            self.updateColor()
        }
    }
    
    public func updateColorUnsubscribe() {
            if let observer = self.updateColorSchemeObserver {
                NotificationCenter.default.removeObserver(observer)
            }
    }
    open func updateColor() {}
}


public extension UIView {
    private static let associationUpdateColorSchemeObserver = ObjectAssociation<NSObjectProtocol>()

    var updateColorSchemeObserver: NSObjectProtocol? {
        get { return UIView.associationUpdateColorSchemeObserver[self] }
        set { UIView.associationUpdateColorSchemeObserver[self] = newValue }
    }
}

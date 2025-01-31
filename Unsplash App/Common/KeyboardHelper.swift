import Foundation
import UIKit

public class KeyboardHelper {

    public var willShowKeyboard: ((_ value: CGFloat, _ duration: TimeInterval) -> Void)?
    public var willHideKeyBoard: ((_ duration: TimeInterval) -> Void)?
    
    public init() { }
    
    public func start() {
        setupKeyboardNotifications()
    }
    
    public func stop() {
        removeKeyboardNotifications()
    }
    
    private func setupKeyboardNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillChange),
                                               name: UIResponder.keyboardWillChangeFrameNotification,
                                               object: nil)
        
    }

    private func removeKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func keyboardWillChange(sender: NSNotification) {
        guard let i = sender.userInfo, let _ = (i[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height else {
            return
        }
        
        _ = (i[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let _: TimeInterval = (i[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0.25
        
    }
    
    @objc private func keyboardWillShow(sender: NSNotification) {
        guard let i = sender.userInfo, let k = (i[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height else {
            return
        }
        let s: TimeInterval = (i[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0.25
        willShowKeyboard?(k, s)
    }

    @objc private func keyboardWillHide(sender: NSNotification) {
        let info = sender.userInfo
        let s: TimeInterval = (info?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0.25
       
        willHideKeyBoard?(s)
    }
    
    deinit {
        stop()
    }
}

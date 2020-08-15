//
//  UIViewController+Keyboard.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 13/07/2017.
//  Copyright © 2017 Pavel Pronin. All rights reserved.
//

import Foundation
import ObjectiveC

/**
 Keyboard state
 - ActiveWithHeight: Keyboard is visible with provided height
 - Hidden: Keyboard is hidden
 */
enum KeyboardState: Equatable {
    case activeWithHeight(CGFloat)
    case hidden
}

/**
 Keyboard delegate
 */
protocol KeyboardStateDelegate: class {

    /**
     Notifies the receiver that the keyboard will show or hide with specified parameters. This method is called before keyboard animation.
     
     - parameter state: Keyboard state
     */
    func keyboardWillTransition(_ state: KeyboardState)

    /**
     Keyboard animation. This method is called inside `UIView` animation block with the same animation parameters as keyboard animation.
     
     - parameter state: Keyboard state
     */
    func keyboardTransitionAnimation(_ state: KeyboardState)

    /**
     Notifies the receiver that the keyboard animation finished. This method is called after keyboard animation.
     
     - parameter state: Keyboard state
     */
    func keyboardDidTransition(_ state: KeyboardState)
}

// MARK: - Keyboardy
extension UIViewController {

    // MARK: Public

    /// Current keyboard state
    var keyboardState: KeyboardState {
        return keyboardHeight > 0 ? .activeWithHeight(keyboardHeight) : .hidden
    }

    /**
     Register for `UIKeyboardWillShowNotification` and `UIKeyboardWillHideNotification` notifications.
     
     - parameter keyboardStateDelegate: Keyboard state delegate
     :discussion: It is recommended to call this method in `viewWillAppear:`
     */
    func registerForKeyboardNotifications(_ keyboardStateDelegate: KeyboardStateDelegate) {
        self.keyboardStateDelegate = keyboardStateDelegate

        let defaultCenter = NotificationCenter.default
        defaultCenter.addObserver(self,
                                  selector: #selector(UIViewController.keyboardWillShow(_:)),
                                  name: UIResponder.keyboardWillShowNotification,
                                  object: nil)
        defaultCenter.addObserver(self,
                                  selector: #selector(UIViewController.keyboardWillHide(_:)),
                                  name: UIResponder.keyboardWillHideNotification,
                                  object: nil)
    }

    /**
     Unregister from `UIKeyboardWillShowNotification` and `UIKeyboardWillHideNotification` notifications.
     
     :discussion: It is recommended to call this method in `viewWillDisappear:`
     */
    func unregisterFromKeyboardNotifications() {
        self.keyboardStateDelegate = nil

        let defaultCenter = NotificationCenter.default
        defaultCenter.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        defaultCenter.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    // MARK: Private

    /// Handler for `UIKeyboardWillShowNotification`
    @objc
    private dynamic func keyboardWillShow(_ notificaion: Notification) {
        if let userInfo = notificaion.userInfo,
            let rect = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let duration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue,
            let curve = (userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber)?.intValue {

            keyboardHeight = rect.height
            keyboardAnimationToState(.activeWithHeight(keyboardHeight), duration: duration, curve: UIView.AnimationCurve(rawValue: curve)!)

        }
    }

    /// Handler for `UIKeyboardWillHideNotification`
    @objc
    private dynamic func keyboardWillHide(_ notificaion: Notification) {
        if let userInfo = notificaion.userInfo,
            let duration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue,
            let curve = (userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber)?.intValue {

            keyboardHeight = 0.0
            keyboardAnimationToState(.hidden, duration: duration, curve: UIView.AnimationCurve(rawValue: curve)!)
        }
    }

    /// Keyboard animation
    private func keyboardAnimationToState(_ state: KeyboardState, duration: TimeInterval, curve: UIView.AnimationCurve) {
        keyboardStateDelegate?.keyboardWillTransition(state)

        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(duration)
        UIView.setAnimationCurve(curve)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDelegate(self)
        UIView.setAnimationDidStop(#selector(UIViewController.keyboardAnimationDidStop(_:finished:context:)))

        keyboardStateDelegate?.keyboardTransitionAnimation(state)

        UIView.commitAnimations()
    }

    /// Keyboard animation did stop selector
    @objc
    private dynamic func keyboardAnimationDidStop(_ animationID: String?, finished: Bool, context: UnsafeMutableRawPointer) {
        keyboardStateDelegate?.keyboardDidTransition(keyboardState)
    }

    // MARK: Private Variables

    /**
     Associated keys for private properties
     */
    private struct AssociatedKeys {
        static var KeyboardHeight: UInt8 = 0
        static var KeyboardDelegate: UInt8 = 0
    }

    /// Class-container to provide weak semantics for associated properties
    private class WeakObjectContainer {
        weak var delegate: KeyboardStateDelegate?

        init(_ delegate: KeyboardStateDelegate?) {
            self.delegate = delegate
        }
    }

    /// Keyboard state delegate container
    private var keyboardStateDelegate: KeyboardStateDelegate? {
        get {
            if let delegateContainer = objc_getAssociatedObject(self, &AssociatedKeys.KeyboardDelegate) as? WeakObjectContainer {
                return delegateContainer.delegate
            } else {
                return nil
            }
        }
        set {
            let value: WeakObjectContainer? = newValue != nil ? WeakObjectContainer(newValue!) : nil

            objc_setAssociatedObject(self,
                                     &AssociatedKeys.KeyboardDelegate,
                                     value,
                                     objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }

    /// Keyboard height container
    private var keyboardHeight: CGFloat {
        get {
            if let keyboardHeight = objc_getAssociatedObject(self, &AssociatedKeys.KeyboardHeight) as? NSNumber {
                return CGFloat(keyboardHeight.floatValue)
            }
            return 0.0
        }
        set {
            objc_setAssociatedObject(self,
                                     &AssociatedKeys.KeyboardHeight,
                                     NSNumber(value: Float(newValue) as Float),
                                     objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }
}

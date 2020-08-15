//
//  UIWindow+RootViewController.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 29/04/2017.
//  Copyright © 2017 Pavel Pronin All rights reserved.
//

extension UIWindow {

    func set(rootViewController newRootVC: UIViewController) {
        let animation = rootViewController != nil
        rootViewController = newRootVC
        if animation {
            UIView.transition(with: self,
                              duration: 0.3,
                              options: .transitionCrossDissolve,
                              animations: {
            }, completion: nil)
        }
    }
}

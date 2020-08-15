//
//  UIApplication+Extensions.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 27.07.2020.
//  Copyright © 2020 Pavel Pronin. All rights reserved.
//

extension UIApplication {

    static func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}


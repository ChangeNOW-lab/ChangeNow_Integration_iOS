//
//  UIViewController+Alert.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 12/07/2017.
//  Copyright © 2017 Pavel Pronin. All rights reserved.
//

extension UIViewController {

    func showMessage(_ message: String?, title: String? = nil) {
        guard message != nil, message != "" else { return }

        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: R.string.localizable.ok(), style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    func showError(_ message: String?) {
        guard message != nil, message != "" else { return }

        let alert = UIAlertController(title: R.string.localizable.error(), message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: R.string.localizable.ok(), style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    func showMessage(_ message: String?, title: String? = nil, cancelTitle: String, actionTitle: String, action: Action?) {
        guard message != nil, message != "" else { return }

        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: cancelTitle, style: UIAlertAction.Style.cancel, handler: nil))
        alert.addAction(UIAlertAction(title: actionTitle, style: UIAlertAction.Style.default, handler: { _ in
            action?.perform()
        }))

        self.present(alert, animated: true, completion: nil)
    }
}

//
//  UIViewController+Mail.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 26.04.2020.
//  Copyright © 2020 proninps. All rights reserved.
//

import MessageUI

extension UIViewController {

    func showEmail(subject: String?, message: String?, recipients: [String] = [ChangeNOW.supportMail]) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(recipients)
            if let subject = subject {
                mail.setSubject(subject)
            }
            if let message = message {
                mail.setMessageBody(message, isHTML: true)
            }
            present(mail, animated: true)
        } else {
            showError(R.string.localizable.errorMail())
        }
    }
}

extension UIViewController: MFMailComposeViewControllerDelegate {

    public func mailComposeController(_ controller: MFMailComposeViewController,
                                      didFinishWith result: MFMailComposeResult,
                                      error: Error?) {
        controller.dismiss(animated: true)
    }
}

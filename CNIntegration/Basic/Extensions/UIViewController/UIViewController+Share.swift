//
//  UIViewController+Share.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 26.04.2020.
//  Copyright © 2020 proninps. All rights reserved.
//

extension UIViewController {

    func showShare(items: [Any]) {
        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        var excludedActivityTypes = [
            UIActivity.ActivityType.postToFacebook,
            UIActivity.ActivityType.postToTwitter,
            UIActivity.ActivityType.postToWeibo,
            UIActivity.ActivityType.print,
            UIActivity.ActivityType.assignToContact,
            UIActivity.ActivityType.saveToCameraRoll,
            UIActivity.ActivityType.addToReadingList,
            UIActivity.ActivityType.postToFlickr,
            UIActivity.ActivityType.postToVimeo,
            UIActivity.ActivityType.postToTencentWeibo,
            UIActivity.ActivityType.openInIBooks
        ]
        if #available(iOS 11.0, *) {
            excludedActivityTypes.append(UIActivity.ActivityType.markupAsPDF)
        }
        activityViewController.excludedActivityTypes = excludedActivityTypes
        present(activityViewController, animated: true, completion: nil)
    }
}

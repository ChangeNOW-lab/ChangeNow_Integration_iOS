//
//  UIViewController+Additions.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 21/07/16.
//  Copyright © 2016 Pavel Pronin. All rights reserved.
//

import NVActivityIndicatorView

extension UIViewController {

    func showActivityIndicator() {
        let activityData = ActivityData(type: .ballSpinFadeLoader, color: .certainMain, backgroundColor: .clear)
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
    }

    func hideActivityIndicator() {
        NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
    }
}

//
//  UIImage+Theme.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 17.04.2020.
//  Copyright © 2020 proninps. All rights reserved.
//

extension UIImage {

    static var certainGreenImage: UIImage = {
        return UIImage.imageWithColor(.primarySelection)
    }()

    static var slightlyGreenImage: UIImage = {
        return UIImage.imageWithColor(UIColor.primarySelection.withAlphaComponent(0.08))
    }()

    static var mainImage = {
        return UIImage.imageWithColor(.main)
    }()

    static var backgroundImage = {
        return UIImage.imageWithColor(.background)
    }()

    static var darkBackgroundImage = {
        return UIImage.imageWithColor(.darkBackground)
    }()

    static var whiteImage = {
        return UIImage.imageWithColor(.white)
    }()

    static var certainLightWhiteImage = {
        return UIImage.imageWithColor(UIColor.white.withAlphaComponent(0.05))
    }()
}

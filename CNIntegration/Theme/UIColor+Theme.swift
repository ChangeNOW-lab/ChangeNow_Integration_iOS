//
//  UIColor+Theme.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 03/08/2017.
//  Copyright © 2017 Pavel Pronin All rights reserved.
//

extension UIColor {

    /// red: 0.969, green: 0.969, blue: 0.969
    static var lightBackground: UIColor {
        return ThemeManager.current.colors.lightBackground
    }

    /// red: 0.827, green: 0.843, blue: 0.855
    static var primaryGray: UIColor {
        return ThemeManager.current.colors.primaryGray
    }

    /// red: 0.153, green: 0.153, blue: 0.251
    static var darkBackground: UIColor {
        return ThemeManager.current.colors.darkBackground
    }

    /// red: 0.208, green: 0.208, blue: 0.298
    static var background: UIColor {
        return ThemeManager.current.colors.background
    }

    /// red: 0.285, green: 0.285, blue: 0.425
    static var main: UIColor {
        return ThemeManager.current.colors.main
    }

    /// red: 0.388, green: 0.388, blue: 0.455
    static var mainLight: UIColor {
        return ThemeManager.current.colors.mainLight
    }

    /// red: 0.502, green: 0.502, blue: 0.745
    static var mainSelection: UIColor {
        return ThemeManager.current.colors.mainSelection
    }

    /// red: 0, green: 0.761, blue: 0.435
    static var primarySelection: UIColor {
        return ThemeManager.current.colors.primarySelection
    }

    /// red: 1, green: 1, blue: 1, alpha: 0.5
    static var placeholder: UIColor {
        return ThemeManager.current.colors.placeholder
    }

    /// red: 0.941, green: 0.729, blue: 0.047
    static var primaryOrange: UIColor {
        return ThemeManager.current.colors.primaryOrange
    }

    /// red: 0.882, green: 0.384, blue: 0.384
    static var primaryRed: UIColor {
        return ThemeManager.current.colors.primaryRed
    }

    // MARK: - Special

    static var transactionSubTitle: UIColor {
        return ThemeManager.current.colors.transactionSubTitle
    }

    static var transactionBackground: UIColor {
        return ThemeManager.current.colors.transactionBackground
    }
}

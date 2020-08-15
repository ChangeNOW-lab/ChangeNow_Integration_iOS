//
//  DefaultTheme.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 26.07.2020.
//  Copyright © 2020 Pavel Pronin. All rights reserved.
//

public struct DefaultTheme: Theme {

    public let mainButtonCornerRadius: CGFloat? = nil
    public let cellSelectionCornerRadius: CGFloat = 12

    public let colors: ThemeColors = DefaultThemeColors()
    public let fonts: ThemeFonts = DefaultThemeFonts()
}

public struct DefaultThemeColors: ThemeColors {

    public var lightBackground: UIColor {
        return UIColor(red: 0.969, green: 0.969, blue: 0.969, alpha: 1)
    }

    public var slightlyGray: UIColor {
        return UIColor(red: 0.827, green: 0.843, blue: 0.855, alpha: 1)
    }

    public var darkBackground: UIColor {
        return UIColor(red: 0.153, green: 0.153, blue: 0.251, alpha: 1)
    }

    public var background: UIColor {
        return UIColor(red: 0.208, green: 0.208, blue: 0.298, alpha: 1)
    }

    public var main: UIColor {
        return UIColor(red: 0.285, green: 0.285, blue: 0.425, alpha: 1)
    }

    public var mainDark: UIColor {
        return UIColor(red: 0.388, green: 0.388, blue: 0.455, alpha: 1)
    }

    public var mainSelection: UIColor {
        return UIColor(red: 0.502, green: 0.502, blue: 0.745, alpha: 1)
    }

    public var certainMain: UIColor {
        return UIColor(red: 0, green: 0.761, blue: 0.435, alpha: 1)
    }

    public var placeholder: UIColor {
        return UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
    }

    public var sertainGrayLight: UIColor {
        return UIColor(red: 0.208, green: 0.208, blue: 0.298, alpha: 1)
    }

    public var certainOrange: UIColor {
        return UIColor(red: 0.941, green: 0.729, blue: 0.047, alpha: 1)
    }

    public var certainRed: UIColor {
        return UIColor(red: 0.882, green: 0.384, blue: 0.384, alpha: 1)
    }

    // MARK: Special

    public var transactionBackground: UIColor {
        return background
    }
}

public struct DefaultThemeFonts: ThemeFonts {

    // MARK: Description

    public var minorDescription: UIFont {
        return .systemFont(ofSize: 10, weight: .light)
    }

    public var normalDescription: UIFont {
        return .systemFont(ofSize: 14, weight: .light)
    }

    public var regularDescription: UIFont {
        return .systemFont(ofSize: 16, weight: .light)
    }

    public var mediumDescription: UIFont {
        return .systemFont(ofSize: 18, weight: .light)
    }

    // MARK: Text

    public var minorText: UIFont {
        return .systemFont(ofSize: 10, weight: .regular)
    }

    public var smallText: UIFont {
        return .systemFont(ofSize: 12, weight: .regular)
    }

    public var normalText: UIFont {
        return .systemFont(ofSize: 14, weight: .regular)
    }

    public var regularText: UIFont {
        return .systemFont(ofSize: 16, weight: .regular)
    }

    public var mediumText: UIFont {
        return .systemFont(ofSize: 18, weight: .regular)
    }

    // MARK: Title

    public var minorTitle: UIFont {
        return .systemFont(ofSize: 10, weight: .medium)
    }

    public var smallTitle: UIFont {
        return .systemFont(ofSize: 12, weight: .medium)
    }

    public var normalTitle: UIFont {
        return .systemFont(ofSize: 14, weight: .medium)
    }

    public var regularTitle: UIFont {
        return .systemFont(ofSize: 16, weight: .medium)
    }

    public var medianTitle: UIFont {
        return .systemFont(ofSize: 17, weight: .medium)
    }

    public var mediumTitle: UIFont {
        return .systemFont(ofSize: 18, weight: .medium)
    }

    public var largeTitle: UIFont {
        switch Device.model {
        case .iPhone5:
            return .systemFont(ofSize: 18, weight: .medium)
        default:
            return .systemFont(ofSize: 20, weight: .medium)
        }
    }

    // MARK: Headline

    public var normalHeadline: UIFont {
        return .systemFont(ofSize: 14, weight: .semibold)
    }

    public var mediumHeadline: UIFont {
        return .systemFont(ofSize: 18, weight: .semibold)
    }

    public var bigHeadline: UIFont {
        return .systemFont(ofSize: 22, weight: .semibold)
    }

    public var greatHeadline: UIFont {
        return .systemFont(ofSize: 24, weight: .semibold)
    }

    // MARK: Header

    public var littleHeader: UIFont {
        return .systemFont(ofSize: 11, weight: .bold)
    }

    public var normalHeader: UIFont {
        return .systemFont(ofSize: 14, weight: .bold)
    }

    public var regularHeader: UIFont {
        return .systemFont(ofSize: 16, weight: .bold)
    }
}

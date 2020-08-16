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

    public let lightBackground = UIColor(red: 0.969, green: 0.969, blue: 0.969, alpha: 1)
    public let primaryGray = UIColor(red: 0.827, green: 0.843, blue: 0.855, alpha: 1)
    public let darkBackground = UIColor(red: 0.153, green: 0.153, blue: 0.251, alpha: 1)
    public let background = UIColor(red: 0.208, green: 0.208, blue: 0.298, alpha: 1)
    public let main = UIColor(red: 0.285, green: 0.285, blue: 0.425, alpha: 1)
    public let mainLight = UIColor(red: 0.388, green: 0.388, blue: 0.455, alpha: 1)
    public let mainSelection = UIColor(red: 0.502, green: 0.502, blue: 0.745, alpha: 1)
    public let primarySelection = UIColor(red: 0, green: 0.761, blue: 0.435, alpha: 1)
    public let placeholder = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
    public let primaryOrange = UIColor(red: 0.941, green: 0.729, blue: 0.047, alpha: 1)
    public let primaryRed = UIColor(red: 0.882, green: 0.384, blue: 0.384, alpha: 1)

    // MARK: Special

    public var transactionSubTitle: UIColor {
        return background
    }

    public var transactionBackground: UIColor {
        return background
    }
}

public struct DefaultThemeFonts: ThemeFonts {

    // MARK: Description
    public let minorDescription = UIFont.systemFont(ofSize: 10, weight: .light)
    public let normalDescription = UIFont.systemFont(ofSize: 14, weight: .light)
    public let regularDescription = UIFont.systemFont(ofSize: 16, weight: .light)
    public let mediumDescription = UIFont.systemFont(ofSize: 18, weight: .light)

    // MARK: Text
    public let minorText = UIFont.systemFont(ofSize: 10, weight: .regular)
    public let smallText = UIFont.systemFont(ofSize: 12, weight: .regular)
    public let normalText = UIFont.systemFont(ofSize: 14, weight: .regular)
    public let regularText = UIFont.systemFont(ofSize: 16, weight: .regular)
    public let mediumText = UIFont.systemFont(ofSize: 18, weight: .regular)

    // MARK: Title
    public let minorTitle = UIFont.systemFont(ofSize: 10, weight: .medium)
    public let smallTitle = UIFont.systemFont(ofSize: 12, weight: .medium)
    public let normalTitle = UIFont.systemFont(ofSize: 14, weight: .medium)
    public let regularTitle = UIFont.systemFont(ofSize: 16, weight: .medium)
    public let medianTitle = UIFont.systemFont(ofSize: 17, weight: .medium)
    public let mediumTitle = UIFont.systemFont(ofSize: 18, weight: .medium)
    public let largeTitle: UIFont = {
        switch Device.model {
        case .iPhone5:
            return .systemFont(ofSize: 18, weight: .medium)
        default:
            return .systemFont(ofSize: 20, weight: .medium)
        }
    }()

    // MARK: Headline
    public let normalHeadline = UIFont.systemFont(ofSize: 14, weight: .semibold)
    public let mediumHeadline = UIFont.systemFont(ofSize: 18, weight: .semibold)
    public let bigHeadline = UIFont.systemFont(ofSize: 22, weight: .semibold)
    public let greatHeadline = UIFont.systemFont(ofSize: 24, weight: .semibold)

    // MARK: Header
    public let littleHeader = UIFont.systemFont(ofSize: 11, weight: .bold)
    public let normalHeader = UIFont.systemFont(ofSize: 14, weight: .bold)
    public let regularHeader = UIFont.systemFont(ofSize: 16, weight: .bold)
}

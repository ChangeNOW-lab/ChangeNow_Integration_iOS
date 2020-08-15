//
//  Theme.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 26.07.2020.
//  Copyright © 2020 Pavel Pronin. All rights reserved.
//

struct ThemeManager {

    static var current: Theme = {
        return DefaultTheme()
    }()
}

public protocol Theme {

    var mainButtonCornerRadius: CGFloat? { get }
    var cellSelectionCornerRadius: CGFloat { get }

    var colors: ThemeColors { get }
    var fonts: ThemeFonts { get }
}

public protocol ThemeColors {

    var lightBackground: UIColor { get }
    var slightlyGray: UIColor { get }
    var darkBackground: UIColor { get }
    var background: UIColor { get }
    var main: UIColor { get }
    var mainDark: UIColor { get }
    var mainSelection: UIColor { get }
    var certainMain: UIColor { get }
    var placeholder: UIColor { get }
    var sertainGrayLight: UIColor { get }
    var certainOrange: UIColor { get }
    var certainRed: UIColor { get }
    var transactionBackground: UIColor { get }
}

public protocol ThemeFonts {

    // MARK: Description
    var minorDescription: UIFont { get } 
    var normalDescription: UIFont { get }
    var regularDescription: UIFont { get }
    var mediumDescription: UIFont { get }

    // MARK: Text
    var minorText: UIFont { get }
    var smallText: UIFont { get }
    var normalText: UIFont { get }
    var regularText: UIFont { get }
    var mediumText: UIFont { get }

    // MARK: Title
    var minorTitle: UIFont { get }
    var smallTitle: UIFont { get }
    var normalTitle: UIFont { get }
    var regularTitle: UIFont { get }
    var medianTitle: UIFont { get }
    var mediumTitle: UIFont { get }
    var largeTitle: UIFont { get }

    // MARK: Headline
    var normalHeadline: UIFont { get }
    var mediumHeadline: UIFont { get }
    var bigHeadline: UIFont { get }
    var greatHeadline: UIFont { get }

    // MARK: Header
    var littleHeader: UIFont { get }
    var normalHeader: UIFont { get }
    var regularHeader: UIFont { get }
}

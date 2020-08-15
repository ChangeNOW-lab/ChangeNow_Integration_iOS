//
//  UIFont+Theme.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 17.04.2020.
//  Copyright © 2020 proninps. All rights reserved.
//

extension UIFont {

    // MARK: Description

    /// Light 10
    static var minorDescription: UIFont {
        return ThemeManager.current.fonts.minorDescription
    }

    /// Light 14
    static var normalDescription: UIFont {
        return ThemeManager.current.fonts.normalDescription
    }

    /// Light 16
    static var regularDescription: UIFont {
        return ThemeManager.current.fonts.regularDescription
    }

    /// Light 18
    static var mediumDescription: UIFont {
        return ThemeManager.current.fonts.mediumDescription
    }

    // MARK: Text

    /// Regular 10
    static var minorText: UIFont {
        return ThemeManager.current.fonts.minorText
    }

    /// Regular 12
    static var smallText: UIFont {
        return ThemeManager.current.fonts.smallText
    }

    /// Regular 14
    static var normalText: UIFont {
        return ThemeManager.current.fonts.normalText
    }

    /// Regular 16
    static var regularText: UIFont {
        return ThemeManager.current.fonts.regularText
    }

    /// Regular 18
    static var mediumText: UIFont {
        return ThemeManager.current.fonts.mediumText
    }

    // MARK: Title

    /// Medium 10
    static var minorTitle: UIFont {
        return ThemeManager.current.fonts.minorTitle
    }

    /// Medium 12
    static var smallTitle: UIFont {
        return ThemeManager.current.fonts.smallTitle
    }

    /// Medium 14
    static var normalTitle: UIFont {
        return ThemeManager.current.fonts.normalTitle
    }

    /// Medium 16
    static var regularTitle: UIFont {
        return ThemeManager.current.fonts.regularTitle
    }

    /// Medium 17
    static var medianTitle: UIFont {
        return ThemeManager.current.fonts.medianTitle
    }

    /// Medium 18
    static var mediumTitle: UIFont {
        return ThemeManager.current.fonts.mediumTitle
    }

    /// Medium 20
    static var largeTitle: UIFont {
        return ThemeManager.current.fonts.largeTitle
    }

    // MARK: Headline

    /// Semibold 14
    static var normalHeadline: UIFont {
        return ThemeManager.current.fonts.normalHeadline
    }

    /// Semibold 18
    static var mediumHeadline: UIFont {
        return ThemeManager.current.fonts.mediumHeadline
    }

    /// Semibold 22
    static var bigHeadline: UIFont {
        return ThemeManager.current.fonts.bigHeadline
    }

    /// Semibold 24
    static var greatHeadline: UIFont {
        return ThemeManager.current.fonts.greatHeadline
    }

    // MARK: Header

    /// Bold 11
    static var littleHeader: UIFont {
        return ThemeManager.current.fonts.littleHeader
    }

    /// Bold 14
    static var normalHeader: UIFont {
        return ThemeManager.current.fonts.normalHeader
    }

    /// Bold 16
    static var regularHeader: UIFont {
        return ThemeManager.current.fonts.regularHeader
    }
}

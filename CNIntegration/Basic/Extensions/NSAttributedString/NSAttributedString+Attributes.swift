//
//  NSAttributedString+Attributes.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 30/04/2017.
//  Copyright © 2017 Pavel Pronin. All rights reserved.
//

extension NSAttributedString {

    convenience init(string: String, font: UIFont, color: UIColor, letterSpacing: CGFloat = 0) {
        self.init(string: string, attributes: [
        NSAttributedString.Key.font: font,
        NSAttributedString.Key.foregroundColor: color,
        NSAttributedString.Key.kern: letterSpacing
        ])
    }

    // MARK: NSKernAttributeName

    func addLetterSpacing(_ value: CGFloat) -> NSAttributedString {
        if let mutableCopy = self.mutableCopy() as? NSMutableAttributedString {
            mutableCopy.addAttribute(NSAttributedString.Key.kern, value: value, range: NSRange(location: 0, length: self.length))
            return mutableCopy
        }
        return self
    }

    // MARK: NSParagraphStyle

    func addParagraphStyle(_ paragraphStyle: NSParagraphStyle) -> NSAttributedString {
        if let mutableCopy = self.mutableCopy() as? NSMutableAttributedString {
            mutableCopy.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: self.length))
            return mutableCopy
        }
        return self
    }

    func addMinimumLineHeight(_ value: CGFloat) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = value
        return self.addParagraphStyle(paragraphStyle)
    }

    func addMaximumLineHeight(_ value: CGFloat) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.maximumLineHeight = value
        return self.addParagraphStyle(paragraphStyle)
    }
}

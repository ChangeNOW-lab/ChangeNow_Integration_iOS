//
//  String+Additions.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 17/07/2018.
//  Copyright © 2018 Pavel Pronin. All rights reserved.
//

extension String {

    func sizeWith(font: UIFont, constrainedToWidth width: Double) -> CGSize {
        let attributedString = NSAttributedString(string: self, attributes: [NSAttributedString.Key.font: font])
        let framesetter = CTFramesetterCreateWithAttributedString(attributedString)
        return CTFramesetterSuggestFrameSizeWithConstraints(
            framesetter,
            CFRange(location: 0, length: 0),
            nil,
            CGSize(width: width, height: .greatestFiniteMagnitude),
            nil
        )
    }
}

extension String {

    func toNumber() -> Int? {
        var v: Int = 0
        if Scanner(string: self).scanInt(&v) {
            return v
        }
        return nil
    }

    func toNumber() -> Float? {
        var v: Float = 0
        if Scanner(string: self).scanFloat(&v) {
            return v
        }
        return nil
    }

    func toNumber() -> Double? {
        var v: Double = 0
        if Scanner(string: self).scanDouble(&v) {
            return v
        }
        return nil
    }
}

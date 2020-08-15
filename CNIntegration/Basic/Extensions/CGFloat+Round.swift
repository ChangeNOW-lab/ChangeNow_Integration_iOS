//
//  CGFloat+Round.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 13/07/2017.
//  Copyright © 2017 Pavel Pronin. All rights reserved.
//

extension CGFloat {

    func round() -> CGFloat {
        return CGFloat(ceilf(Float(self) * Float(UIScreen.main.scale)) * (1.0 / Float(UIScreen.main.scale)))
    }

    func sRound() -> CGFloat {
        return CGFloat(roundf(Float(self)))
    }

    mutating func mRound() {
        self = CGFloat(ceilf(Float(self) * Float(UIScreen.main.scale)) * (1.0 / Float(UIScreen.main.scale)))
    }

    func up() -> CGFloat {
        return CGFloat(ceilf(Float(self)))
    }

    func down() -> CGFloat {
        return CGFloat(floorf(Float(self)))
    }

    /// String without values after the decimal point
    var clean: String {
        return String(format: "%.0f", self)
    }
}

extension Float {

    func round() -> Float {
        return ceilf(self * Float(UIScreen.main.scale)) * (1.0 / Float(UIScreen.main.scale))
    }

    func sRound() -> Float {
        return roundf(self)
    }

    mutating func mRound() {
        self = ceilf(self * Float(UIScreen.main.scale)) * (1.0 / Float(UIScreen.main.scale))
    }

    func up() -> Float {
        return ceilf(self)
    }

    func down() -> Float {
        return floorf(self)
    }

    /// String without values after the decimal point
    var clean: String {
        return String(format: "%.0f", self)
    }
}

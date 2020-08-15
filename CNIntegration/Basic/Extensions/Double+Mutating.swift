//
//  Double+Mutating.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 26/07/2017.
//  Copyright © 2017 Pavel Pronin. All rights reserved.
//

import Foundation

extension Double {

    func round() -> Double {
        return ceil(self * Double(UIScreen.main.scale)) * (1.0 / Double(UIScreen.main.scale))
    }

    func sRound() -> Double {
        return Darwin.round(self)
    }

    mutating func mRound() {
        self = ceil(self * Double(UIScreen.main.scale)) * (1.0 / Double(UIScreen.main.scale))
    }

    func up() -> Double {
        return ceil(self)
    }

    func down() -> Double {
        return floor(self)
    }

    /// String without values after the decimal point
    var clean: String {
        return String(format: "%.0f", self)
    }
}

extension Double {

    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

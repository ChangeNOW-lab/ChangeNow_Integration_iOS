//
//  Decimal+Extensions.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 30/03/2017.
//  Copyright © 2017 Pavel Pronin. All rights reserved.
//

extension Decimal {
    var doubleValue: Double {
        return NSDecimalNumber(decimal: self).doubleValue
    }

    var intValue: Int {
        return Int(NSDecimalNumber(decimal: self).doubleValue)
    }

    var floatValue: Float {
        return NSDecimalNumber(decimal: self).floatValue
    }

    func rounding(withMode mode: RoundingMode, scale: Int) -> Decimal {
        let rounder = NSDecimalNumberHandler(roundingMode: mode,
                                             scale: Int16(scale),
                                             raiseOnExactness: false,
                                             raiseOnOverflow: false,
                                             raiseOnUnderflow: false,
                                             raiseOnDivideByZero: false)

        return (self as NSDecimalNumber).rounding(accordingToBehavior: rounder) as Decimal
    }
}

//
//  Int+Extensions.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 16/06/2017.
//  Copyright © 2017 Pavel Pronin. All rights reserved.
//

extension Int {

    static func random(range: CountableClosedRange<Int>) -> Int {
        var offset = 0

        if range.lowerBound < 0 {
            offset = abs(range.lowerBound)
        }

        let lowerBound = UInt32(range.lowerBound + offset)
        let upperBound = UInt32(range.upperBound + offset)

        return Int(lowerBound + arc4random_uniform(upperBound - lowerBound)) - offset
    }
}

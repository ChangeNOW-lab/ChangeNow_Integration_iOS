//
//  ClosedRange+Extensions.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 19.04.2020.
//  Copyright © 2020 proninps. All rights reserved.
//

extension ClosedRange where Bound == Unicode.Scalar {

    var range: ClosedRange<UInt32> {
        return lowerBound.value...upperBound.value
    }

    var scalars: [Unicode.Scalar] {
        return range.compactMap(Unicode.Scalar.init)
    }

    var characters: [Character] {
        return scalars.map(Character.init)
    }

    var string: String {
        return String(scalars)
    }
}

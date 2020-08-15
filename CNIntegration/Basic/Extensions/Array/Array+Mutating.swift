//
//  Array+Mutating.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 30/04/2017.
//  Copyright © 2017 Pavel Pronin. All rights reserved.
//

import Foundation

extension Array where Element: Equatable {

    mutating func remove(object: Element) {
        if let index = firstIndex(of: object) {
            remove(at: index)
        }
    }

    func unique() -> [Element] {
        var uniqueValues: [Element] = []
        for item in self {
            if !uniqueValues.contains(item) {
                uniqueValues.append(item)
            }
        }
        return uniqueValues
    }
}

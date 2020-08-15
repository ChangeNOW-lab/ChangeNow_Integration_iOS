//
//  Sequence+Extensions.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 07/08/2018.
//  Copyright © 2018 Pavel Pronin. All rights reserved.
//

extension Sequence {

    func all(_ predicate: (Self.Iterator.Element) -> Bool) -> Bool {
        for element in self {
            if !predicate(element) { return false }
        }
        return true
    }

    func any(_ predicate: (Self.Iterator.Element) -> Bool) -> Bool {
        for element in self {
            if predicate(element) { return true }
        }
        return false
    }
}

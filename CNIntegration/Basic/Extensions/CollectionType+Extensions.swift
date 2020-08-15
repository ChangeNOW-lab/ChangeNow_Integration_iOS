//
//  CollectionType+Extensions.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 09.08.16.
//  Copyright © 2016 Pavel Pronin. All rights reserved.
//

extension Collection {

    var nonEmpty: Self? {
        return isEmpty ? nil : self
    }

   var isNotEmpty: Bool {
        return !isEmpty
    }
}

extension Collection {

    /// Returns the element at the specified index iff it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension Collection {

    func dictionary<K, V>(transform: (_ element: Iterator.Element) -> [K: V]?) -> [K: V] {
        var dictionary = [K: V]()
        self.forEach { element in
            if let transformedElement = transform(element) {
                for (key, value) in transformedElement {
                    dictionary[key] = value
                }
            }
        }
        return dictionary
    }
}

//
//  Array+Extension.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 11/12/2019.
//  Copyright © 2019 Pavel Pronin. All rights reserved.
//

extension Array where Element: Equatable {

    func removeDuplicates() -> [Element] {
        var result = [Element]()

        for value in self {
            if result.contains(value) == false {
                result.append(value)
            }
        }

        return result
    }

    func removeDuplicates<T>(_ comparableObject: (Element) -> T) -> [Element] {
        var uniqueObjects = Set<String>()
        return filter { uniqueObjects.insert("\(comparableObject($0))").inserted }
    }

    @discardableResult
    mutating func removeSafe(at position: Int) -> Element? {
        if count > position {
            return remove(at: position)
        }
        return nil
    }
}

//
//  Dictionary+Extensions.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 27/12/2016.
//  Copyright © 2016 Pavel Pronin. All rights reserved.
//

extension Dictionary {

    init(elements: [Element]) {
        var dictionary: [Key: Value] = [:]
        for (key, value) in elements {
            dictionary[key] = value
        }
        self = dictionary
    }
}

@available(iOS 11.0, *)
extension Dictionary where Key == String, Value == String {

    var jsonString: String? {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self, options: .sortedKeys)
            let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)
            return jsonString as String?
        } catch {
            return nil
        }
    }
}

extension Dictionary {

     var queryString: String? {
        guard !self.isEmpty else { return nil }

        var queryStringComponents: [String] = []
        for (key, value) in self {
            queryStringComponents.append("\(key)=\(value)")
        }
        return queryStringComponents.joined(separator: "&")
    }

    subscript <T: RawRepresentable>(key: T) -> Value? where T.RawValue == Key {
        get {
            return self[key.rawValue]
        }
        set {
            self[key.rawValue] = newValue
        }
    }
}

/// Merges dictionaries into one dictionary.
func union<K, V>(_ dictionaries: [K: V]...) -> [K: V] {
    var result = [K: V]()
    for dictionary in dictionaries {
        for (key, value) in dictionary {
            result.updateValue(value, forKey: key)
        }
    }
    return result
}

func + <K, V> (first: [K: V], second: [K: V]) -> [K: V] {
    return union(first, second)
}

func + <K, V> (first: [K: V]?, second: [K: V]) -> [K: V] {
    if let first = first {
        return first + second
    }
    return second
}

func + <K, V> (first: [K: V], second: [K: V]?) -> [K: V] {
    if let second = second {
        return first + second
    }
    return first
}

func += <K, V> (first: inout [K: V], second: [K: V]) {
    for (key, value) in second {
        first[key] = value
    }
}

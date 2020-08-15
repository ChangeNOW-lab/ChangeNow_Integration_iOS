//
//  Array+Synchronized.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 29/07/2017.
//  Copyright © 2017 Pavel Pronin. All rights reserved.
//

import Foundation

class SynchronizedArray<Element> {

    init() {}

    init(_ sequence: [Element]) {
        sequence.forEach { element in
            self.array.append(element)
        }
    }

    private var monitor = os_unfair_lock_s()
    private var array = [Element]()

    private func synchronized<T>(_ closure: () -> (T)) -> T {
        os_unfair_lock_lock(&monitor)
        let result = closure()
        os_unfair_lock_unlock(&monitor)
        return result
    }
}

// MARK: - Properties

extension SynchronizedArray {

    /// The first element of the collection.
    var first: Element? {
        return synchronized { self.array.first }
    }

    /// The last element of the collection.
    var last: Element? {
        return synchronized { self.array.last }
    }

    /// The number of elements in the array.
    var count: Int {
        return synchronized { self.array.count }
    }

    /// A Boolean value indicating whether the collection is empty.
    var isEmpty: Bool {
        return synchronized { self.array.isEmpty }
    }

    /// A Boolean value indicating whether the collection is empty.
    var isNotEmpty: Bool {
        return synchronized { !self.array.isEmpty }
    }

    /// A textual representation of the array and its elements.
    var description: String {
        return synchronized { self.array.description }
    }
}

// MARK: - Immutable

extension SynchronizedArray {
    /// Returns the first element of the sequence that satisfies the given predicate or nil if no such element is found.
    ///
    /// - Parameter predicate: A closure that takes an element of the sequence as its argument and returns a Boolean value indicating whether the element is a match.
    /// - Returns: The first match or nil if there was no match.
    func first(where predicate: (Element) -> Bool) -> Element? {
        return synchronized { self.array.first(where: predicate) }
    }

    /// Returns an array containing, in order, the elements of the sequence that satisfy the given predicate.
    ///
    /// - Parameter isIncluded: A closure that takes an element of the sequence as its argument and returns a Boolean value indicating whether the element should be included in the returned array.
    /// - Returns: An array of the elements that includeElement allowed.
    func filter(_ isIncluded: (Element) -> Bool) -> [Element] {
        return synchronized { self.array.filter(isIncluded) }
    }

    /// Returns the first index in which an element of the collection satisfies the given predicate.
    ///
    /// - Parameter predicate: A closure that takes an element as its argument and returns a Boolean value that indicates whether the passed element represents a match.
    /// - Returns: The index of the first element for which predicate returns true. If no elements in the collection satisfy the given predicate, returns nil.
    func index(where predicate: (Element) -> Bool) -> Int? {
        return synchronized { self.array.firstIndex(where: predicate) }
    }

    /// Returns the elements of the collection, sorted using the given predicate as the comparison between elements.
    ///
    /// - Parameter areInIncreasingOrder: A predicate that returns true if its first argument should be ordered before its second argument; otherwise, false.
    /// - Returns: A sorted array of the collection’s elements.
    func sorted(by areInIncreasingOrder: (Element, Element) -> Bool) -> [Element] {
        return synchronized { self.array.sorted(by: areInIncreasingOrder) }
    }

    /// Returns an array containing the non-nil results of calling the given transformation with each element of this sequence.
    ///
    /// - Parameter transform: A closure that accepts an element of this sequence as its argument and returns an optional value.
    /// - Returns: An array of the non-nil results of calling transform with each element of the sequence.
    func flatMap<ElementOfResult>(_ transform: (Element) -> ElementOfResult?) -> [ElementOfResult] {
        return synchronized { self.array.compactMap(transform) }
    }

    /// Calls the given closure on each element in the sequence in the same order as a for-in loop.
    ///
    /// - Parameter body: A closure that takes an element of the sequence as a parameter.
    func forEach(_ body: (Element) -> Void) {
        return synchronized { self.array.forEach(body) }
    }

    /// Returns a Boolean value indicating whether the sequence contains an element that satisfies the given predicate.
    ///
    /// - Parameter predicate: A closure that takes an element of the sequence as its argument and returns a Boolean value that indicates whether the passed element represents a match.
    /// - Returns: true if the sequence contains an element that satisfies predicate; otherwise, false.
    func contains(where predicate: (Element) -> Bool) -> Bool {
        return synchronized { self.array.contains(where: predicate) }
    }
}

// MARK: - Mutable

extension SynchronizedArray {

    /// Adds a new element at the end of the array.
    ///
    /// - Parameter element: The element to append to the array.
    func append( _ element: Element) {
        return synchronized { self.array.append(element) }
    }

    /// Adds a new element at the end of the array.
    ///
    /// - Parameter element: The element to append to the array.
    func append( _ elements: [Element]) {
        return synchronized { self.array += elements }
    }

    /// Inserts a new element at the specified position.
    ///
    /// - Parameters:
    ///   - element: The new element to insert into the array.
    ///   - index: The position at which to insert the new element.
    func insert( _ element: Element, at index: Int) {
        return synchronized { self.array.insert(element, at: index) }
    }

    /// Removes the element at the specified position.
    ///
    /// - Parameters:
    ///   - index: The position of the element to remove.
    func remove(at index: Int) {
        synchronized {
            guard self.array.startIndex..<self.array.endIndex ~= index else { return }
            self.array.remove(at: index)
        }
    }

    /// Removes the element at the specified position.
    ///
    /// - Parameters:
    ///   - predicate: A closure that takes an element of the sequence as its argument and returns a Boolean value indicating whether the element is a match.
    func remove(where predicate: @escaping (Element) -> Bool) {
        synchronized {
            guard let index = self.array.firstIndex(where: predicate) else { return }
            self.array.remove(at: index)
        }
    }

    /// Removes all elements at the specified position.
    ///
    /// - Parameters:
    ///   - predicate: A closure that takes an element of the sequence as its argument and returns a Boolean value indicating whether the element is a match.
    func removeAll(where predicate: @escaping (Element) -> Bool) {
        synchronized {
            for index in array.indices.reversed() where predicate(array[index]) {
                array.remove(at: index)
            }
        }
    }

    /// Removes all elements from the array.
    func removeAll() {
        synchronized { self.array.removeAll() }
    }

}

extension SynchronizedArray {

    /// Accesses the element at the specified position if it exists.
    ///
    /// - Parameter index: The position of the element to access.
    /// - Returns: optional element if it exists.
    subscript(index: Int) -> Element? {
        get {
            return synchronized {
                guard self.array.startIndex..<self.array.endIndex ~= index else { return nil }
                return self.array[index]
            }
        }
        set {
            guard let newValue = newValue else { return }
            synchronized { self.array[index] = newValue }
        }
    }
}

// MARK: - Equatable

extension SynchronizedArray where Element: Equatable {

    /// Returns a Boolean value indicating whether the sequence contains the given element.
    ///
    /// - Parameter element: The element to find in the sequence.
    /// - Returns: true if the element was found in the sequence; otherwise, false.
    func contains(_ element: Element) -> Bool {
        return synchronized { self.array.contains(element) }
    }
}

// MARK: - Infix operators

extension SynchronizedArray {

    static func += (left: inout SynchronizedArray, right: Element) {
        left.append(right)
    }

    static func += (left: inout SynchronizedArray, right: [Element]) {
        left.append(right)
    }
}

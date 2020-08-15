//
//  Logger.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 23/07/2018.
//  Copyright © 2018 Pavel Pronin. All rights reserved.
//

final class ListenerContainer<T> {

    private var listeners = NSHashTable<AnyObject>.weakObjects()

    // MARK: - Public

    init() {}

    func add(listener: T) {
        listeners.add(listener as AnyObject)
    }

    func remove(listener: T) {
        listeners.remove(listener as AnyObject)
    }

    func forEach(_ block: @escaping (T) -> Void) {
        listeners.allObjects.compactMap { $0 as? T }.forEach(block)
    }

    func executeInMainForEach(_ block: @escaping (T) -> Void) {
        if Thread.isMainThread {
            listeners.allObjects.compactMap { $0 as? T }.forEach(block)
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.listeners.allObjects.compactMap { $0 as? T }.forEach(block)
            }
        }
    }
}

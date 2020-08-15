//
//  UserDefaultsStorage.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 06/03/17.
//  Copyright © 2017 ChangeNOW. All rights reserved.
//

protocol UserDefaultsStorageKeyConvertible {
    var userDefaultsStorageKey: String { get }
}

struct UserDefaultsStorage {

    static func value<T>(forKey key: UserDefaultsStorageKey) -> T? {
        return UserDefaults.standard.object(forKey: key.userDefaultsStorageKey) as? T
    }

    static func set<T>(_ value: T?, forKey key: UserDefaultsStorageKey, synchronizeImmediately: Bool = false) {
        if let value = value {
            UserDefaults.standard.set(value, forKey: key.userDefaultsStorageKey)
        } else {
            removeValueForKey(key)
        }
        if synchronizeImmediately {
            synchronize()
        }
    }

    static func removeValueForKey(_ key: UserDefaultsStorageKeyConvertible) {
        UserDefaults.standard.removeObject(forKey: key.userDefaultsStorageKey)
    }

    static func synchronize() {
        UserDefaults.standard.synchronize()
    }

    static func resetAll() {
        if let bundleIdentifier = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleIdentifier)
        }
    }
}

//
//  NSDictionary+Extensions.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 04/02/2020.
//  Copyright © 2020 Pavel Pronin. All rights reserved.
//

import Foundation

extension NSDictionary {

    var swiftDictionary: [String: AnyObject] {
        var swiftDictionary: [String: AnyObject] = [:]
        let keys = self.allKeys.compactMap { $0 as? String }
        for key in keys {
            let keyValue = self.value(forKey: key) as AnyObject
            swiftDictionary[key] = keyValue
        }
        return swiftDictionary
    }
}

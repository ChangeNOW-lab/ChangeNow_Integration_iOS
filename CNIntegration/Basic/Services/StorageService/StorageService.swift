//
//  StorageService.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 29/04/2017.
//  Copyright © 2017 Pavel Pronin All rights reserved.
//

import Foundation
import CoreData

struct StorageService {

    static func removeAllData() {
        UserDefaultsStorage.resetAll()
        KeychainStorage.resetAll()
        try? FileStorage.resetAll()
    }
}

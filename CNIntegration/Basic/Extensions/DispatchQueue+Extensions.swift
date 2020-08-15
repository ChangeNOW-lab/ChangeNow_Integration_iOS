//
//  DispatchQueue+Extensions.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 05/11/2019.
//  Copyright © 2019 Pavel Pronin. All rights reserved.
//

extension DispatchQueue {

    private static var privateOnceTracker = [String]()

    static func once(file: StaticString = #file, line: UInt = #line, block: () -> Void) {
        let token = "\(file)-\(line)"
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        if privateOnceTracker.contains(token) {
            return
        }
        privateOnceTracker.append(token)
        block()
    }
}

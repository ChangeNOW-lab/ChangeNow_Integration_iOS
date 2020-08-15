//
//  TimeZone+Extensions.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 24/05/2018.
//  Copyright © 2018 Pavel Pronin. All rights reserved.
//

extension TimeZone {

    static var UTC: TimeZone {
        return TimeZone(abbreviation: "UTC")!
    }

    static var GMT: TimeZone {
        return TimeZone(secondsFromGMT: 0)!
    }
}

//
//  Hash+Extensions.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 15/08/2018.
//  Copyright © 2018 Pavel Pronin. All rights reserved.
//

func combine(hashes: [Int]) -> Int {
    return hashes.reduce(0, { 31 &* $0 &+ $1.hashValue })
}

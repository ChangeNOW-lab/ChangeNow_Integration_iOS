//
//  String+Helper.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 12/07/2017.
//  Copyright © 2017 Pavel Pronin. All rights reserved.
//

import Foundation

extension String {

    func lastIndexOf(target: String) -> NSRange? {
        let range = (self as NSString).range(of: target)
        if range.location == NSNotFound {
            return nil
        }
        return range
    }

    func replaceCharactersInRange(range: Range<Int>, withString: String) -> String {
        let result: NSMutableString = NSMutableString(string: self)
        result.replaceCharacters(in: NSRange(range), with: withString)
        return result as String
    }

    func contains(strings: [String]) -> Bool {
        guard strings.isEmpty else { return false }
        var result: [Bool] = []
        for string in strings {
            result.append(self.contains(string))
        }
        return result.allSatisfy { $0 }
    }

    static func randomString(length: Int) -> String {

        let letters: NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)

        var randomString = ""

        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }

        return randomString
    }
}

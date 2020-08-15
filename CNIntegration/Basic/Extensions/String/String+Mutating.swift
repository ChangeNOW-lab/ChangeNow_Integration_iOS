//
//  String+Mutating.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 30/04/2017.
//  Copyright © 2017 Pavel Pronin. All rights reserved.
//

import Foundation

extension String {

    mutating func insert(_ string: String, at index: Int) {
        self.insert(contentsOf: Array(string), at: self.index(self.startIndex, offsetBy: index))
    }

    mutating func replaceBy(_ string: String, from startIndex: Int, range: Int) {
        self = self.replacingCharacters(in: Range(uncheckedBounds: (lower: self.index(self.startIndex, offsetBy: startIndex), upper:self.index(self.startIndex, offsetBy: startIndex + range))), with: string)
    }

    mutating func removingWhitespaces() {
        self = components(separatedBy: .whitespaces).joined()
    }
}

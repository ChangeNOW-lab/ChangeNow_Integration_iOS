//
//  NSRange+Converter.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 12/07/2017.
//  Copyright © 2017 Pavel Pronin. All rights reserved.
//

import Foundation

extension NSRange {

    func range(for str: String) -> Range<String.Index>? {
        guard location != NSNotFound else { return nil }

        guard let fromUTFIndex = str.utf16.index(str.utf16.startIndex, offsetBy: location, limitedBy: str.utf16.endIndex) else { return nil }
        guard let toUTFIndex = str.utf16.index(fromUTFIndex, offsetBy: length, limitedBy: str.utf16.endIndex) else { return nil }
        guard let fromIndex = String.Index(fromUTFIndex, within: str) else { return nil }
        guard let toIndex = String.Index(toUTFIndex, within: str) else { return nil }

        return fromIndex ..< toIndex
    }
}

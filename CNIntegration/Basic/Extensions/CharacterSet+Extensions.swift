//
//  CharacterSet+Extensions.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 19.04.2020.
//  Copyright © 2020 proninps. All rights reserved.
//

extension CharacterSet {

    static let hexadecimal = CharacterSet(charactersIn: "0123456789ABCDEFabcdef")

    static let latinLetters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ")

    static let addressLetters: CharacterSet = {
        var characterSet = latinLetters
        characterSet.formUnion(CharacterSet(charactersIn: ":1234567890"))
        return characterSet
    }()

    static let dot = CharacterSet(charactersIn: ".")

    static let floatDigits: CharacterSet = {
        var characterSet = CharacterSet.dot
        characterSet.formUnion(.decimalDigits)
        return characterSet
    }()
}

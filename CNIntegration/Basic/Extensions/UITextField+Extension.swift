//
//  UITextField+Additions.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 06/01/2017.
//  Copyright © 2017 Pavel Pronin. All rights reserved.
//

extension UITextField {

    func replaceCharactersOfFormattedStringInRange(_ range: NSRange,
                                                   withString string: String,
                                                   normalizedCharacters: CharacterSet,
                                                   formatting: (String) -> String) {
        let (formattedString, offset) = (text ?? "")
            .replaceCharactersOfFormattedStringInRange(range,
                                                       withString: string,
                                                       normalizedCharacters: normalizedCharacters,
                                                       formatting: formatting)

        restoreCursorPositionInFormattedString(formattedString,
                                               normalizedOffset: offset,
                                               normalizedCharacters: normalizedCharacters)
    }

    func restoreCursorPositionInFormattedString(_ formattedString: String,
                                                normalizedOffset: Int,
                                                normalizedCharacters: CharacterSet) {
        var cursorOffset = normalizedOffset

        for (index, character) in formattedString.enumerated() {
            guard index <= cursorOffset else { break }

            if character.unicodeScalars.filter(normalizedCharacters.contains).isEmpty {
                cursorOffset += 1 // incrementing offset each time we encounter formatting character
            }
        }

        if let restoredCursorPosition = position(from: beginningOfDocument, offset: cursorOffset) {
            let newSelectedRange = textRange(from: restoredCursorPosition, to: restoredCursorPosition)
            selectedTextRange = newSelectedRange
        }
    }
}

extension UITextField {
    /// Moves the caret to the correct position by removing the trailing whitespace
    func fixCaretPosition() {
        // Moving the caret to the correct position by removing the trailing whitespace
        // http://stackoverflow.com/questions/14220187/uitextfield-has-trailing-whitespace-after-securetextentry-toggle

        let beginning = beginningOfDocument
        selectedTextRange = textRange(from: beginning, to: beginning)
        let end = endOfDocument
        selectedTextRange = textRange(from: end, to: end)
    }
}

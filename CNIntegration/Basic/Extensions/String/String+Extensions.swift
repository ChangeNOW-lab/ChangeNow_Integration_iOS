//
//  String+Extensions.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 05/01/2017.
//  Copyright © 2017 Pavel Pronin. All rights reserved.
//

extension Character {

    func isDigit() -> Bool {
        return isWholeNumber
    }

    func isZeroDigit() -> Bool {
        return ("\(self)" as NSString).integerValue == 0
    }
}

extension String {

    init<S: Sequence>(_ sequence: S) where S.Element == Unicode.Scalar {
        self.init(UnicodeScalarView(sequence))
    }
}

extension String {

    var nonEmpty: String? {
        return isEmpty ? nil : self
    }

    var floatDigit: String {
        var isDotted = false
        var isZeroStart = true
        var floatDigit = ""
        for (index, character) in self.enumerated() {
            if character == "." {
                if index == 0 {
                    isZeroStart = false
                    floatDigit.append("0")
                }
                if !isDotted {
                    isDotted = true
                    floatDigit.append(character)
                }
            } else {
                if isZeroStart {
                    if !character.isZeroDigit() || index != 0 {
                        isZeroStart = false
                    }
                    if index != 0, !isDotted {
                        isDotted = true
                        floatDigit.append(".")
                    }
                }
                floatDigit.append(String((String(character) as NSString).integerValue))
            }
        }
        return floatDigit
    }

    var arabicDigits: String {
        return compactMap {
            if $0.isDigit() {
                return String((String($0) as NSString).integerValue)
            }
            return nil
        }.joined()
    }

    var stringWithoutHtmlTags: String {
        return self.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
    }

    private static let directionChangeStart = "\u{202A}" // start of text direction change
    private static let directionChangeEnd = "\u{202C}"   // end of text direction change

    func removeWhitespacesAndNewlines() -> String {
        return components(separatedBy: .whitespacesAndNewlines).joined()
    }

    func stripNonDigits() -> String {
        return String(unicodeScalars.filter(CharacterSet.decimalDigits.contains))
    }

    func stripNonDigitsExPlus() -> String {
        let allowedCharset = CharacterSet.decimalDigits.union(CharacterSet(charactersIn: "+"))
        return String(unicodeScalars.filter(allowedCharset.contains))
    }

    func isDigitsOnly() -> Bool {
        return all({ $0.isDigit() })
    }

    func contains(_ find: String, ignoreCase: Bool = true) -> Bool {
        var options = NSString.CompareOptions()
        if ignoreCase {
            options.formUnion(.caseInsensitive)
        }
        return self.range(of: find, options: options) != nil
    }

    func indexOfFirst(target: String) -> Int? {
        let range = (self as NSString).range(of: target)
        if range.location != NSNotFound {
            return range.location
        }
        return nil
    }

    func indexOfLast(target: String) -> Int? {
        let range = (self as NSString).range(of: target, options: NSString.CompareOptions.backwards)
        if range.location != NSNotFound {
            return range.location
        }
        return nil
    }

    // MARK: Replace in Formatted String

    func replaceCharactersOfFormattedStringInRange(_ range: NSRange,
                                                   withString string: String,
                                                   normalizedCharacters: CharacterSet,
                                                   formatting: (String) -> String) -> (formatterString: String, normalizedOffset: Int) {
        var removingOneCharacter: Bool {
            return string == "" && range.length == 1
        }

        /* Implementation */

        let formattedString = self

        let normalizedString = formattedString.normalizeWithCharacters(normalizedCharacters)
        let normalizedReplacementString = string.normalizeWithCharacters(normalizedCharacters)
        let normalizedRange = String.normalizedRangeFromRange(range,
                                                              formattedString: formattedString,
                                                              normalizedCharacters: normalizedCharacters,
                                                              removingOneCharacter: removingOneCharacter
        )

        let newNormalizedString = (normalizedString as NSString) // casting so we can work with NSRange
            .replacingCharacters(in: normalizedRange, with: normalizedReplacementString)

        let newFormattedString = formatting(newNormalizedString)

        return (newFormattedString, normalizedRange.location + normalizedReplacementString.count)
    }

    /// Strips non-normalizedPhoneCharacters from the string.
    private func normalizeWithCharacters(_ normalizedCharacters: CharacterSet) -> String {
        return String(unicodeScalars.filter(normalizedCharacters.contains))
    }

    /**
     Converts range within formatted string to a range within normalized string.
     
     - Parameters:
     - range: Range within formatted string.
     - formattedString: String which contains formatting characters.
     - normalizedCharacters: Characters which can be used for constructing normalized string.
     - removingOneCharacter: Flag which specifies whether logic should be adjusted for the case of removing one character.
     
     - Returns: Normalized range, which can be used on the normalized version of formattedString.
     */
    private static func normalizedRangeFromRange(_ range: NSRange,
                                                 formattedString: String,
                                                 normalizedCharacters: CharacterSet,
                                                 removingOneCharacter: Bool) -> NSRange {
        assert(!(range.length > 1 && removingOneCharacter), "Invalid arguments range & removingOneCharacter!")

        func numberOfFormattingCharactersInString(_ string: String) -> Int {
            return string.reduce(0) { counter, character in
                return character.unicodeScalars.filter(normalizedCharacters.contains).isNotEmpty ? counter : counter + 1
            }
        }

        /* Implementation */

        let nsFormattedString = formattedString as NSString // casting so we can work with NSRange
        let stringBefore = nsFormattedString.substring(to: range.location)
        let stringToReplace = nsFormattedString.substring(with: range)

        let numberOfFormattingCharactersBeforeRange = numberOfFormattingCharactersInString(stringBefore)
        let numberOfFormattingCharactersInRange = numberOfFormattingCharactersInString(stringToReplace)

        var normalizedRange = NSRange(
            location: range.location - numberOfFormattingCharactersBeforeRange,
            length: range.length - numberOfFormattingCharactersInRange
        )

        if removingOneCharacter {
            // If the character that is being removed is a formatting character, we apply additional shift
            // to range's location in order to remove the non-formatting character(digit). Unless it's the last character.
            normalizedRange.location -= normalizedRange.location != 0 ? numberOfFormattingCharactersInRange : 0
            // When we are removing one character, we want to preserve range's length(so the deletion actually happens).
            // We add numberOfFormattingCharactersInRange, which we subtracted earlier. Unless there are no characters to delete.
            let hasCharacterToDelete = (stringBefore.count - numberOfFormattingCharactersBeforeRange) > 0
            normalizedRange.length += hasCharacterToDelete ? numberOfFormattingCharactersInRange : 0
        }

        return normalizedRange
    }

    func sizeWithFont(_ font: UIFont, constrainedSize: CGSize) -> CGSize {
        let attributes = [NSAttributedString.Key.font: font]
        let bounds = (self as NSString).boundingRect(with: constrainedSize,
                                                             options: [.usesLineFragmentOrigin, .usesFontLeading],
                                                             attributes: attributes,
                                                             context: nil)

        return CGSize(width: ceil(bounds.width), height: ceil(bounds.height))
    }

    func capitalizedFirst() -> String {
        guard isNotEmpty else { return self }
        let first = self[self.startIndex ..< self.index(startIndex, offsetBy: 1)]
        let rest = self[self.index(startIndex, offsetBy: 1) ..< self.endIndex]
        return first.uppercased() + rest.lowercased()
    }

    func urlStringWithParams(_ params: [String: Any]) -> String {
        guard let queryString = params.queryString else { return self }

        return self + (self.range(of: "?") == nil ? "?" : "&") + queryString
    }

    func wrapWithForcedLTR() -> String {
        return "\(Self.directionChangeStart)\(self)\(Self.directionChangeEnd)"
    }

    func wrapDirection() -> String {
        return UIView.isLTR ? "\u{200E}\(self)" : "\u{200F}\(self)"
    }
}

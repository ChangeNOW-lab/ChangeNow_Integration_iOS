//
//  ValidationRulePhone.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 20/09/16.
//  Copyright © 2016 Pavel Pronin. All rights reserved.
//

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
private func < <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
private func > <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

struct ValidationRulePhone: ValidationRule {

    typealias InputType = String

    let failureError: ValidationErrorType

    init(failureError: ValidationErrorType) {
        self.failureError = failureError
    }

    private let pattern = "^\\+?\\d+(-\\d+)*$"
    private let maximumCharactersCount = 15
    private let minimumCharactersCount = 5

    func validateInput(_ input: String?) -> Bool {
        guard !(input ?? "").isEmpty else { return true }

        let regexResult = NSPredicate(format: "SELF MATCHES %@", pattern).evaluate(with: input)
        return regexResult && input?.count < maximumCharactersCount && input?.count > minimumCharactersCount
    }

    func possibleToBecomeValid(_ input: InputType?) -> Bool {
        return (NSPredicate(format: "SELF MATCHES %@", pattern).evaluate(with: input) && input?.count < maximumCharactersCount) || (input ?? "").isEmpty
    }
}

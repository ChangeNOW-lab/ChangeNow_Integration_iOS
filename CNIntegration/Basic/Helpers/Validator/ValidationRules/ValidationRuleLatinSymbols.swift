//
//  ValidationRuleLatinSymbols.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 20/09/16.
//  Copyright © 2016 Pavel Pronin. All rights reserved.
//

struct ValidationRuleLatinSymbols: ValidationRule {

    typealias InputType = String

    let pattern = "^[A-Za-z]+([A-Za-z\\s-.]+[A-Za-z\\s])?$"
    let failureError: ValidationErrorType

    init(failureError: ValidationErrorType) {
        self.failureError = failureError
    }

    func validateInput(_ input: String?) -> Bool {
        return NSPredicate(format: "SELF MATCHES %@", pattern).evaluate(with: input) || (input ?? "").isEmpty
    }
}

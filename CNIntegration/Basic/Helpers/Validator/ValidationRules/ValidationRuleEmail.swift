//
//  ValidationRuleEmail.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 02/03/17.
//  Copyright © 2017 Pavel Pronin. All rights reserved.
//

import Foundation

struct ValidationRuleEmail: ValidationRule {

    typealias InputType = String

    let pattern = "^[_A-Za-z0-9-+]+(\\.[_A-Za-z0-9-+]+)*@[A-Za-z0-9-]+(\\.[A-Za-z0-9-]+)*(\\.[A-Za-z‌​]{2,})$"
    let possibleToBecomeValidPattern = "[A-Z0-9a-z._%+-@]*"

    let failureError: ValidationErrorType

    init(failureError: ValidationErrorType) {
        self.failureError = failureError
    }

    func validateInput(_ input: String?) -> Bool {
        return (input ?? "").isEmpty || NSPredicate(format: "SELF MATCHES %@", pattern).evaluate(with: input)
    }

    func possibleToBecomeValid(_ input: InputType?) -> Bool {
        return (input ?? "").isEmpty || NSPredicate(format: "SELF MATCHES %@", possibleToBecomeValidPattern).evaluate(with: input)
    }
}

//
//  ValidationRuleStringEquality.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 20/09/16.
//  Copyright © 2016 Pavel Pronin. All rights reserved.
//

struct ValidationRuleStringEquality: ValidationRule {

    typealias InputType = String

    let target: InputType
    let dynamicTarget : (() -> InputType)?
    let failureError: ValidationErrorType

    init(target: InputType, failureError: ValidationErrorType) {
        self.target = target
        self.failureError = failureError
        self.dynamicTarget = nil
    }

    init(dynamicTarget: @escaping (() -> InputType), failureError: ValidationErrorType) {
        self.target = dynamicTarget()
        self.dynamicTarget = dynamicTarget
        self.failureError = failureError
    }

    func validateInput(_ input: InputType?) -> Bool {
        if let dT = dynamicTarget {
            return input == dT()
        }

        return input == target
    }

    func possibleToBecomeValid(_ input: InputType?) -> Bool {
        guard let input = input else { return true }

        let resultTarget: String
        if let dT = dynamicTarget?() {
            resultTarget = dT
        } else {
            resultTarget = target
        }

        if input.count < resultTarget.count {

            let resultTargetSubstring = String(resultTarget[..<input.endIndex])
            return resultTargetSubstring == input
        }

        return false
    }
}

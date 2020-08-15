//
//  ValidationRuleRequiredIfDependenceRequired.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 03/03/17.
//  Copyright © 2017 Pavel Pronin. All rights reserved.
//

struct ValidationRuleRequiredIfDependenceRequired: ValidationRule {
    
    typealias InputType = String
    
    let dependOnRequiredInput: (() -> String?)
    
    let failureError: ValidationErrorType
    
    init(dependOnRequiredInput: @escaping (() -> String?),
         failureError: ValidationErrorType) {
        self.dependOnRequiredInput = dependOnRequiredInput
        self.failureError = failureError
    }
    
    func validateInput(_ input: String?) -> Bool {
        guard let dependOnRequiredInput = self.dependOnRequiredInput(), !dependOnRequiredInput.isEmpty else { return true }
        
        return !(input ?? "").isEmpty
    }
    
    func possibleToBecomeValid(_ input: InputType?) -> Bool {
        return (input ?? "").isEmpty
    }
}

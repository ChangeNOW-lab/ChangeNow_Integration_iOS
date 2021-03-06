/*

 ValidationRuleSet.swift
 Validator

 Created by @adamwaite.

 Copyright (c) 2015 Adam Waite. All rights reserved.

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.

*/

struct ValidationRuleSet<InputType> {

    init() {

    }

    init<R: ValidationRule>(rules: [R]) where R.InputType == InputType {
        self.rules = rules.map(AnyValidationRule.init)
    }

    internal var rules = [AnyValidationRule<InputType>]()

    mutating func addRule<R: ValidationRule>(_ rule: R) where R.InputType == InputType {
        let anyRule = AnyValidationRule(base: rule)
        rules.append(anyRule)
    }

    func possibleToBecomeValid(_ input: InputType?) -> Bool {
        return rules.map { $0.possibleToBecomeValid(input) }.all { $0 == true }
    }

    func validateInput(_ input: InputType?) -> Bool {
        return rules.map { $0.validateInput(input) }.all { $0 == true }
    }
}

//
//  CurrencyValidationRule.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 24.04.2020.
//  Copyright © 2020 proninps. All rights reserved.
//

struct CurrencyValidationRule: ValidationRule {

    typealias InputType = String

    var failureError: ValidationErrorType {
        if let extraId = extraId, extraId.isNotEmpty {
            return CurrencyValidationRuleError.invalidExtraId(extraIdName: extraId)
        } else {
            return CurrencyValidationRuleError.invalidAddress(ticker: ticker)
        }
    }

    private let ticker: String
    private let extraId: String?
    private let validatorService: ValidatorService

    private var isExtraId: Bool {
        if let extraId = extraId, extraId.isNotEmpty {
            return true
        }
        return false
    }

    init(ticker: String, extraId: String?, validatorService: ValidatorService) {
        self.ticker = ticker
        self.extraId = extraId
        self.validatorService = validatorService
    }

    func validateInput(_ input: String?) -> Bool {
        guard let input = input else {
            return false
        }
        do {
            if isExtraId {
                return try validatorService.isValid(ticker: ticker, extraId: input)
            } else {
                return try validatorService.isValid(ticker: ticker, address: input)
            }
        } catch {
            if let error = error as? ValidatorServiceError,
                error == ValidatorServiceError.regExNotFound {
                return true
            }
            return false
        }
    }

    func possibleToBecomeValid(_ input: InputType?) -> Bool {
        return true
    }
}

enum CurrencyValidationRuleError: ValidationErrorType {

    case invalidExtraId(extraIdName: String)
    case invalidAddress(ticker: String)
    case regexNotFound

    var name: String {
        switch self {
        case .invalidExtraId:
            return "invalidExtraId"
        case .invalidAddress:
            return "invalidAddress"
        case .regexNotFound:
            return "regexNotFound"
        }
    }

    var message: String {
        switch self {
        case let .invalidExtraId(extraIdName):
            return R.string.localizable.currencyValidationRuleErrorInvalidExtraId(extraIdName)
        case let .invalidAddress(ticker):
            return R.string.localizable.currencyValidationRuleErrorInvalidAddress(ticker.uppercased())
        case .regexNotFound:
            return R.string.localizable.currencyValidationRuleErrorRegexNotFound()
        }
    }
}

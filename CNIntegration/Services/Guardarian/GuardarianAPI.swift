//
//  GuardarianAPI.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 21.08.2020.
//  Copyright © 2020 Pavel Pronin. All rights reserved.
//

import Moya

enum GuardarianAPI {
    case estimate(cryptoCurrency: String, fiatCurrency: String, fiatAmount: Decimal)
    case transaction(cryptoCurrency: String, fiatCurrency: String, fiatAmount: Decimal, payoutAddress: String)
}

extension GuardarianAPI: TargetType {

    var baseURL: URL {
        return URL(string: Guardarian.apiBaseURL)!
    }
    var path: String {
        switch self {
        case .estimate:
            return "/v1/estimate"
        case .transaction:
            return "/v1/transaction"
        }
    }
    var method: Moya.Method {
        switch self {
        case .estimate:
            return .get
        case .transaction:
            return .post
        }
    }
    var task: Task {
        switch self {
        case let .estimate(cryptoCurrency, fiatCurrency, fiatAmount):
            return .requestParameters(
                parameters: [
                    "crypto_currency": cryptoCurrency,
                    "fiat_currency": fiatCurrency,
                    "fiat_amount": fiatAmount
                ],
                encoding: URLEncoding.queryString
            )
        case let .transaction(cryptoCurrency, fiatCurrency, fiatAmount, payoutAddress):
            return .requestParameters(
                parameters: [
                    "crypto_currency": cryptoCurrency,
                    "fiat_currency": fiatCurrency,
                    "fiat_amount": fiatAmount,
                    "payout_address": payoutAddress
                ],
                encoding: URLEncoding.default
            )
        }
    }
    var sampleData: Data {
        return Data()
    }
    var headers: [String: String]? {
        return ["x-api-key": Guardarian.apiKey]
    }
}

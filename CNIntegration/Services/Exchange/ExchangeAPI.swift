//
//  ExchangeAPI.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 19.04.2020.
//  Copyright © 2020 proninps. All rights reserved.
//

import Moya

enum ExchangeAPI {
    case minAmount(pair: String)
    case exchangeAmount(pair: String, sendAmount: Decimal)
}

extension ExchangeAPI: TargetType {

    var baseURL: URL {
        return URL(string: ChangeNOW.apiBaseURL)!
    }
    var path: String {
        switch self {
        case let .minAmount(pair):
            return "/v1/min-amount/\(pair)"
        case let .exchangeAmount(pair, sendAmount):
            return "/v1/exchange-amount/\(sendAmount)/\(pair)"
        }
    }
    var method: Moya.Method {
        switch self {
        case .minAmount, .exchangeAmount:
            return .get
        }
    }
    var task: Task {
        switch self {
        case .minAmount:
            return .requestPlain
        case .exchangeAmount:
            return .requestParameters(
                parameters: [
                    "api_key": ChangeNOW.apiKey
                ],
                encoding: URLEncoding.queryString
            )
        }
    }
    var sampleData: Data {
        return Data()
    }
    var headers: [String: String]? {
        return ["Content-type": "application/json; charset=utf-8"]
    }
}


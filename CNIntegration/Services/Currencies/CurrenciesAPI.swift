//
//  CurrenciesAPI.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 18.04.2020.
//  Copyright © 2020 proninps. All rights reserved.
//

import Moya

enum CurrenciesAPI {
    case getAll
    case availablePairs
    case amounts
    case anonyms
}

extension CurrenciesAPI: TargetType {

    var baseURL: URL {
        switch self {
        case .getAll, .availablePairs:
            return URL(string: ChangeNOW.apiBaseURL)!
        case .amounts, .anonyms:
            return URL(string: ChangeNOW.apiMobileBaseURL)!
        }
    }
    var path: String {
        switch self {
        case .getAll:
            return "/v1/currencies"
        case .availablePairs:
            return "/v1/market-info/available-pairs"
        case .amounts:
            return "/amounts"
        case .anonyms:
            return "/v2/anonyms"
        }
    }
    var method: Moya.Method {
        switch self {
        case .getAll, .availablePairs, .amounts, .anonyms:
            return .get
        }
    }
    var task: Task {
        switch self {
        case .getAll:
            return .requestPlain
        case .availablePairs:
            return .requestPlain
        case .amounts, .anonyms:
            return .requestPlain
        }
    }
    var sampleData: Data {
        return Data()
    }
    var headers: [String: String]? {
        return ["Content-type": "application/json; charset=utf-8"]
    }
}

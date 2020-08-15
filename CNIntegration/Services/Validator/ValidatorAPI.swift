//
//  ValidatorAPI.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 24.04.2020.
//  Copyright © 2020 proninps. All rights reserved.
//

import Moya

enum ValidatorAPI {
    case getCurrenciesValidationData
}

extension ValidatorAPI: TargetType {

    var baseURL: URL {
        switch self {
        case .getCurrenciesValidationData:
            return URL(string: "https://www.binance.com/assetWithdraw")!
        }
    }
    var path: String {
        switch self {
        case .getCurrenciesValidationData:
            return "/getAllAsset.html"
        }
    }
    var method: Moya.Method {
        switch self {
        case .getCurrenciesValidationData:
            return .get
        }
    }
    var task: Task {
        switch self {
        case .getCurrenciesValidationData:
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

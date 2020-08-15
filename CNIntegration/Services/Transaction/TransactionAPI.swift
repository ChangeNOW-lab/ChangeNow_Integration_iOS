//
//  TransactionAPI.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 26.04.2020.
//  Copyright © 2020 proninps. All rights reserved.
//

import Moya

enum TransactionAPI {
    case create(from: String, to: String, address: String, amount: Decimal, extraId: String)
    case status(id: String)
    case statusMobile(id: String)
}

extension TransactionAPI: TargetType {

    var baseURL: URL {
        switch self {
        case .create, .status:
            return URL(string: ChangeNOW.apiBaseURL)!
        case .statusMobile:
            return URL(string: ChangeNOW.apiMobileBaseURL)!
        }
    }
    var path: String {
        switch self {
        case .create:
            return "/v1/transactions/\(ChangeNOW.apiKey)"
        case let .status(id):
            return "/v1/transactions/\(id)/\(ChangeNOW.apiKey)"
        case .statusMobile:
            return "/tx"
        }
    }
    var method: Moya.Method {
        switch self {
        case .create, .statusMobile:
            return .post
        case .status:
            return .get
        }
    }
    var task: Task {
        switch self {
        case let .create(from, to, address, amount, extraId):
            return .requestParameters(parameters: [
                "from": from,
                "to": to,
                "address": address,
                "amount": "\(amount)",
                "extraId": extraId,
                "refundAddress": "",
                "refundExtraId": "",
                "userId": "",
                "payload": "",
                "contactEmail": ""
            ], encoding: JSONEncoding.default)
        case .status:
            return .requestPlain
        case let .statusMobile(id):
            return .requestParameters(parameters: [
                "id": id,
                "device_id": Device.identifier ?? ""
            ], encoding: URLEncoding.queryString)
        }
    }
    var sampleData: Data {
        return Data()
    }
    var headers: [String: String]? {
        return ["Content-type": "application/json; charset=utf-8"]
    }
}


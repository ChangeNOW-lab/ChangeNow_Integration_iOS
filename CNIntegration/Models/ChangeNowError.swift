//
//  ChangeNowError.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 28.05.2020.
//  Copyright © 2020 proninps. All rights reserved.
//

class ChangeNowError: NSError {

    enum ErrorType: String {
        case notValidAddress = "not_valid_address"
        case unknown
    }

    var type: ErrorType {
        return ErrorType(rawValue: error) ?? .unknown
    }

    var error: String {
        return userInfo["error"] as! String
    }

    var message: String {
        return userInfo["message"] as! String
    }

    init(code: Int, error: String, message: String) {
        super.init(
            domain: "ChangeNOW.NetworkError",
            code: code,
            userInfo: [
                "error": error,
                "message": message
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

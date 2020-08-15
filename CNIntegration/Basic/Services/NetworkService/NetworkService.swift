//
//  NetworkService.swift
//
//  Created by Pavel Pronin on 08/08/2017.
//  Copyright © 2017 Pavel Pronin All rights reserved.
//

import Foundation
import Moya

struct NetworkService {

    private static let queue = DispatchQueue.global(qos: .default)

    // MARK: Types

    typealias Completion = (Result<Moya.Response, MoyaError>) -> Void

    enum AuthType {
        case none
        case standart

        func plugins() -> [PluginType]? {
            switch self {
            case .none:
                return nil
            case .standart:
                return NetworkService.standartPlugins
            }
        }
    }

    // MARK: Variables

    static var standartTokenPlugin: AccessTokenPlugin? {
        guard let token = KeychainStorage.getAccessToken() else { return nil }
        return AccessTokenPlugin(tokenClosure: { _ in
            return token
        })
    }

    static var standartPlugins: [PluginType]? {
        guard let token = standartTokenPlugin else { return [] }
        return [token]
    }

    // MARK: Methods

    static func request<T: TargetType>(target: T, auth: AuthType, completion: @escaping Completion) -> Cancellable {
        let plugins = auth.plugins()
        let provider = plugins != nil ? MoyaProvider<T>(plugins: plugins!) : MoyaProvider<T>()
        let object = provider.request(target, callbackQueue: queue) { (response) in
            NetworkService.validate(response, completion: completion)
        }
        return object
    }

    static func validate(_ response: Result<Moya.Response, MoyaError>, completion: @escaping Completion) {
        var responseError: Error?
        do {
            let result = try response.get()
            if ResponseValidator.isValidCode(result.statusCode) {
                completion(response)
                return
            }
            responseError = NetworkError.errorBy(data: result.data) ?? NetworkError.errorBy(code: result.statusCode)
        } catch {
            responseError = error
        }
        if let error = responseError {
            if let result = try? response.get(),
                let json = try? JSONSerialization.jsonObject(with: result.data, options: []) as? [String: String],
                let errorValue = json["error"],
                let messageValue = json["message"] {
                let resultError = ChangeNowError(code: result.statusCode, error: errorValue, message: messageValue)
                completion(Result.failure(MoyaError.underlying(resultError, nil)))
            } else {
                completion(Result.failure(MoyaError.underlying(error, nil)))
            }
        }
    }
}

struct ResponseValidator {

    /// Response status code validation
    ///
    /// - Parameter code: Status Code
    /// - Returns: Result of validation
    static func isValidCode(_ statusCode: Int) -> Bool {
        guard 200..<300 ~= statusCode else { return false }
        return true
    }

}

enum NetworkError: Swift.Error {

    case unknown
    case badRequest
    case unathorized
    case forbidden
    case notFound
    case requestTimeout
    case unprocessableEntity
    case internalServerError
    case canceled
    case noInternetConnection
    case other(String)
}

extension NetworkError {

    // swiftlint:disable cyclomatic_complexity
    static func errorBy(code: Int) -> NetworkError {
        switch code {
        case -1:
            return .unknown
        case 400:
            return .badRequest
        case 401:
            return .unathorized
        case 403:
            return .forbidden
        case 404:
            return .notFound
        case 408:
            return .requestTimeout
        case 422:
            return .unprocessableEntity
        case 500:
            return .internalServerError
        case -50:
            return .canceled
        case -1_009:
            return .noInternetConnection
        default:
            return .unknown
        }
    }
    // swiftlint:enable cyclomatic_complexity

    static func errorBy(data: Data?) -> NetworkError? {
        guard let json = try? JSONSerialization.jsonObject(with: data ?? Data(), options: []) else { return nil }
        if let `json` = json as? [String: Any] {
            guard let message = json["message"] as? String else { return nil }
            return .other(message)
        } else if let `json` = json as? [Any] {
            for value in json {
                if let `value` = value as? [String: Any], let message = value["message"] as? String {
                    return .other(message)
                }
            }
        }
        return nil
    }

    static func getErrorCodeBy(data: Data?) -> Int? {
        guard let json = try? JSONSerialization.jsonObject(with: data ?? Data(), options: []) as? [String: Any] else {
            return nil
        }
        guard let code = json["code"] as? Int else { return nil }
        return code
    }
}

extension NetworkError: LocalizedError {

    var errorDescription: String? {
        switch self {
        case .unknown, .badRequest, .unathorized, .forbidden, .notFound, .requestTimeout, .unprocessableEntity, .internalServerError, .canceled, .noInternetConnection:
            return "NetworkError: \(String(describing: self).capitalized)"
        case .other(let error):
            return error
        }
    }
}

//
//  ExchangeService.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 19.04.2020.
//  Copyright © 2020 proninps. All rights reserved.
//

import Moya

typealias GetMinimalExchangeAmountCompletion = (Result<Decimal, Error>) -> Void
typealias GetEstimatedExchangeAmountCompletion = (Result<EstimatedExchange, Error>) -> Void

protocol ExchangeService {

    var exchangeData: ExchangeData? { get }

    func set(exchangeData: ExchangeData)

    @discardableResult
    func getMinimalExchangeAmount(pair: String,
                                  completion: GetMinimalExchangeAmountCompletion?) -> Cancellable

    @discardableResult
    func getEstimatedExchangeAmount(pair: String,
                                    sendAmount: Decimal,
                                    completion: GetEstimatedExchangeAmountCompletion?) -> Cancellable
}

final class ExchangeDefaultService: ExchangeService {

    private(set) lazy var exchangeData: ExchangeData? = {
        do {
            return try FileStorage.content(
                from: .documents,
                filename: exchangeDataLocalPath
            )
        } catch {
            log.debug("Failed to load exchange data from storage. Error: \(error)")
        }
        return nil
    }()

    private let exchangeDataLocalPath = Filename(name: "CNExchangeData", fileExtension: .plist)

    // MARK: - Public

    func set(exchangeData: ExchangeData) {
        self.exchangeData = exchangeData
        updateExchangeDataStorage(exchangeData: exchangeData)
    }

    @discardableResult
    func getMinimalExchangeAmount(pair: String, completion: GetMinimalExchangeAmountCompletion?) -> Cancellable {
        return NetworkService.request(target: ExchangeAPI.minAmount(pair: pair), auth: .none) { (response) in
            switch response {
            case let .success(result):
                if let amount = ExchangeDecoder.getMinimalExchangeAmount(data: result.data) {
                    DispatchQueue.main.async {
                        completion?(Result.success(amount))
                    }
                }
            case let .failure(error):
                DispatchQueue.main.async {
                    completion?(Result.failure(error))
                }
            }
        }
    }

    @discardableResult
    func getEstimatedExchangeAmount(pair: String,
                                    sendAmount: Decimal,
                                    completion: GetEstimatedExchangeAmountCompletion?) -> Cancellable {
        if let currencies = GlobalExchange.currencies(pair: pair),
            GlobalExchange.fiat.contains(currencies.0) {
            return NetworkService.request(
                target: GuardarianAPI.estimate(cryptoCurrency: currencies.1,
                                               fiatCurrency: currencies.0,
                                               fiatAmount: sendAmount),
                auth: .none) { (response) in
                    switch response {
                    case let .success(result):
                        if let guardarianExchange = GuardarianDecoder.getGuardarianExchange(data: result.data) {
                            DispatchQueue.main.async {
                                completion?(Result.success(EstimatedExchange(
                                    estimatedAmount: guardarianExchange.estimatedAmount,
                                    transactionSpeedForecast: "",
                                    warningMessage: nil))
                                )
                            }
                        }
                    case let .failure(error):
                        DispatchQueue.main.async {
                            completion?(Result.failure(error))
                        }
                    }
            }
        }
        return NetworkService.request(
            target: ExchangeAPI.exchangeAmount(pair: pair, sendAmount: sendAmount),
            auth: .none) { (response) in
                switch response {
                case let .success(result):
                    if let estimatedExchange = ExchangeDecoder.getEstimatedExchangeAmount(data: result.data) {
                        DispatchQueue.main.async {
                            completion?(Result.success(estimatedExchange))
                        }
                    }
                case let .failure(error):
                    DispatchQueue.main.async {
                        completion?(Result.failure(error))
                    }
                }
        }
    }

    // MARK: - Private

    private func updateExchangeDataStorage(exchangeData: ExchangeData) {
        do {
            try FileStorage.store(objects: exchangeData,
                                                 to: .documents,
                                                 as: exchangeDataLocalPath)
        } catch {
            log.error("Failed to save exchange data to storage. Error: \(error)")
        }
    }
}

//
//  TransactionService.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 18.04.2020.
//  Copyright © 2020 proninps. All rights reserved.
//

import Moya

typealias GetFiatTransactionCompletion = (Result<GuardarianTransactionData, Error>) -> Void
typealias GetTransactionCompletion = (Result<TransactionData, Error>) -> Void
typealias GetTransactionStatusCompletion = (Result<TransactionStatusData, Error>) -> Void

protocol TransactionService {

    var transactionStatusData: TransactionStatusData? { get }

    func removeTransaction()

    @discardableResult
    func createFiatTransaction(from: String,
                               to: String,
                               address: String,
                               amount: Decimal,
                               extraId: String,
                               completion: GetFiatTransactionCompletion?) -> Cancellable

    @discardableResult
    func createTransaction(from: String,
                           to: String,
                           address: String,
                           amount: Decimal,
                           extraId: String,
                           completion: GetTransactionCompletion?) -> Cancellable

    @discardableResult
    func getTransactionStatus(id: String,
                              completion: GetTransactionStatusCompletion?) -> Cancellable
}

final class TransactionDefaultService: TransactionService {

    private(set) lazy var transactionStatusData: TransactionStatusData? = {
        do {
            return try FileStorage.content(
                from: .documents,
                filename: transactionStatusDataLocalPath
            )
        } catch {
            log.debug("Failed to load transaction status data data from storage. Error: \(error)")
        }
        return nil
    }()

    private let transactionStatusDataLocalPath = Filename(name: "CNTransactionStatusData", fileExtension: .plist)

    // MARK: - Public

    func removeTransaction() {
        transactionStatusData = nil
        try? FileStorage.remove(from: .documents, filename: transactionStatusDataLocalPath)
    }

    @discardableResult
    func createFiatTransaction(from: String,
                               to: String,
                               address: String,
                               amount: Decimal,
                               extraId: String,
                               completion: GetFiatTransactionCompletion?) -> Cancellable {
        return NetworkService.request(
            target: GuardarianAPI.transaction(cryptoCurrency: to,
                                              fiatCurrency: from,
                                              fiatAmount: amount,
                                              payoutAddress: address),
            auth: .none) { (response) in
                switch response {
                case let .success(result):
                    if let transaction = GuardarianDecoder.getGuardarianTransaction(data: result.data) {
                        DispatchQueue.main.async {
                            completion?(Result.success(transaction))
                        }
                    }
                case let .failure(error):
                    DispatchQueue.main.async {
                        if case MoyaError.underlying(let error, _) = error {
                            completion?(Result.failure(error))
                        } else {
                            completion?(Result.failure(error))
                        }
                    }
                }
        }
    }

    @discardableResult
    func createTransaction(from: String,
                           to: String,
                           address: String,
                           amount: Decimal,
                           extraId: String,
                           completion: GetTransactionCompletion?) -> Cancellable {
        return NetworkService.request(
            target: TransactionAPI.create(from: from,
                                          to: to,
                                          address: address,
                                          amount: amount,
                                          extraId: extraId),
            auth: .none) { (response) in
                switch response {
                case let .success(result):
                    if let transaction = TransactionDecoder.getTransactionData(data: result.data) {
                        DispatchQueue.main.async {
                            completion?(Result.success(transaction))
                        }
                    }
                case let .failure(error):
                    DispatchQueue.main.async {
                        if case MoyaError.underlying(let error, _) = error {
                            completion?(Result.failure(error))
                        } else {
                            completion?(Result.failure(error))
                        }
                    }
                }
        }
    }

    @discardableResult
    func getTransactionStatus(id: String,
                              completion: GetTransactionStatusCompletion?) -> Cancellable {
        return NetworkService.request(
            target: TransactionAPI.status(id: id),
            auth: .none) { [weak self] (response) in
                switch response {
                case let .success(result):
                    if let transactionStatusData = TransactionDecoder.getTransactionStatusData(data: result.data) {
                        self?.updateTransactionStatusData(transactionStatusData: transactionStatusData)
                        DispatchQueue.main.async {
                            completion?(Result.success(transactionStatusData))
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

    private func updateTransactionStatusData(transactionStatusData: TransactionStatusData) {
        do {
            try FileStorage.store(objects: transactionStatusData,
                                                 to: .documents,
                                                 as: transactionStatusDataLocalPath)
        } catch {
            log.error("Failed to save exchange data to storage. Error: \(error)")
        }
    }
}


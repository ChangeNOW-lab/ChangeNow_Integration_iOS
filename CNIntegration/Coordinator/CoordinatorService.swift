//
//  CoordinatorService.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 12/07/2017.
//  Copyright © 2017 Pavel Pronin All rights reserved.
//

protocol CoordinatorService {

    @discardableResult
    func showMainScreen() -> UIViewController
    @discardableResult
    func showExchangeScreen() -> UIViewController
    @discardableResult
    func showTransactionScreen(transaction: TransactionStatusData,
                               isNeedReload: Bool) -> UIViewController

    func showGuardarianTransaction(url: URL,
                                   fromCurrencyTicker: String,
                                   toCurrencyTicker: String)
    func showScannerScreen(delegate: ScannerDelegate?)
    func showChooseCurrencyScreen(fromCurrencyTicker: String,
                                  toCurrencyTicker: String,
                                  selectedState: ChooseCurrencyState,
                                  exchangeType: ExchangeType,
                                  delegate: ChooseCurrencyDelegate?)

    func dismiss()
    func prepareStart(viewController: UIViewController)
    func prepareStop(viewController: UIViewController)
}

extension CoordinatorService {

    @discardableResult
    func showTransactionScreen(transaction: TransactionStatusData) -> UIViewController {
        return showTransactionScreen(transaction: transaction, isNeedReload: false)
    }
}

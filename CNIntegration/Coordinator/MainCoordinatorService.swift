//
//  MainCoordinatorService.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 26.07.2020.
//  Copyright © 2020 Pavel Pronin. All rights reserved.
//

final class MainCoordinatorService: CoordinatorService {

    @Injected private var transactionService: TransactionService

    private lazy var defaultCoordinatorService = DefaultCoordinatorService(exchangeType: exchangeType)

    private var window: UIWindow? {
        return UIApplication.shared.delegate?.window ?? UIWindow()
    }

    private let scope: AnyObject
    private let exchangeType: ExchangeType

    init(scope: AnyObject, exchangeType: ExchangeType) {
        self.scope = scope
        self.exchangeType = exchangeType
    }

    // MARK: - Navigation

    @discardableResult
    func showMainScreen() -> UIViewController {
        if let transaction = transactionService.transactionStatusData {
            return showTransactionScreen(transaction: transaction, isNeedReload: true)
        } else {
            return showExchangeScreen()
        }
    }

    @discardableResult
    func showExchangeScreen() -> UIViewController {
        let newVC = ExchangeViewController(exchangeType: exchangeType,
                                           isInNavigationStack: false)
        if window?.rootViewController == nil {
            window?.rootViewController = newVC
            window?.makeKeyAndVisible()
        } else {
            window?.set(rootViewController: newVC)
        }
        return newVC
    }

    @discardableResult
    func showTransactionScreen(transaction: TransactionStatusData, isNeedReload: Bool = false) -> UIViewController {
        let newVC = TransactionViewController(transaction: transaction,
                                              isInNavigationStack: false,
                                              isNeedReload: isNeedReload)
        if window?.rootViewController == nil {
            window?.rootViewController = newVC
            window?.makeKeyAndVisible()
        } else {
            window?.set(rootViewController: newVC)
        }
        return newVC
    }

    func showScannerScreen(delegate: ScannerDelegate?) {
        defaultCoordinatorService.showScannerScreen(delegate: delegate)
    }

    func showChooseCurrencyScreen(fromCurrencyTicker: String,
                                  toCurrencyTicker: String,
                                  selectedState: ChooseCurrencyState,
                                  exchangeType: ExchangeType,
                                  delegate: ChooseCurrencyDelegate?) {
        defaultCoordinatorService.showChooseCurrencyScreen(fromCurrencyTicker: fromCurrencyTicker,
                                                           toCurrencyTicker: toCurrencyTicker,
                                                           selectedState: selectedState,
                                                           exchangeType: exchangeType,
                                                           delegate: delegate)
    }

    func dismiss() { }
}

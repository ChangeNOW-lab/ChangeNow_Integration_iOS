//
//  EmbedCoordinatorService.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 27.07.2020.
//  Copyright © 2020 Pavel Pronin. All rights reserved.
//

final class EmbedCoordinatorService: CoordinatorService {

    @Injected private var transactionService: TransactionService

    private lazy var defaultCoordinatorService = DefaultCoordinatorService(exchangeType: exchangeType)

    private var window: UIWindow? {
        return UIApplication.shared.delegate?.window ?? UIWindow()
    }

    private weak var mainViewController: UIViewController?

    private let moduleManager: ModuleManager
    private let exchangeType: ExchangeType

    init(moduleManager: ModuleManager, exchangeType: ExchangeType) {
        self.moduleManager = moduleManager
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
        let viewController = ExchangeViewController(exchangeType: exchangeType,
                                                    isInNavigationStack: false)
        showRoot(viewController: viewController)
        return viewController
    }

    @discardableResult
    func showTransactionScreen(transaction: TransactionStatusData, isNeedReload: Bool = false) -> UIViewController {
        let viewController = TransactionViewController(transaction: transaction,
                                                       isInNavigationStack: false,
                                                       isNeedReload: isNeedReload)
        showRoot(viewController: viewController)
        return viewController
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

    func dismiss() {
        
    }

    func prepareStart(viewController: UIViewController) {
        if let navVC = viewController.navigationController {
            navVC.setNavigationBarHidden(true, animated: false)
        }
    }

    func prepareStop(viewController: UIViewController) {
        if mainViewController == nil {
            moduleManager.stop()
        }
    }

    // MARK: - Private

    private func showRoot(viewController: UIViewController) {
        if let currentViewController = mainViewController {
            if let rootController = currentViewController.parent as? UINavigationController {
                rootController.setViewControllers([viewController], animated: true)
            } else if let rootController = currentViewController.parent as? UITabBarController {
                var viewControllers = rootController.viewControllers ?? []
                if let index = viewControllers.firstIndex(where: {
                    $0 is TransactionViewController || $0 is ExchangeViewController
                }) {
                    viewControllers[index] = viewController
                }
                rootController.setViewControllers(viewControllers, animated: true)
            }
        }
        mainViewController = viewController
    }

    // MARK: - Private

    private func currentViewController() -> UIViewController? {
        return UIApplication.topViewController()
    }
}

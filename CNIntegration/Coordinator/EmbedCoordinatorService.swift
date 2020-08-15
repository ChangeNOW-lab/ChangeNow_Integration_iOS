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
        let viewController = ExchangeViewController(exchangeType: exchangeType,
                                                    isInNavigationStack: false)
        showRootIfNeeded(viewController: viewController)
        return viewController
    }

    @discardableResult
    func showTransactionScreen(transaction: TransactionStatusData, isNeedReload: Bool = false) -> UIViewController {
        let viewController = TransactionViewController(transaction: transaction,
                                                       isInNavigationStack: false,
                                                       isNeedReload: isNeedReload)
        showRootIfNeeded(viewController: viewController)
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

    // MARK: - Private

    private func showRootIfNeeded(viewController: UIViewController) {
        let currentViewController = self.currentViewController()
        if currentViewController is TransactionViewController || currentViewController is ExchangeViewController {
            if let rootController = currentViewController?.parent as? UINavigationController {
                rootController.setViewControllers([viewController], animated: true)
            } else if let rootController = currentViewController?.parent as? UITabBarController {
                var viewControllers = rootController.viewControllers ?? []
                if let index = viewControllers.firstIndex(where: {
                    $0 is TransactionViewController || $0 is ExchangeViewController
                }) {
                    viewControllers[index] = viewController
                }
                rootController.setViewControllers(viewControllers, animated: true)
            }
        }
    }

    private func pushAnimation() {
        let transition = CATransition()
        transition.duration = 0.5
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromRight
        transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
        window?.layer.add(transition, forKey: kCATransition)
    }

    // MARK: - Private

    private func currentViewController() -> UIViewController? {
        return UIApplication.topViewController()
    }
}

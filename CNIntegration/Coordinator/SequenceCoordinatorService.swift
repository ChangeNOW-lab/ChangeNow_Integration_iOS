//
//  SequenceCoordinatorService.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 26.07.2020.
//  Copyright © 2020 Pavel Pronin. All rights reserved.
//

final class SequenceCoordinatorService: CoordinatorService {

    @Injected private var transactionService: TransactionService

    private lazy var defaultCoordinatorService = DefaultCoordinatorService(exchangeType: exchangeType)

    private var window: UIWindow? {
        return UIApplication.shared.delegate?.window ?? UIWindow()
    }

    private weak var mainViewController: UIViewController?
    private var isNavigationBarHidden: Bool?

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
                                                    isInNavigationStack: true)
        showRoot(viewController: viewController)
        return viewController
    }

    @discardableResult
    func showTransactionScreen(transaction: TransactionStatusData, isNeedReload: Bool = false) -> UIViewController {
        let viewController = TransactionViewController(transaction: transaction,
                                                       isInNavigationStack: true,
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
        if let mainViewController = mainViewController {
            if let parentVC = mainViewController.parent as? UINavigationController {
                parentVC.popViewController(animated: true)
                if let isNavigationBarHidden = isNavigationBarHidden {
                    parentVC.setNavigationBarHidden(isNavigationBarHidden, animated: false)
                }
            } else {
                mainViewController.dismiss(animated: true, completion: nil)
            }
        } else {
            log.error("Unknown navigation state")
        }
    }

    func prepareStart(viewController: UIViewController) {
        if isNavigationBarHidden == nil,
            let navVC = viewController.navigationController {
            isNavigationBarHidden = navVC.isNavigationBarHidden
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
        viewController.hidesBottomBarWhenPushed = true
        if let mainViewController = mainViewController {
            if let parentVC = mainViewController.parent as? UINavigationController {
                var viewControllers = parentVC.viewControllers
                if let index = viewControllers.firstIndex(where: {
                    $0 is TransactionViewController || $0 is ExchangeViewController
                }) {
                    viewControllers[index] = viewController
                }
                self.mainViewController = viewController
                parentVC.setViewControllers(viewControllers, animated: true)
            } else if let parentVC = mainViewController.presentingViewController {
                self.mainViewController = viewController
                parentVC.presentedViewController?.dismiss(animated: true, completion: { [weak parentVC] in
                    parentVC?.present(viewController, animated: true, completion: nil)
                })
            } else {
                log.error("Unknown navigation state")
            }
        } else {
            mainViewController = viewController
        }
    }

    // MARK: - Private

    private func currentViewController() -> UIViewController? {
        return UIApplication.topViewController()
    }
}

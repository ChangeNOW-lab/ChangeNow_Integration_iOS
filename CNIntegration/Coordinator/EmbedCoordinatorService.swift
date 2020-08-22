//
//  EmbedCoordinatorService.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 27.07.2020.
//  Copyright © 2020 Pavel Pronin. All rights reserved.
//

final class EmbedCoordinatorService: DefaultCoordinatorService, CoordinatorService {

    @Injected private var transactionService: TransactionService

    private var window: UIWindow? {
        return UIApplication.shared.delegate?.window ?? UIWindow()
    }

    private weak var mainViewController: UIViewController?

    private let moduleManager: ModuleManager

    init(moduleManager: ModuleManager, exchangeType: ExchangeType) {
        self.moduleManager = moduleManager
        super.init(exchangeType: exchangeType)
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
}

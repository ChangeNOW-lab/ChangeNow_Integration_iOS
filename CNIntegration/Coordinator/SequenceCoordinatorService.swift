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

    private var startedViewController: UIViewController?
    private var startedNavBarIsHidden: Bool?

    private let scope: AnyObject
    private let exchangeType: ExchangeType
    private let dismissAction: Action

    init(scope: AnyObject, exchangeType: ExchangeType, dismissAction: Action) {
        self.scope = scope
        self.exchangeType = exchangeType
        self.dismissAction = dismissAction
        self.startedViewController = UIApplication.topViewController()
        self.startedNavBarIsHidden = self.startedViewController?.navigationController?.navigationBar.isHidden
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
        if let navigationController = startedViewController?.navigationController {
            var viewControllers = navigationController.viewControllers
            viewControllers.removeAll(where: {
                $0 is TransactionViewController || $0 is ExchangeViewController
            })
            navigationController.setNavigationBarHidden(startedNavBarIsHidden ?? false, animated: false)
            navigationController.setViewControllers(viewControllers, animated: true)
        } else {
            startedViewController?.presentedViewController?.dismiss(animated: true, completion: { [weak self] in
                self?.dismissAction.perform()
            })
        }
    }

    // MARK: - Private

    private func showRoot(viewController: UIViewController) {
        if let navigationController = startedViewController?.navigationController {
            var viewControllers = navigationController.viewControllers
            viewControllers.removeAll(where: {
                $0 is TransactionViewController || $0 is ExchangeViewController
            })
            viewControllers.append(viewController)
            viewController.hidesBottomBarWhenPushed = true
            navigationController.setNavigationBarHidden(true, animated: false)
            navigationController.setViewControllers(viewControllers, animated: true)
        } else {
            if startedViewController?.presentedViewController != nil {
                startedViewController?.presentedViewController?.dismiss(animated: false, completion: nil)
            }
            viewController.modalPresentationStyle = .fullScreen
            pushAnimation(on: startedViewController?.view)
            startedViewController?.present(viewController,
                                           animated: false,
                                           completion: nil)
        }
    }

    private func pushAnimation(on view: UIView?) {
        let transition = CATransition()
        transition.duration = 0.5
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromRight
        transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
        view?.layer.add(transition, forKey: kCATransition)
    }

    // MARK: - Private

    private func currentViewController() -> UIViewController? {
        return UIApplication.topViewController()
    }
}

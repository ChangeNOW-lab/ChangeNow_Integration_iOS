//
//  DefaultCoordinatorService.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 27.07.2020.
//  Copyright © 2020 Pavel Pronin. All rights reserved.
//

class DefaultCoordinatorService {

    let exchangeType: ExchangeType

    init(exchangeType: ExchangeType) {
        self.exchangeType = exchangeType
    }

    // MARK: - Navigation

    func showGuardarianTransaction(url: URL,
                                   fromCurrencyTicker: String,
                                   toCurrencyTicker: String) {
        let newVC = WebViewController(
            url: url,
            title: R.string.localizable.transactionTitle(fromCurrencyTicker.uppercased(),
                                                         toCurrencyTicker.uppercased())
        )
        let navVC = ConfigurableNavigationController(rootViewController: newVC)
        navVC.modalPresentationStyle = .fullScreen
        currentViewController()?.present(navVC, animated: true, completion: nil)
    }

    func showScannerScreen(delegate: ScannerDelegate?) {
        let newVC = ScannerViewController()
        newVC.delegate = delegate
        currentViewController()?.present(newVC, animated: true, completion: nil)
    }

    func showChooseCurrencyScreen(fromCurrencyTicker: String,
                                  toCurrencyTicker: String,
                                  selectedState: ChooseCurrencyState,
                                  exchangeType: ExchangeType,
                                  delegate: ChooseCurrencyDelegate?) {
        let newVC = ChooseCurrencyViewController(fromCurrencyTicker: fromCurrencyTicker,
                                                 toCurrencyTicker: toCurrencyTicker,
                                                 selectedState: selectedState,
                                                 exchangeType: exchangeType)
        newVC.delegate = delegate
        if #available(iOS 13.0, *) {
            newVC.modalPresentationStyle = .automatic
        } else {
            newVC.modalPresentationStyle = .overCurrentContext
        }
        currentViewController()?.present(newVC, animated: true, completion: nil)
    }

    func currentViewController() -> UIViewController? {
        return UIApplication.topViewController()
    }
}

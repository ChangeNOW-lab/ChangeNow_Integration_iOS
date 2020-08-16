//
//  CNModule.swift
//  CNModule
//
//  Created by Pavel Pronin on 26.07.2020.
//  Copyright © 2020 Pavel Pronin. All rights reserved.
//

import Resolver

protocol ModuleManager: AnyObject {
    func stop()
}

public class CNModule: ModuleManager {

    private weak var resolverScopeCache: ResolverScopeCache?

    public init(apiKey: String,
                theme: Theme? = nil,
                navigationType: NavigationType = .main,
                exchangeType: ExchangeType = .any,
                languageCode: String? = nil) {
        ChangeNOW.apiKey = apiKey
        if let theme = theme {
            ThemeManager.current = theme
        }
        configureLanguage(languageCode: languageCode)
        configureAppearance()
        configureDependencies(navigationType: navigationType, exchangeType: exchangeType)
    }

    @discardableResult
    public func start() -> UIViewController {
        #if DEBUG
        return Resolver.main.resolve(CoordinatorService.self).showMainScreen()
//        return Resolver.main.resolve(CoordinatorService.self).showTransactionScreen(
//            transaction: TransactionStatusData(
//                id: "90c5866d162c6",
//                status: "new",
//                fromCurrency: "usdterc20",
//                toCurrency: "eth",
//                expectedSendAmount: 0.1,
//                expectedReceiveAmount: 4.925642323,
//                amountSend: nil,
//                amountReceive: nil,
//                payinAddress: "32XW9v9kC4jj9KkL3FDR3ua9Lsp2WGQ6HT",
//                payinExtraId: nil,
//                payoutAddress: "32XW9v9kC4jj9KkL3FDR3ua9Lsp2WGQ6HT",
//                payoutExtraId: nil,
//                payoutExtraIdName: nil,
//                refundAddress: nil,
//                refundExtraId: nil),
//            isNeedReload: true
//        )
        #else
        return Resolver.main.resolve(CoordinatorService.self).showMainScreen()
        #endif
    }

    func stop() {
        resolverScopeCache?.reset()
    }

    // MARK: - Private

    private func configureLanguage(languageCode: String?) {
        let locale = Bundle.updateLanguage(languageCode: languageCode, tableName: "Localizable")
        if ChangeNOW.isOriginalApp {
            if let languageCode = locale.languageCode {
                let direction = Locale.characterDirection(forLanguage: languageCode)
                switch direction {
                case .leftToRight, .bottomToTop, .topToBottom, .unknown:
                    UIView.appearance().semanticContentAttribute = .forceLeftToRight
                case .rightToLeft:
                    UIView.appearance().semanticContentAttribute = .forceRightToLeft
                @unknown default:
                    log.error("Unknown state")
                }
            }
        }
    }

    private func configureAppearance() {
        let navBarAppearance = UINavigationBar.appearance(whenContainedInInstancesOf: [ConfigurableNavigationController.self])
        navBarAppearance.isTranslucent = false
        navBarAppearance.shadowImage = UIImage()
        navBarAppearance.tintColor = .white
        navBarAppearance.barTintColor = .background
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white,
                                                .font: UIFont.bigHeadline]
    }

    private func configureDependencies(navigationType: NavigationType,
                                       exchangeType: ExchangeType) {
        let resolver = Resolver.main
        let scope = ResolverScopeCache()
        self.resolverScopeCache = scope

        switch navigationType {
        case .main:
            resolver.register { [unowned self] in
                MainCoordinatorService(moduleManager: self, exchangeType: exchangeType) as CoordinatorService
            }.scope(scope)
        case .sequence:
            resolver.register { [unowned self] in
                SequenceCoordinatorService(moduleManager: self, exchangeType: exchangeType) as CoordinatorService
            }.scope(scope)
        case .embed:
            resolver.register { [unowned self] in
                EmbedCoordinatorService(moduleManager: self, exchangeType: exchangeType) as CoordinatorService
            }.scope(scope)
        }
        resolver.register { CurrenciesDefaultService() as CurrenciesService }.scope(scope)
        resolver.register { ExchangeDefaultService() as ExchangeService }.scope(scope)
        resolver.register { TransactionDefaultService() as TransactionService }.scope(scope)
        resolver.register { ValidatorDefaultService() as ValidatorService }.scope(scope)
        resolver.register { ReachabilityService() }.scope(scope)
    }
}


//
//  ExchangePresenter.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 18.04.2020.
//  Copyright © 2020 proninps. All rights reserved.
//

import Moya

final class ExchangePresenter: NSObject {

    private let currenciesService: CurrenciesService
    private let exchangeService: ExchangeService

    @Injected private var reachabilityService: ReachabilityService
    @Injected private var bipDecoderService: BIPDecoderService

    // MARK: - Public

    var isReadyToExchange: Bool {
        return toAmount != nil &&
            minimumExchangeAmount != nil &&
            fromAmount >= minimumExchangeAmount!
    }

    // MARK: - Private

    private unowned let viewController: ExchangeViewController

    private(set) var fromCurrency: Currency
    private(set) var toCurrency: Currency {
        didSet {
            updateAddress()
        }
    }
    private(set) var fromAmount: Decimal {
        didSet {
            checkMinimumExchangeAmount()
        }
    }
    private(set) var toAmount: Decimal?
    private(set) var minimumExchangeAmount: Decimal? {
        didSet {
            checkMinimumExchangeAmount()
        }
    }

    private var exchangeData: ExchangeData {
        return ExchangeData(fromCurrency: fromCurrency,
                            toCurrency: toCurrency,
                            fromAmount: fromAmount,
                            toAmount: toAmount,
                            minimumExchangeAmount: minimumExchangeAmount)
    }

    private var pair: String {
        return "\(fromCurrency.ticker)_\(toCurrency.ticker)"
    }

    private var reversePair: String {
        return "\(toCurrency.ticker)_\(fromCurrency.ticker)"
    }

    private var isNeedReloadCurrencies: Bool
    private var isNeedDefaultRate: Bool = true
    private var isNeedShowPairError: Bool = true
    private var isReachable = true
    private var minimalExchangeAmountRequest: Cancellable?
    private var estimatedExchangeAmountRequest: Cancellable?

    // MARK: - Life Cycle

    init(viewController: ExchangeViewController,
         exchangeService: ExchangeService,
         currenciesService: CurrenciesService,
         exchangeType: ExchangeType) {
        self.viewController = viewController
        self.exchangeService = exchangeService
        self.currenciesService = currenciesService

        let exchangeData: ExchangeData
        if let cachedExchangeData = exchangeService.exchangeData {
            self.isNeedReloadCurrencies = false
            exchangeData = cachedExchangeData
        } else {
            self.isNeedReloadCurrencies = true
            exchangeData = ExchangeData.default
        }

        self.fromCurrency = exchangeData.fromCurrency
        switch exchangeType {
        case .any:
            self.toCurrency = exchangeData.toCurrency
        case let .specific(currency, _):
            let specificCurrency = currency.lowercased()
            if let toCurrency = currenciesService.currencies.first(where: { $0.ticker == specificCurrency }) {
                self.toCurrency = toCurrency
            } else {
                self.isNeedReloadCurrencies = true
                self.toCurrency = Currency(ticker: specificCurrency,
                                           name: currency.uppercased(),
                                           image: "",
                                           hasExternalId: false,
                                           isFiat: false,
                                           featured: true,
                                           isStable: true,
                                           supportsFixedRate: true)
            }
        }

        self.fromAmount = exchangeData.fromAmount
        self.toAmount = nil
        self.minimumExchangeAmount = nil

        super.init()

        reachabilityService.add(listener: self)
        currenciesService.add(listener: self)
    }

    deinit {
        reachabilityService.remove(listener: self)
        currenciesService.remove(listener: self)
    }

    func viewDidLoad() {
        updateDefaultRate()
        viewController.set(exchangeData: exchangeData)
        updateAddress()
        updateMinimalExchangeAmount()
        updateEstimatedExchangeAmount()
        networkReachabilityDidChanged(isReachable: reachabilityService.isReachable)
    }

    func switchCurrencies() {
        updateCurrencies(fromCurrency: toCurrency, toCurrency: fromCurrency)
    }

    func stopUpdateEstimatedExchangeAmount() {
        estimatedExchangeAmountRequest?.cancel()
    }

    func set(fromAmountString: String) {
        guard let fromAmount = Decimal(string: fromAmountString) else {
            log.error("Failed conversion from string to decimal")
            self.fromAmount = 0
            toAmount = nil
            viewController.set(toAmount: toAmount, rate: nil)
            return
        }
        guard self.fromAmount != fromAmount else { return }
        self.fromAmount = fromAmount
        isNeedDefaultRate = false
        toAmount = nil
        updateToAmounts()
        updateEstimatedExchangeAmount()
    }

    func refresh() {
        currenciesService.updateAll(force: false)
        toAmount = nil
        minimumExchangeAmount = nil
        viewController.set(exchangeData: exchangeData)
        updateMinimalExchangeAmount()
        updateEstimatedExchangeAmount()
    }

    func reset() {
        let exchangeData = ExchangeData.default
        fromCurrency = exchangeData.fromCurrency
        toCurrency = exchangeData.toCurrency

        isNeedDefaultRate = true
        updateDefaultRate()

        refresh()
    }

    // MARK: - Private

    private func updateCurrencies(fromCurrency: Currency, toCurrency: Currency) {
        self.fromCurrency = fromCurrency
        self.toCurrency = toCurrency
        updateDefaultRate()
        exchangeService.set(exchangeData: exchangeData)
        refresh()
    }

    private func updateCurrencies(fromCurrencyTicker: String, toCurrencyTicker: String) {
        let currencies = currenciesService.currencies
        guard let fromCurrency = currencies.first(where: { $0.ticker == fromCurrencyTicker }),
            let toCurrency = currencies.first(where: { $0.ticker == toCurrencyTicker }) else {
                log.error("Selected currencies not found")
                return
        }
        updateCurrencies(fromCurrency: fromCurrency, toCurrency: toCurrency)
    }

    private func updateDefaultRate() {
        if isNeedDefaultRate,
            let rate = currenciesService.amounts[fromCurrency.ticker] {
            fromAmount = rate
        }
    }

    private func updateToAmounts() {
        let rate: Decimal?
        if let toAmount = toAmount {
            rate = toAmount / fromAmount
        } else {
            rate = nil
        }
        viewController.set(toAmount: toAmount, rate: rate)
    }

    private func updateAddress() {
        let extraIdTitle = currenciesService.anonyms[toCurrency.ticker]
        viewController.set(addressTitle: R.string.localizable.exchangeAddress(toCurrency.ticker.uppercased()),
                           extraIdTitle: extraIdTitle ?? nil)
    }

    private func checkMinimumExchangeAmount() {
        var isHidden = true
        if let minimumExchangeAmount = minimumExchangeAmount, fromAmount < minimumExchangeAmount {
            isHidden = false
        }
        if viewController.isMinimumExchangeWarningHidden != isHidden {
            viewController.setMinimumExchangeWarning(isHidden: isHidden)
        }
    }

    private func updateMinimalExchangeAmount() {
        minimalExchangeAmountRequest?.cancel()
        minimalExchangeAmountRequest = exchangeService.getMinimalExchangeAmount(pair: pair) { [weak self] result in
            self?.minimalExchangeAmountRequest = nil
            switch result {
            case let .success(amount):
                self?.minimumExchangeAmount = amount
            case let .failure(error):
                log.error("GetMinimalExchangeAmount failed with error: \(error.localizedDescription)")
            }
            self?.viewController.stopRefreshIndicator()
        }
    }

    private func updateEstimatedExchangeAmount(isReverse: Bool = false) {
        estimatedExchangeAmountRequest?.cancel()
        estimatedExchangeAmountRequest = exchangeService.getEstimatedExchangeAmount(
            pair: isReverse ? reversePair : pair,
            sendAmount: isReverse ? toAmount ?? 1 : fromAmount,
            completion: { [weak self] result in
                guard let self = self else { return }
                self.estimatedExchangeAmountRequest = nil
                switch result {
                case let .success(estimatedExchange):
                    if isReverse {
                        self.fromAmount = estimatedExchange.estimatedAmount
                    } else {
                        self.toAmount = estimatedExchange.estimatedAmount
                    }
                    self.updateToAmounts()
                    self.exchangeService.set(exchangeData: self.exchangeData)
                case let .failure(error):
                    switch error.localizedDescription {
                    case "Pair is inactive":
                        self.viewController.showError(R.string.localizable.exchangeUnavailablePair(self.fromCurrency.ticker.uppercased(),
                                                                                                   self.toCurrency.ticker.uppercased()))
                        self.isNeedShowPairError = false
                        self.currenciesService.updatePairs(force: true)
                    default:
                        break
                    }
                    log.error("GetEstimatedExchangeAmount failed with error: \(error.localizedDescription)")
                }
                self.viewController.stopRefreshIndicator()
            }
        )
    }

    private func reloadCurrenciesIfNeeded() {
        if isNeedReloadCurrencies,
            currenciesService.currencies.isNotEmpty,
            currenciesService.pairs.isNotEmpty {
            isNeedReloadCurrencies = false
            updateCurrencies(fromCurrencyTicker: fromCurrency.ticker,
                             toCurrencyTicker: toCurrency.ticker)
        }
    }

    private func checkPair(pairs: CurrencyPairs) {
        let pairs = pairs[fromCurrency.ticker]
        if isNeedShowPairError, pairs == nil || !pairs!.contains(toCurrency.ticker) {
            viewController.showMessage(R.string.localizable.exchangeUnavailablePair(fromCurrency.ticker.uppercased(),
            toCurrency.ticker.uppercased()),
                                       title: R.string.localizable.exchangePairNotAvailable())
        }
        isNeedShowPairError = true
    }
}

extension ExchangePresenter: ChooseCurrencyDelegate {

    func currencyPairDidSelected(fromCurrencyTicker: String, toCurrencyTicker: String) {
        updateCurrencies(fromCurrencyTicker: fromCurrencyTicker, toCurrencyTicker: toCurrencyTicker)
    }
}

extension ExchangePresenter: ScannerDelegate {

    func scannerFoundReadableCodeObject(value: String) {
        viewController.set(address: bipDecoderService.decode(uri: value) ?? value)
    }
}

extension ExchangePresenter: ReachabilityServiceDelegate {

    func networkReachabilityDidChanged(isReachable: Bool) {
        viewController.networkReachabilityDidChanged(isReachable: isReachable)
        if !isReadyToExchange, isReachable, !self.isReachable {
            viewController.startRefreshIndicator()
            refresh()
        }
        self.isReachable = isReachable
    }
}

extension ExchangePresenter: CurrenciesServiceDelegate {

    func currenciesDidChanged(currencies: [Currency]) {
        reloadCurrenciesIfNeeded()
    }

    func pairsDidChanged(pairs: CurrencyPairs) {
        reloadCurrenciesIfNeeded()
        checkPair(pairs: pairs)
    }

    func amountsDidChanged(amounts: Amounts) {

    }

    func anonymsDidChanged(anonyms: Anonyms) {
        updateAddress()
    }
}

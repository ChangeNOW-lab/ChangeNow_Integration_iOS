//
//  CurrenciesService.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 18.04.2020.
//  Copyright © 2020 proninps. All rights reserved.
//

typealias Amounts = [String: Decimal]
typealias Anonyms = [String: String]

protocol CurrenciesServiceDelegate: AnyObject {

    func currenciesDidChanged(currencies: [Currency])
    func pairsDidChanged(pairs: CurrencyPairs)
    func amountsDidChanged(amounts: Amounts)
    func anonymsDidChanged(anonyms: Anonyms)
}

extension CurrenciesServiceDelegate {

    func currenciesDidChanged(currencies: [Currency]) { }
    func pairsDidChanged(pairs: CurrencyPairs) { }
    func amountsDidChanged(amounts: Amounts) { }
    func anonymsDidChanged(anonyms: Anonyms) { }
}

protocol CurrenciesService {

    var topFrom: [String] { get }
    var topTo: [String] { get }

    var currencies: [Currency] { get }
    var pairs: CurrencyPairs { get }
    var amounts: Amounts { get }
    var anonyms: Anonyms { get }

    func updateAll(force: Bool)
    func updateCurrencies(force: Bool)
    func updatePairs(force: Bool)
    func updateAmounts(force: Bool)
    func updateAnonyms(force: Bool)

    // MARK: - Listeners

    func add(listener: CurrenciesServiceDelegate)
    func remove(listener: CurrenciesServiceDelegate)
}

extension CurrenciesService {

    func updateAll() {
        updateAll(force: false)
    }
    func updateCurrencies() {

    }
    func updatePairs() {

    }
    func updateAmounts() {

    }
    func updateAnonyms() {

    }
}

final class CurrenciesDefaultService: CurrenciesService {

    let topFrom = ["btc", "eth", "xmr", "xrp", "ltc", "trx", "xlm", "usdterc20"]
    let topTo = ["btc", "xmr", "eth", "vet", "xtz", "xrp", "zec", "trx", "ada"]

    private(set) lazy var currencies: [Currency] = {
        do {
            return try FileStorage.content(from: .documents, filename: currenciesLocalPath)
        } catch {
            log.debug("Failed to load currencies from storage. Error: \(error)")
        }
        return []
    }()

    private(set) lazy var pairs: CurrencyPairs = {
        do {
            return try FileStorage.content(from: .documents, filename: pairsLocalPath)
        } catch {
            log.debug("Failed to load pairs from storage. Error: \(error)")
        }
        return [:]
    }()

    private(set) lazy var amounts: Amounts = {
        do {
            return try FileStorage.content(from: .documents, filename: amountsLocalPath)
        } catch {
            log.debug("Failed to load amounts from storage. Error: \(error)")
        }
        return [:]
    }()

    private(set) lazy var anonyms: Anonyms = {
        do {
            return try FileStorage.content(from: .documents, filename: anonymsLocalPath)
        } catch {
            log.debug("Failed to load anonyms from storage. Error: \(error)")
        }
        return [:]
    }()

    private var listenersContainer = ListenerContainer<CurrenciesServiceDelegate>()

    private let currenciesLocalPath = Filename(name: "CNCurrencies", fileExtension: .plist)
    private let pairsLocalPath = Filename(name: "CNPairs", fileExtension: .plist)
    private let amountsLocalPath = Filename(name: "CNAmounts", fileExtension: .plist)
    private let anonymsLocalPath = Filename(name: "CNAnonyms", fileExtension: .plist)

    private var isUpdatingCurrencies = false
    private var isUpdatingPairs = false
    private var isUpdatingAmounts = false
    private var isUpdatingAnonyms = false

    init() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationDidBecomeActive),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
        updateAll()
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    // MARK: - Update

    func updateAll(force: Bool = false) {
        updateCurrencies(force: force)
        updatePairs(force: force)
        updateAmounts(force: force)
        updateAnonyms(force: force)
    }

    func updateCurrencies(force: Bool = false) {
        guard !isUpdatingCurrencies else { return }
        if currencies.isNotEmpty, !force {
            let date: Date? = UserDefaultsStorage.value(forKey: .currenciesUpdateDate)
            guard date == nil || Date().hours(from: date!) >= 24 else { return }
        }
        isUpdatingCurrencies = true
        _ = NetworkService.request(target: CurrenciesAPI.getAll, auth: .none) { [weak self] (response) in
            switch response {
            case let .success(result):
                if let currencies = CurrenciesDecoder.getCurrencies(data: result.data) {
                    self?.updateCurrenciesStorage(currencies: currencies)
                    UserDefaultsStorage.set(Date(), forKey: .currenciesUpdateDate)
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        self.currencies = currencies
                        self.listenersContainer.forEach { listener in
                            listener.currenciesDidChanged(currencies: currencies)
                        }
                    }
                }
            case let .failure(error):
                log.debug(error.localizedDescription)
            }
            self?.isUpdatingCurrencies = false
        }
    }

    func updatePairs(force: Bool = false) {
        guard !isUpdatingPairs else { return }
        if pairs.isNotEmpty, !force {
            let date: Date? = UserDefaultsStorage.value(forKey: .pairsUpdateDate)
            guard date == nil || Date().minutes(from: date!) >= 30 else { return }
        }
        isUpdatingPairs = true
        _ = NetworkService.request(target: CurrenciesAPI.availablePairs, auth: .none) { [weak self] (response) in
            switch response {
            case let .success(result):
                if let pairs = CurrenciesDecoder.getPairs(data: result.data) {
                    self?.updatePairsStorage(pairs: pairs)
                    UserDefaultsStorage.set(Date(), forKey: .pairsUpdateDate)
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        self.pairs = pairs
                        self.listenersContainer.forEach { listener in
                            listener.pairsDidChanged(pairs: pairs)
                        }
                    }
                }
            case let .failure(error):
                log.debug(error.localizedDescription)
            }
            self?.isUpdatingPairs = false
        }
    }

    func updateAmounts(force: Bool = false) {
        guard !isUpdatingAmounts else { return }
        if amounts.isNotEmpty, !force {
            let date: Date? = UserDefaultsStorage.value(forKey: .amountsUpdateDate)
            guard date == nil || Date().minutes(from: date!) >= 30 else { return }
        }
        isUpdatingAmounts = true
        _ = NetworkService.request(target: CurrenciesAPI.amounts, auth: .none) { [weak self] (response) in
            switch response {
            case let .success(result):
                if let amounts = CurrenciesDecoder.getAmounts(data: result.data) {
                    self?.updateAmountsStorage(amounts: amounts)
                    UserDefaultsStorage.set(Date(), forKey: .amountsUpdateDate)
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        self.amounts = amounts
                        self.listenersContainer.forEach { listener in
                            listener.amountsDidChanged(amounts: amounts)
                        }
                    }
                }
            case let .failure(error):
                log.debug(error.localizedDescription)
            }
            self?.isUpdatingAmounts = false
        }
    }

    func updateAnonyms(force: Bool = false) {
        guard !isUpdatingAnonyms else { return }
        if anonyms.isNotEmpty, !force {
            let date: Date? = UserDefaultsStorage.value(forKey: .anonymsUpdateDate)
            guard date == nil || Date().hours(from: date!) >= 24 else { return }
        }
        isUpdatingAnonyms = true
        _ = NetworkService.request(target: CurrenciesAPI.anonyms, auth: .none) { [weak self] (response) in
            switch response {
            case let .success(result):
                if let anonyms = CurrenciesDecoder.getAnonyms(data: result.data) {
                    self?.updateAnonymsStorage(anonyms: anonyms)
                    UserDefaultsStorage.set(Date(), forKey: .anonymsUpdateDate)
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        self.anonyms = anonyms
                        self.listenersContainer.forEach { listener in
                            listener.anonymsDidChanged(anonyms: anonyms)
                        }
                    }
                }
            case let .failure(error):
                log.debug(error.localizedDescription)
            }
            self?.isUpdatingAnonyms = false
        }
    }

    // MARK: - Listeners

    func add(listener: CurrenciesServiceDelegate) {
        listenersContainer.add(listener: listener)
    }

    func remove(listener: CurrenciesServiceDelegate) {
        listenersContainer.remove(listener: listener)
    }

    // MARK: - Private

    @objc
    private func applicationDidBecomeActive() {
        updateAll()
    }

    private func updateCurrenciesStorage(currencies: [Currency]) {
        do {
            try FileStorage.store(objects: currencies,
                                                 to: .documents,
                                                 as: currenciesLocalPath)
        } catch {
            log.error("Failed to save currencies to storage. Error: \(error)")
        }
    }

    private func updatePairsStorage(pairs: CurrencyPairs) {
        do {
            try FileStorage.store(objects: pairs,
                                                 to: .documents,
                                                 as: pairsLocalPath)
        } catch {
            log.error("Failed to save pairs to storage. Error: \(error)")
        }
    }

    private func updateAmountsStorage(amounts: Amounts) {
        do {
            try FileStorage.store(objects: amounts,
                                                 to: .documents,
                                                 as: amountsLocalPath)
        } catch {
            log.error("Failed to save amounts to storage. Error: \(error)")
        }
    }

    private func updateAnonymsStorage(anonyms: Anonyms) {
        do {
            try FileStorage.store(objects: anonyms,
                                                 to: .documents,
                                                 as: anonymsLocalPath)
        } catch {
            log.error("Failed to save anonyms to storage. Error: \(error)")
        }
    }
}

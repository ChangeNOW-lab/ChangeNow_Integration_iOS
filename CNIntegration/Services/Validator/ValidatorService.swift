//
//  ValidatorService.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 18.04.2020.
//  Copyright © 2020 proninps. All rights reserved.
//

protocol ValidatorServiceDelegate: AnyObject {

    func currenciesValidationDataDidChanged(currenciesValidationData: CurrenciesValidationData)
}

extension ValidatorServiceDelegate {

    func currenciesValidationDataDidChanged(currenciesValidationData: CurrenciesValidationData) { }
}

enum ValidatorServiceError: LocalizedError {
    case regExNotFound

    var localizedDescription: String {
        return errorDescription ?? ""
    }

    var errorDescription: String? {
        switch self {
        case .regExNotFound:
            return "RegEx not found"
        }
    }
}

protocol ValidatorService {

    var currenciesValidationData: CurrenciesValidationData { get }

    func containsValidationDataFor(ticker: String, isExtraId: Bool) -> Bool
    func isValid(ticker: String, address: String) throws -> Bool
    func isValid(ticker: String, extraId: String) throws -> Bool

    // MARK: - Update

    func updateCurrenciesValidationData(force: Bool)

    // MARK: - Listeners

    func add(listener: ValidatorServiceDelegate)
    func remove(listener: ValidatorServiceDelegate)
}

final class ValidatorDefaultService: ValidatorService {

    private(set) lazy var currenciesValidationData: CurrenciesValidationData = {
        do {
            return try FileStorage.content(from: .documents, filename: validationDataLocalPath)
        } catch {
            log.debug("Failed to load currencies validation data from storage. Error: \(error)")
        }
        return [:]
    }()

    private var listenersContainer = ListenerContainer<ValidatorServiceDelegate>()

    private let validationDataLocalPath = Filename(name: "CNCurrenciesValidationData", fileExtension: .plist)

    private var isUpdatingValidationData = false

    init() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationDidBecomeActive),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    // MARK: - Validation

    func containsValidationDataFor(ticker: String, isExtraId: Bool) -> Bool {
        let currency = Currency.currencyComponents(currency: ticker.lowercased()).ticker
        if let currencyValidationData = currenciesValidationData[currency] {
            if isExtraId {
                return currencyValidationData.regExTag.isNotEmpty
            } else {
                return currencyValidationData.regEx.isNotEmpty
            }
        }
        return false
    }

    func isValid(ticker: String, address: String) throws -> Bool {
        var addressRegEx: String = ""
        let currency = Currency.currencyComponents(currency: ticker.lowercased()).ticker
        if let currencyValidationData = currenciesValidationData[currency] {
            addressRegEx = currencyValidationData.regEx
        }
        guard addressRegEx.isNotEmpty else {
            throw ValidatorServiceError.regExNotFound
        }
        let addressPredicate = NSPredicate(format: "SELF MATCHES %@", addressRegEx)
        return addressPredicate.evaluate(with: address)
    }

    func isValid(ticker: String, extraId: String) throws -> Bool {
        var regExExtraId: String = ""
        let currency = Currency.currencyComponents(currency: ticker.lowercased()).ticker
        if let currencyValidationData = currenciesValidationData[currency] {
            regExExtraId = currencyValidationData.regExTag
        }
        guard regExExtraId.isNotEmpty else {
            throw ValidatorServiceError.regExNotFound
        }
        let extraIdPredicate = NSPredicate(format: "SELF MATCHES %@", regExExtraId)
        return extraIdPredicate.evaluate(with: extraId)
    }

    // MARK: - Update

    func updateCurrenciesValidationData(force: Bool = false) {
        guard !isUpdatingValidationData else { return }
        if !force {
            let date: Date? = UserDefaultsStorage.value(forKey: .currenciesValidationData)
            guard date == nil || Date().hours(from: date!) >= 24 else { return }
        }
        isUpdatingValidationData = true
        _ = NetworkService.request(target: ValidatorAPI.getCurrenciesValidationData, auth: .none) { [weak self] (response) in
            switch response {
            case let .success(result):
                if let currenciesValidationData = ValidatorDecoder.getCurrenciesValidationData(data: result.data) {
                    self?.updateCurrenciesValidationData(currenciesValidationData: currenciesValidationData)
                    UserDefaultsStorage.set(Date(), forKey: .currenciesValidationData)
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        self.currenciesValidationData = currenciesValidationData
                        self.listenersContainer.forEach { listener in
                            listener.currenciesValidationDataDidChanged(currenciesValidationData: currenciesValidationData)
                        }
                    }
                }
            case let .failure(error):
                log.debug(error.localizedDescription)
            }
            self?.isUpdatingValidationData = false
        }
    }

    // MARK: - Listeners

    func add(listener: ValidatorServiceDelegate) {
        listenersContainer.add(listener: listener)
    }

    func remove(listener: ValidatorServiceDelegate) {
        listenersContainer.remove(listener: listener)
    }

    // MARK: - Private

    @objc
    private func applicationDidBecomeActive() {
        updateCurrenciesValidationData()
    }

    private func updateCurrenciesValidationData(currenciesValidationData: CurrenciesValidationData) {
        do {
            try FileStorage.store(objects: currenciesValidationData,
                                                 to: .documents,
                                                 as: validationDataLocalPath)
        } catch {
            log.error("Failed to save currencies to storage. Error: \(error)")
        }
    }
}


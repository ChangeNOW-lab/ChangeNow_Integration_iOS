//
//  ValidatorDecoder.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 24.04.2020.
//  Copyright © 2020 proninps. All rights reserved.
//

struct ValidatorDecoder {

    static func getCurrenciesValidationData(data: Data) -> CurrenciesValidationData? {
        let decoder = Foundation.JSONDecoder()
        do {
            let decoded = try decoder.decode([CurrencyValidationData].self, from: data)
            return decoded.dictionary(transform: {
                return [$0.ticker.lowercased(): $0]
            })
        } catch {
            log.error("Failed to decode JSON – \(error)")
        }
        return nil
    }

    static func getCachedCurrenciesValidationData(data: Data) -> CurrenciesValidationData? {
        let decoder = Foundation.JSONDecoder()
        do {
            return try decoder.decode(CurrenciesValidationData.self, from: data)
        } catch {
            log.error("Failed to decode JSON – \(error)")
        }
        return nil
    }
}


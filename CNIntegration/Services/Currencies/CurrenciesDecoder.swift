//
//  CurrenciesDecoder.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 18.04.2020.
//  Copyright © 2020 proninps. All rights reserved.
//

struct CurrenciesDecoder {

    static func getCurrencies(data: Data) -> [Currency]? {
        let decoder = Foundation.JSONDecoder()
        do {
            let decoded = try decoder.decode([Currency].self, from: data)
            return decoded
        } catch {
            log.error("Failed to decode JSON – \(error)")
        }
        return nil
    }

    static func getPairs(data: Data) -> CurrencyPairs? {
        let decoder = Foundation.JSONDecoder()
        do {
            let decoded = try decoder.decode([String].self, from: data)
            var result: CurrencyPairs = [:]
            for value in decoded {
                let currencies = value.split(separator: "_")
                if currencies.count == 2 {
                    let key = String(currencies[0])
                    let value = String(currencies[1])
                    if var pairs = result[key] {
                        pairs.append(value)
                        result[key] = pairs
                    } else {
                        result[key] = [value]
                    }
                }
            }
            return result
        } catch {
            log.error("Failed to decode JSON – \(error)")
        }
        return nil
    }

    static func getAmounts(data: Data) -> Amounts? {
        let decoder = Foundation.JSONDecoder()
        do {
            let decoded = try decoder.decode(Amounts.self, from: data)
            return decoded
        } catch {
            log.error("Failed to decode JSON – \(error)")
        }
        return nil
    }

    static func getAnonyms(data: Data) -> Anonyms? {
        let decoder = Foundation.JSONDecoder()
        do {
            let decoded = try decoder.decode(Anonyms.self, from: data)
            return decoded
        } catch {
            log.error("Failed to decode JSON – \(error)")
        }
        return nil
    }
}


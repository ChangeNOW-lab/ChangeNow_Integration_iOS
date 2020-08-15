//
//  ExchangeDecoder.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 19.04.2020.
//  Copyright © 2020 proninps. All rights reserved.
//

struct ExchangeDecoder {

    static func getMinimalExchangeAmount(data: Data) -> Decimal? {
        let decoder = Foundation.JSONDecoder()
        do {
            let decoded = try decoder.decode([String: Decimal].self, from: data)
            return decoded.first?.value
        } catch {
            log.error("Failed to decode JSON – \(error)")
        }
        return nil
    }

    static func getEstimatedExchangeAmount(data: Data) -> EstimatedExchange? {
        let decoder = Foundation.JSONDecoder()
        do {
            let decoded = try decoder.decode(EstimatedExchange.self, from: data)
            return decoded
        } catch {
            log.error("Failed to decode JSON – \(error)")
        }
        return nil
    }
}

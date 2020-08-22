//
//  GuardarianDecoder.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 21.08.2020.
//  Copyright © 2020 Pavel Pronin. All rights reserved.
//

struct GuardarianDecoder {

    static func getGuardarianExchange(data: Data) -> GuardarianExchangeData? {
        let decoder = Foundation.JSONDecoder()
        do {
            return try decoder.decode(GuardarianExchangeData.self, from: data)
        } catch {
            log.error("Failed to decode JSON – \(error)")
        }
        return nil
    }

    static func getGuardarianTransaction(data: Data) -> GuardarianTransactionData? {
        let decoder = Foundation.JSONDecoder()
        do {
            return try decoder.decode(GuardarianTransactionData.self, from: data)
        } catch {
            log.error("Failed to decode JSON – \(error)")
        }
        return nil
    }
}

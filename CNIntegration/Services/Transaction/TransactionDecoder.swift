//
//  TransactionDecoder.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 26.04.2020.
//  Copyright © 2020 proninps. All rights reserved.
//

struct TransactionDecoder {

    static func getTransactionData(data: Data) -> TransactionData? {
        let decoder = Foundation.JSONDecoder()
        do {
            let decoded = try decoder.decode(TransactionData.self, from: data)
            return decoded
        } catch {
            log.error("Failed to decode JSON – \(error)")
        }
        return nil
    }

    static func getTransactionStatusData(data: Data) -> TransactionStatusData? {
        let decoder = Foundation.JSONDecoder()
        do {
            let decoded = try decoder.decode(TransactionStatusData.self, from: data)
            return decoded
        } catch {
            log.error("Failed to decode JSON – \(error)")
        }
        return nil
    }
}

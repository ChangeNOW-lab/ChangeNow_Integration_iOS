//
//  TransactionData.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 26.04.2020.
//  Copyright © 2020 proninps. All rights reserved.
//

struct TransactionData: Equatable, Codable {

    let id: String // You can use it to get transaction status at the Transaction status API endpoint

    /*
    let fromCurrency: String // Ticker of the currency you want to exchange
    let toCurrency: String // Ticker of the currency you want to receive

    let amount: Decimal // Amount of currency you want to exchange

    let payinAddress: String // We generate it when creating a transaction
    let payinExtraId: String? // We generate it when creating a transaction

    let payoutAddress: String // The wallet address that will recieve the exchanged funds
    let payoutExtraId: String? // Extra ID that you send when creating a transaction

    let refundAddress: String? // Refund address (if you specified it)
    let refundExtraId: String? // Refund Extra ID (if you specified it)
    let payoutExtraIdName: String? // Field name currency Extra ID (e.g. Memo, Extra ID)
     */
}

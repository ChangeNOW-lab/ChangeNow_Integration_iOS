//
//  TransactionStatusData.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 26.04.2020.
//  Copyright © 2020 proninps. All rights reserved.
//

enum TransactionStatus: String, CaseIterable {
    case new
    case waiting
    case verifying
    case confirming
    case exchanging
    case sending
    case finished
    case failed
    case refunded
    case expired
}

struct TransactionStatusData: Equatable, Codable {

    let id: String // You can use it to get transaction status at the Transaction status API endpoint
    let status: String

    let fromCurrency: String // Ticker of the currency you want to exchange
    let toCurrency: String // Ticker of the currency you want to receive

    let expectedSendAmount: Decimal? // The amount you want to send
    let expectedReceiveAmount: Decimal? // Estimate based on the field expectedSendAmount. Formula for calculating the estimated amount is given below

    let amountSend: Decimal? // Amount you send
    let amountReceive: Decimal? // Amount you receive

    let payinAddress: String // We generate it when creating a transaction
    let payinExtraId: String? // We generate it when creating a transaction

    let payoutAddress: String // The wallet address that will recieve the exchanged funds
    let payoutExtraId: String? // Extra ID that you send when creating a transaction
    let payoutExtraIdName: String? // Field name currency Extra ID (e.g. Memo, Extra ID)

    let refundAddress: String? // Refund address (if you specified it)
    let refundExtraId: String? // Refund Extra ID (if you specified it)

    /*
    let createdAt: String // Transaction creation date and time
    let updatedAt: String // Date and time of the last transaction update (e.g. status update)
    let depositReceivedAt: String // Deposit receiving date and time

    let payinHash: String // Transaction hash in the blockchain of the currency which you specified in the fromCurrency field that you send when creating the transaction
    let payoutHash: String // Transaction hash in the blockchain of the currency which you specified in the toCurrency field. We generate it when creating a transaction

    let networkFee: Decimal // Network fee for transferring funds between wallets, it should be deducted from the result. Formula for calculating the estimated amount is given below
    let tokensDestination: String // Wallet address to receive NOW tokens upon exchange
    let validUntil: String // Date and time of transaction validity
    let verificationSent: Bool // Indicates if a transaction has been sent for verification

    let isPartner: Bool // Indicates if transactions are affiliate
    let userId: String // Partner user ID that was sent when the transaction was created
 */
}

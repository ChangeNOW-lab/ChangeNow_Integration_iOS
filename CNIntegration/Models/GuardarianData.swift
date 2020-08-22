//
//  GuardarianData.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 21.08.2020.
//  Copyright © 2020 Pavel Pronin. All rights reserved.
//

struct GuardarianExchangeData: Equatable, Codable {

    enum CodingKeys: String, CodingKey {
        case estimatedAmount = "value"
//        case cryptoCurrency = "crypto_currency"
//        case fiatCurrency = "fiat_currency"
    }

    let estimatedAmount: Decimal
//    let cryptoCurrency: String
//    let fiatCurrency: String?
}

struct GuardarianTransactionData: Equatable, Codable {

    /*
    "id": "6186515561",
    "status": "new",
    "fiat_currency": "USD",
    "fiat_amount": "100",
    "crypto_currency": "BTC",
    "crypto_amount": null,
    "created_at": "2020-06-04T10:02:51.474Z",
    "updated_at": "2020-06-04T10:02:51.474Z",
    "payout_address": "someAddress",
    "redirect_url": "<urltoRedirect>",
    "email": "test@mail.ru"
     */

    enum CodingKeys: String, CodingKey {
//        case id = "id"
        case redirectURL = "redirect_url"
    }

//    let id: String
    let redirectURL: String
}

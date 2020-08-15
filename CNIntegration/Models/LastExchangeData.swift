//
//  ExchangeData.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 19.04.2020.
//  Copyright © 2020 proninps. All rights reserved.
//

struct ExchangeData: Equatable, Codable {

    let fromCurrency: Currency
    let toCurrency: Currency
    let fromAmount: Decimal
    let toAmount: Decimal?
    let minimumExchangeAmount: Decimal?

    static var `default`: ExchangeData {
        return ExchangeData(fromCurrency: Currency.defaultBTC,
                                toCurrency: Currency.defaultETH,
                                fromAmount: 0.1,
                                toAmount: nil,
                                minimumExchangeAmount: nil)
    }
}

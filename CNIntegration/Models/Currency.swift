//
//  Currency.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 18.04.2020.
//  Copyright © 2020 proninps. All rights reserved.
//

struct Currency: Hashable, Codable {

    let ticker: String
    let name: String
    let image: String

    let hasExternalId: Bool
    let isFiat: Bool
    let featured: Bool
    let isStable: Bool
    let supportsFixedRate: Bool

    func hash(into hasher: inout Hasher) {
        hasher.combine(ticker)
    }

    static func currencyComponents(currency: String) -> (ticker: String, description: String?) {
        switch currency {
        case "usdterc20":
            return ("usdt", "Erc-20")
        case "usdttrc20":
            return ("usdt", "Trc-20")
        case "bnbmainnet":
            return ("bnb", "Mainnet")
        default:
            return (currency, nil)
        }
    }
}

typealias CurrencyPairs = [String: [String]]

extension Currency {

    static var defaultBTC: Currency {
        return Currency(ticker: "btc",
                        name: "Bitcoin",
                        image: "",
                        hasExternalId: false,
                        isFiat: false,
                        featured: true,
                        isStable: true,
                        supportsFixedRate: true)
    }

    static var defaultETH: Currency {
        return Currency(ticker: "eth",
                        name: "Ethereum",
                        image: "",
                        hasExternalId: false,
                        isFiat: false,
                        featured: true,
                        isStable: true,
                        supportsFixedRate: true)
    }

    static var defaultUSD: Currency {
        return Currency(ticker: "usd",
                        name: "US Dollar",
                        image: "",
                        hasExternalId: false,
                        isFiat: true,
                        featured: false,
                        isStable: true,
                        supportsFixedRate: true)
    }

    static var defaultEUR: Currency {
        return Currency(ticker: "eur",
                        name: "Euro",
                        image: "",
                        hasExternalId: false,
                        isFiat: true,
                        featured: false,
                        isStable: true,
                        supportsFixedRate: true)
    }
}

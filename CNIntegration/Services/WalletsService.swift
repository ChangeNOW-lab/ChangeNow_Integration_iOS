//
//  WalletsService.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 28.04.2020.
//  Copyright © 2020 proninps. All rights reserved.
//

struct WalletsService {

    private static let trustWalletRegisteredCoins = [
        "btc": 0,
        "eth": 60,
        "etc": 61,
        "go": 6060,
        "poa": 178,
        "vet": 818,
        "trx": 195,
        "wan": 5718350,
        "clo": 820,
        "icx": 74,
        "ltc": 2,
        "bch": 145,
        "tomo": 889,
        "dash": 5,
        "zec": 133,
        "xrp": 144,
        "kin": 2017,
        "nim": 242,
        "tt": 1001,
        "aion": 425,
        "xlm": 148,
        "xtz": 1729,
        "theta": 500,
        "doge": 3,
        "ont": 1024,
        "atom": 118,
        "grs": 17,
        "qtum": 2301,
        "via": 14,
        "bnb": 714,
        "iotx": 304,
        "rvn": 175,
        "zil": 313,
        "waves": 5741564,
        "ae": 457,
        "nas": 2718,
        "dcr": 42,
        "algo": 283,
        "dgb": 20,
        "nano": 165,
        "one": 270
    ]

    static func sendViaTrustWallet(ticker: String, address: String, memo: String?, amount: Decimal) -> Bool {
        let currency = Currency.currencyComponents(currency: ticker.lowercased()).ticker
        guard let coinIndex = trustWalletRegisteredCoins[currency] else {
            return false
        }
        var params = "send?coin=\(coinIndex)&address=\(address)&amount=\(amount)"
        if let memo = memo {
            params += "&memo=\(memo)"
        }
        let url: URL?
        if UIApplication.shared.canOpenURL(URL(string: "trust://")!) {
            url = URL(string: "trust://\(params)")
        } else {
            url = URL(string: "itms-apps://itunes.apple.com/app/apple-store/id1288339409?mt=8")
        }
        guard let resultUrl = url else { return false }
        UIApplication.shared.open(resultUrl, options: [:], completionHandler: nil)
        return true
    }

    static func sendViaGuardaWallet(ticker: String, address: String, memo: String?, amount: Decimal) {
        let currency = Currency.currencyComponents(currency: ticker.lowercased())
        var params = "send?amount=\(amount)&currencyTo=\(currency.ticker)&addressTo=\(address)"
//        if let description = currency.description?.lowercased() {
//            params += "&family=\(description)"
//        }
        if let memo = memo {
            params += "&extraID=\(memo)"
        }
        let url: URL? = URL(string: "https://guarda.co/app/mobile/\(params)")
//        if UIApplication.shared.canOpenURL(URL(string: "guardaWallet://")!) {
//            url = URL(string: "guardaWallet://")
//        } else {
//            url = URL(string: "itms-apps://itunes.apple.com/app/apple-store/id1442083982?mt=8")
//        }
        guard let resultUrl = url else { return }
        UIApplication.shared.open(resultUrl, options: [:], completionHandler: nil)
    }
}


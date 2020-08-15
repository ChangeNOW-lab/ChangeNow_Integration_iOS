//
//  CurrencyValidationData.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 24.04.2020.
//  Copyright © 2020 proninps. All rights reserved.
//

typealias CurrenciesValidationData = [String: CurrencyValidationData]

struct CurrencyValidationData: Equatable, Codable {

    enum CodingKeys: String, CodingKey {
        case ticker = "assetCode"
        case regEx = "regEx"
        case regExTag = "regExTag"
//        case name = "assetName"
//        case logoUrl = "logoUrl"
//        case fullLogoUrl = "fullLogoUrl"
    }

    let ticker: String
    let regEx: String
    let regExTag: String
//    let name: String?
//    let logoUrl: String?
//    let fullLogoUrl: String?
}

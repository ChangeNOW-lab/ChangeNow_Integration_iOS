//
//  UserDefaultStorageKeys.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 28.06.17.
//  Copyright © 2017 ChangeNOW. All rights reserved.
//

public enum UserDefaultsStorageKey: String, UserDefaultsStorageKeyConvertible {

    case currenciesUpdateDate = "CNCurrenciesUpdateDate"
    case pairsUpdateDate = "CNPairsUpdateDate"
    case amountsUpdateDate = "CNAmountsUpdateDate"
    case anonymsUpdateDate = "CNAnonymsUpdateDate"
    case currenciesValidationData = "CNCurrenciesValidationData"

    case reviewWorthyActionCount = "CNReviewWorthyActionCount"
    case lastReviewRequestAppVersion = "CNLastReviewRequestAppVersion"
    case lastReviewRequestDate = "CNLastReviewRequestDate"

    public var userDefaultsStorageKey: String {
        return rawValue
    }
}

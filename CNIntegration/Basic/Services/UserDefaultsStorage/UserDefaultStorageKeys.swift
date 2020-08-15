//
//  UserDefaultStorageKeys.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 28.06.17.
//  Copyright © 2017 ChangeNOW. All rights reserved.
//

public enum UserDefaultsStorageKey: String, UserDefaultsStorageKeyConvertible {

    case currenciesUpdateDate
    case pairsUpdateDate
    case amountsUpdateDate
    case anonymsUpdateDate
    case currenciesValidationData

    case reviewWorthyActionCount
    case lastReviewRequestAppVersion
    case lastReviewRequestDate

    public var userDefaultsStorageKey: String {
        return rawValue
    }
}

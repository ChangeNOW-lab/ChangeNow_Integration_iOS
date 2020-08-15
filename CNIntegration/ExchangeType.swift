//
//  ExchangeType.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 26.07.2020.
//  Copyright © 2020 Pavel Pronin. All rights reserved.
//

public enum ExchangeType {

    // Exchange for any currency
    case any

    // Exchange for a specific currency, with the ability to specify the user's default address
    case specific(currency: String, address: String?)
}

//
//  EstimatedExchange.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 18.04.2020.
//  Copyright © 2020 proninps. All rights reserved.
//

struct EstimatedExchange: Equatable, Codable {

    let estimatedAmount: Decimal
    let transactionSpeedForecast: String
    let warningMessage: String?
}

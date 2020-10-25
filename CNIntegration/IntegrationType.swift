//
//  IntegrationType.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 25.10.2020.
//  Copyright © 2020 Pavel Pronin. All rights reserved.
//

struct IntegrationsManager {

    static var current: [IntegrationType] = []
}

public enum IntegrationType {

    case trustWallet
}

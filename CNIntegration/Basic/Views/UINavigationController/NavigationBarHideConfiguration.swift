//
//  NavigationBarHideConfiguration.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 10/12/2019.
//  Copyright © 2019 Pavel Pronin. All rights reserved.
//

enum NavigationBarHideConfiguration {

    case shown
    case hidden

    var isHidden: Bool {
        switch self {
        case .shown:  return false
        case .hidden: return true
        }
    }
}

protocol NavigationBarHideConfigurator {

    var navigationBarHideConfiguration: NavigationBarHideConfiguration { get }
}

extension NavigationBarHideConfigurator {

    var navigationBarHideConfiguration: NavigationBarHideConfiguration {
        return .shown
    }
}

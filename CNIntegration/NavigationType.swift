//
//  NavigationType.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 26.07.2020.
//  Copyright © 2020 Pavel Pronin. All rights reserved.
//

public enum NavigationType {

    // When used as the base of the app on UIWindow
    case main

    // When you need to open by push from NavigationController or present from ViewController
    case sequence

    // When you need to embed in the TabBarController
    case embed
}

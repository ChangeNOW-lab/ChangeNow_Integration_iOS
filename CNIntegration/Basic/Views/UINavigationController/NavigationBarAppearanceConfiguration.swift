//
//  NavigationBarAppearanceConfiguration.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 10/12/2019.
//  Copyright © 2019 Pavel Pronin. All rights reserved.
//

struct NavigationBarAppearanceConfiguration: Equatable {
    
    let backgroundImage: UIImage?
    let shadowImage: UIImage?
    let isTranslucent: Bool
    let tintColor: UIColor
    let barTintColor: UIColor?
    // 'navigationControllerViewColor' put here because it need to keep same color as 'barTintColor'
    // to prevent blinking while push/pop animations. Another reason: color of view of UINavigationController
    // seems has no other visible effect ecxept of NavigationBar animations.
    // So it relates to NavigationBar appearance.
    let navigationControllerViewColor: UIColor?
    let titleTextColor: UIColor?
    let statusBarStyle: UIStatusBarStyle
    
    init(backgroundImage: UIImage?,
         shadowImage: UIImage?,
         isTranslucent: Bool,
         tintColor: UIColor,
         barTintColor: UIColor?,
         navigationControllerViewColor: UIColor?,
         titleTextColor: UIColor?,
         statusBarStyle: UIStatusBarStyle) {
        self.backgroundImage = backgroundImage
        self.shadowImage = shadowImage
        self.isTranslucent = isTranslucent
        self.tintColor = tintColor
        self.barTintColor = barTintColor
        self.navigationControllerViewColor = navigationControllerViewColor
        self.titleTextColor = titleTextColor
        self.statusBarStyle = statusBarStyle
    }
}

protocol NavigationBarAppearanceConfigurator {
    
    var navigationBarAppearanceConfiguration: NavigationBarAppearanceConfiguration { get }
}

extension NavigationBarAppearanceConfiguration {
    
    private static let appearance = UINavigationBar.appearance(whenContainedInInstancesOf: [ConfigurableNavigationController.self])
    private static let defaultStatusBarStyle: UIStatusBarStyle = .lightContent
    
    static let common: NavigationBarAppearanceConfiguration = {
        let titleTextColor = appearance.titleTextAttributes?[NSAttributedString.Key.foregroundColor] as? UIColor
        return .init(backgroundImage: appearance.backgroundImage(for: .default),
                     shadowImage: appearance.shadowImage,
                     isTranslucent: appearance.isTranslucent,
                     tintColor: appearance.tintColor,
                     barTintColor: appearance.barTintColor,
                     navigationControllerViewColor: appearance.barTintColor,
                     titleTextColor: titleTextColor,
                     statusBarStyle: defaultStatusBarStyle)
    }()
    
    static let translucent: NavigationBarAppearanceConfiguration = {
        return Self.translucent(statusBarStyle: defaultStatusBarStyle)
    }()
    
    static func translucent(statusBarStyle: UIStatusBarStyle) -> NavigationBarAppearanceConfiguration {
        let titleTextColor = appearance.titleTextAttributes?[NSAttributedString.Key.foregroundColor] as? UIColor
        return .init(backgroundImage: UIImage(),
                     shadowImage: UIImage(),
                     isTranslucent: true,
                     tintColor: appearance.tintColor,
                     barTintColor: appearance.barTintColor,
                     navigationControllerViewColor: appearance.barTintColor,
                     titleTextColor: titleTextColor,
                     statusBarStyle: statusBarStyle)
    }
}

//
//  GlobalVariables.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 29/04/2017.
//  Copyright © 2017 Pavel Pronin All rights reserved.
//

struct ChangeNOW {
    static var apiKey = ""

    static let apiBaseURL = "https://changenow.io/api"
    static let supportMail = "support@changenow.io"

    static let isOriginalApp = App.appBundleID == "io.changenow"

    #if DEBUG
    static let apiMobileBaseURL = "https://dev-nowbutton.herokuapp.com"
    #else
    static let apiMobileBaseURL = "https://android.changenow.io"
    #endif

    static func url(currency: String) -> URL? {
        return URL(string: "https://changenow.io/images/coins/\(currency).svg")
    }
}

struct Guardarian {

    #if DEBUG
    static let apiBaseURL = "https://api-guardarian-test.nownodes.io"
    #else
    static let apiBaseURL = "https://api-payments.guardarian.com"
    #endif

    #if DEBUG
    static let apiKey = "c14d927f-cb01-4561-9520-28ec22c92709"
    #else
    static let apiKey = "ff2e92c2-5c0c-464f-bed8-25fc7876e240"
    #endif
}

struct GlobalExchange {

    static let fiatMinimum: Decimal = 20
    static let fiatMaximum: Decimal = 150

    static let fiat = ["usd", "eur"]
    static let defi = ["lend", "comp", "snx", "knc", "ren", "rep", "bnt", "lrc", "yfi", "bal"]

    static func pair(fromCurrency: Currency, toCurrency: Currency) -> String {
        return "\(fromCurrency.ticker)_\(toCurrency.ticker)"
    }

    static func currencies(pair: String) -> (String, String)? {
        let components = pair.components(separatedBy: "_")
        if components.count == 2 {
            return (components[0], components[1])
        }
        return nil
    }
}

struct GlobalStrings {
    static let extraId = "Extra ID"
}

struct GlobalConsts {

    static let maxMantissa = 6

    static let sideOffset: CGFloat = 16
    static let internalSideOffset: CGFloat = 12

    static let buttonHeight: CGFloat = {
        switch Device.model {
        case .iPhone5, .iPhone6:
            return 44
        default:
            return 50
        }
    }()
}

struct Screen {

    static var width: CGFloat { return UIScreen.main.bounds.width }

    static var height: CGFloat { return UIScreen.main.bounds.height }

    static var statusBarHeight: CGFloat { return UIApplication.shared.statusBarFrame.height }

    static var scale: CGFloat { return UIScreen.main.scale }

    static var separatorHeight: CGFloat { return 1 / self.scale }
}

struct App {

    static var appDisplayName: String? {
        return Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String
    }

    static var appBundleID: String? {
        return Bundle.main.bundleIdentifier
    }

    static var applicationIconBadgeNumber: Int {
        get {
            return UIApplication.shared.applicationIconBadgeNumber
        }
        set {
            UIApplication.shared.applicationIconBadgeNumber = newValue
        }
    }

    static var appVersion: String? {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    }

    static var currentDevice: UIDevice {
        return UIDevice.current
    }

    static var deviceModel: String {
        return currentDevice.model
    }

    static var deviceName: String {
        return currentDevice.name
    }

    static var deviceOrientation: UIDeviceOrientation {
        return currentDevice.orientation
    }

    static var isPad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }

    static var isPhone: Bool {
        return UIDevice.current.userInterfaceIdiom == .phone
    }

    static var sharedApplication: UIApplication {
        return UIApplication.shared
    }

    static var isRegisteredForRemoteNotifications: Bool {
        return UIApplication.shared.isRegisteredForRemoteNotifications
    }

    static var systemVersion: String {
        return currentDevice.systemVersion
    }
}

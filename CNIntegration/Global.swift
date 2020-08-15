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

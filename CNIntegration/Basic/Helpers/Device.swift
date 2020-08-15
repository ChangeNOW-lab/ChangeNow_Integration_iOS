//
//  Device.swift
//  ReactiveOAuth
//
//  Created by Pavel Pronin on 04/10/16.
//  Copyright © 2016 Pavel Pronin. All rights reserved.
//

class Device: NSObject {

    static var identifier: String? {
        return UIDevice.current.identifierForVendor?.uuidString
    }

    class var isIPhone: Bool {
        return UIDevice.current.userInterfaceIdiom == .phone
    }

    class var isIPad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }

    class var model: Model {
        let bounds = UIScreen.main.bounds
        let width = bounds.width
        let height = bounds.height
        switch true {
        case width <= 320:
            return .iPhone5
        case width <= 375:
            if height == 812 {
               return .iPhoneX
            }
            return .iPhone6
        case width <= 414:
            if height == 812 {
               return .iPhone6Plus
            }
            return .iPhoneMax
        default:
            return .iPhoneMax
        }
    }

    enum Model {
        case iPhone5
        case iPhone6
        case iPhone6Plus
        case iPhoneX
        case iPhoneMax
    }
}

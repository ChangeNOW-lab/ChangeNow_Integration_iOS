//
//  UIControl+Additions.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 04/10/2017.
//  Copyright © 2017 Pavel Pronin. All rights reserved.
//

private var controlHandlerKey: Int8 = 0

extension UIControl {

    func addHandler(for controlEvents: UIControl.Event, handler: @escaping (UIControl) -> Void) {
        removeHandlers(for: controlEvents)

        let target = CocoaTarget<UIControl>(handler)
        objc_setAssociatedObject(self, &controlHandlerKey, target, .OBJC_ASSOCIATION_RETAIN)
        self.addTarget(target, action: #selector(target.sendNext), for: controlEvents)
    }

    func removeHandlers(for controlEvents: UIControl.Event) {
        if let oldTarget = objc_getAssociatedObject(self, &controlHandlerKey) as? CocoaTarget<UIControl> {
            self.removeTarget(oldTarget, action: #selector(oldTarget.sendNext), for: controlEvents)
        }
    }
}

extension UIBarButtonItem {

    func add(handler: @escaping (UIBarButtonItem) -> Void) {

        let target = CocoaTarget<UIBarButtonItem>(handler)

        objc_setAssociatedObject(self, &controlHandlerKey, target, .OBJC_ASSOCIATION_RETAIN)

        self.target = target
        self.action = #selector(target.sendNext)
    }

    func removeHandlers() {
        self.action = nil
        self.target = nil
    }
}

extension UIGestureRecognizer {
    
    func addHandler(handler: @escaping (UIGestureRecognizer) -> Void) {
        if let oldTarget = objc_getAssociatedObject(self, &controlHandlerKey) as? CocoaTarget<UIGestureRecognizer> {
            self.removeTarget(oldTarget, action: #selector(oldTarget.sendNext))
        }

        let target = CocoaTarget<UIGestureRecognizer>(handler)
        objc_setAssociatedObject(self, &controlHandlerKey, target, .OBJC_ASSOCIATION_RETAIN)
        self.addTarget(target, action: #selector(target.sendNext))
    }

    func removeHandlers() {
        if let oldTarget = objc_getAssociatedObject(self, &controlHandlerKey) as? CocoaTarget<UIGestureRecognizer> {
            self.removeTarget(oldTarget, action: #selector(oldTarget.sendNext))
        }
    }
}

final class CocoaTarget<Value>: NSObject {

    init(_ action: @escaping (Value) -> Void) {
        self.action = action
    }

    @objc
    func sendNext(_ receiver: Any?) {
        action(receiver as! Value)
    }

    private let action: (Value) -> Void
}

//
//  TouchThroughView.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 24/03/2020.
//  Copyright © 2020 Pavel Pronin. All rights reserved.
//

@objcMembers
class TouchThroughView: UIView {

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        for view in subviews {
            if !view.isHidden,
                view.alpha > 0,
                view.isUserInteractionEnabled,
                view.point(inside: convert(point, to: view), with: event) {
                return true
            }
        }
        return false
    }
}

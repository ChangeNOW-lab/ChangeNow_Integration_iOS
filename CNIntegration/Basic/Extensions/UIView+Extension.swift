//
//  UIView+Additions.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 08/08/2017.
//  Copyright © 2017 Pavel Pronin. All rights reserved.
//

extension UIView {

    @objc static var isRTL: Bool {
        return UIView.appearance().semanticContentAttribute == .forceRightToLeft
    }

    @objc static var isLTR: Bool {
        return !UIView.isRTL
    }
}

extension UIView {

    func maskByRoundingCorners(_ masks: UIRectCorner, withRadii radii: CGSize = CGSize(width: 10, height: 10)) {
        let shape = CAShapeLayer()
        shape.frame = self.bounds

        let rounded = UIBezierPath(roundedRect: shape.bounds, byRoundingCorners: masks, cornerRadii: radii)
        shape.path = rounded.cgPath

        self.layer.mask = shape
    }
}

extension UIView {

    func addSubviews(_ arrayOfViews: [UIView]) {
        for view in arrayOfViews {
            self.addSubview(view)
        }
    }
}

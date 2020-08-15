//
//  UIEdgeInsets+Extensions.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 19/10/2017.
//  Copyright © 2017 Pavel Pronin. All rights reserved.
//

extension UIEdgeInsets {

    var horziontalInset: CGFloat {
        return self.left + self.right
    }

    var verticalInset: CGFloat {
        return self.top + self.bottom
    }

    var hashValue: Int {
        return self.top.hashValue ^ self.left.hashValue ^ self.bottom.hashValue ^ self.right.hashValue
    }

    static func + (lhs: UIEdgeInsets, rhs: UIEdgeInsets) -> UIEdgeInsets {
        return UIEdgeInsets(top: lhs.top + rhs.top,
                            left: lhs.left + rhs.left,
                            bottom: lhs.bottom + rhs.bottom,
                            right: lhs.right + rhs.right)
    }

    static func vertical(top: CGFloat, bottom: CGFloat) -> UIEdgeInsets {
        return .init(top: top, left: 0, bottom: bottom, right: 0)
    }

    static func horziontal(left: CGFloat, right: CGFloat) -> UIEdgeInsets {
        return .init(top: 0, left: left, bottom: 0, right: right)
    }

    init(vertical: CGFloat, horizontal: CGFloat) {
        self.init(top: vertical, left: horizontal, bottom: vertical, right: horizontal)
    }

    init(offset: CGFloat) {
        self.init(top: offset, left: offset, bottom: offset, right: offset)
    }
}

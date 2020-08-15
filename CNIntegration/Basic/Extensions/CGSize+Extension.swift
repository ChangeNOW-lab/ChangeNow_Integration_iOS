//
//  CNIntegration
//
//  Created by Pavel Pronin on 10/07/2018.
//  Copyright © 2018 Pavel Pronin. All rights reserved.
//

import CoreGraphics

extension CGSize {

    func insetBy(dx: CGFloat, dy: CGFloat) -> CGSize {
        return CGSize(width: self.width - dx, height: self.height - dy)
    }

    func outsetBy(dx: CGFloat, dy: CGFloat) -> CGSize {
        return self.insetBy(dx: -dx, dy: -dy)
    }

    func roundForUI(scale: CGFloat = Screen.scale) -> CGSize {
        return CGSize(width: width.roundForUI(scale: scale),
                      height: height.roundForUI(scale: scale))
    }

    func rect(inContainer containerRect: CGRect,
              xAlignament: HorizontalAlignment,
              yAlignment: VerticalAlignment,
              dx: CGFloat = 0,
              dy: CGFloat = 0,
              sizeDx: CGFloat = 0,
              sizeDy: CGFloat = 0) -> CGRect {
        let originX, originY: CGFloat
        let size = self.outsetBy(dx: sizeDx, dy: sizeDy)

        // Horizontal alignment
        switch xAlignament {
        case .left:
            originX = 0
        case .center:
            originX = containerRect.midX - size.width / 2.0
        case .right:
            originX = containerRect.greatestY - size.width
        }

        // Vertical alignment
        switch yAlignment {
        case .top:
            originY = 0
        case .center:
            originY = containerRect.midY - size.height / 2.0
        case .bottom:
            originY = containerRect.greatestY - size.height
        }

        return CGRect(origin: CGPoint(x: originX, y: originY).offsetBy(dx: dx, dy: dy), size: size)
    }

    static func square(with sideWidth: CGFloat) -> CGSize {
        return CGSize(width: sideWidth, height: sideWidth)
    }
}

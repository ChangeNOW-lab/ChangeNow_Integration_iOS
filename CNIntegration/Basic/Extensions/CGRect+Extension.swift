//
//  CNIntegration
//
//  Created by Pavel Pronin on 10/07/2018.
//  Copyright © 2018 Pavel Pronin. All rights reserved.
//

import CoreGraphics

extension CGRect {

    var bounds: CGRect {
        return CGRect(origin: CGPoint.zero, size: self.size)
    }

    var center: CGPoint {
        return CGPoint(x: self.midX, y: self.midY)
    }

    var greatestY: CGFloat {
        get {
            return self.maxY
        } set {
            let delta = newValue - self.maxY
            self.origin = self.origin.offsetBy(dx: 0, dy: delta)
        }
    }

    func roundForUI(scale: CGFloat = Screen.scale) -> CGRect {
        let origin = CGPoint(x: self.origin.x.roundForUI(scale: scale), y: self.origin.y.roundForUI(scale: scale))
        return CGRect(origin: origin, size: size.roundForUI(scale: scale))
    }
}

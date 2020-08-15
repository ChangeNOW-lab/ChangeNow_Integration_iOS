//
//  CNIntegration
//
//  Created by Pavel Pronin on 10/07/2018.
//  Copyright © 2018 Pavel Pronin. All rights reserved.
//

import CoreGraphics

extension CGPoint {

    func offsetBy(dx: CGFloat, dy: CGFloat) -> CGPoint {
        return CGPoint(x: self.x + dx, y: self.y + dy)
    }
}

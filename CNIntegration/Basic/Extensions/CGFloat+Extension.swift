//
//  CNIntegration
//
//  Created by Pavel Pronin on 10/07/2018.
//  Copyright © 2018 Pavel Pronin. All rights reserved.
//

import CoreGraphics

extension CGFloat {

    func roundForUI(scale: CGFloat = Screen.scale) -> CGFloat {
        return ceil(self * scale) * (1.0 / scale)
    }
}

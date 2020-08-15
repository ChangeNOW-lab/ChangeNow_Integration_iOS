//
//  CNIntegration
//
//  Created by Pavel Pronin on 10/07/2018.
//  Copyright © 2018 Pavel Pronin. All rights reserved.
//

extension CABasicAnimation {

    class func fadeInAnimationWithDuration(_ duration: CFTimeInterval) -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.duration = duration
        animation.fromValue = 0
        animation.toValue = 1
        animation.fillMode = CAMediaTimingFillMode.forwards
        animation.isAdditive = false
        return animation
    }
}

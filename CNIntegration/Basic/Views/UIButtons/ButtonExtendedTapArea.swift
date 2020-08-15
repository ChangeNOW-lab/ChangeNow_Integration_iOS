//
//  ButtonExtendedTapArea.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 19/06/2019.
//  Copyright © 2019 Pavel Pronin. All rights reserved.
//

class ButtonExtendedTapArea: HighlightedButton {

    var extendedSize: CGFloat = 10

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        contentEdgeInsets = UIEdgeInsets(top: .leastNormalMagnitude,
                                         left: .leastNormalMagnitude,
                                         bottom: .leastNormalMagnitude,
                                         right: .leastNormalMagnitude)
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let newArea = CGRect(x: bounds.origin.x - extendedSize,
                             y: bounds.origin.y - extendedSize,
                             width: bounds.size.width + 2 * extendedSize,
                             height: bounds.size.height + 2 * extendedSize)
        return newArea.contains(point)
    }
}

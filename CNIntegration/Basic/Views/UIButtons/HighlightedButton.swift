//
//  HighlightedButton.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 29/08/2019.
//  Copyright © 2019 Pavel Pronin. All rights reserved.
//

class HighlightedButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    override var isEnabled: Bool {
        get {
            return super.isEnabled
        }
        set {
            if newValue {
                self.alpha = 1
            } else {
                self.alpha = 0.5
            }
            super.isEnabled = newValue
        }
    }

    override var isHighlighted: Bool {
        get {
            return super.isHighlighted
        }
        set {
            if newValue {
                self.alpha = 0.5
            } else {
                self.alpha = 1
            }
            super.isHighlighted = newValue
        }
    }

    private func commonInit() {
        adjustsImageWhenHighlighted = false
        adjustsImageWhenDisabled = false
    }
}

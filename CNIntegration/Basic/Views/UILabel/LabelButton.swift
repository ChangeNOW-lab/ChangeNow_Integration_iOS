//
//  LabelButton.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 27/12/2018.
//  Copyright © 2018 Pavel Pronin. All rights reserved.
//

class LabelButton: UILabel {

     var action: Action?

    override init(frame: CGRect) {
        super.init(frame: frame)
        addActionConfig()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addActionConfig()
    }

    private func addActionConfig() {
        isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(actionMethod))
        addGestureRecognizer(tap)
    }

    @objc
    private func actionMethod() {
        action?.perform()
    }

     override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        alpha = 0.5
    }

     override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        alpha = 1
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        alpha = 1
    }
}

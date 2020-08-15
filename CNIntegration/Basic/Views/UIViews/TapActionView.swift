//
//  TapActionView.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 19/02/2019.
//  Copyright © 2019 Pavel Pronin. All rights reserved.
//

class TapActionView: UIView {

    private var tapRecognizer: UITapGestureRecognizer?

    var onTapAction: Action? {
        didSet {
            if onTapAction != nil, tapRecognizer == nil {
                tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
                addGestureRecognizer(tapRecognizer!)
            }
        }
    }
    var isHighlightEnabled = true

    @objc
    private func handleTap() {
        onTapAction?.perform()
    }

    func makeHighlighted() {
        alpha = 0.5
    }

    func makeUnhighlighted() {
        alpha = 1
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if isHighlightEnabled {
            makeHighlighted()
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        if isHighlightEnabled {
            makeUnhighlighted()
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        if isHighlightEnabled {
            makeUnhighlighted()
        }
    }
}

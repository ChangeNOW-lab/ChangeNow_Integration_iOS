//
//  DefaultButton.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 26/03/2020.
//  Copyright © 2020 Pavel Pronin. All rights reserved.
//

class DefaultButton: ButtonExtendedTapArea {

    override var isHighlighted: Bool {
        set {
            guard isEnabled else { return }
            if newValue != isHighlighted && newValue == false {
                UIView.transition(with: self,
                                  duration: 0.3,
                                  options: [.allowUserInteraction, .transitionCrossDissolve],
                                  animations: { [weak self] in
                                    // using this method because of bug with calling super in closures
                                    // http://stackoverflow.com/questions/27142208/how-to-call-super-in-closure-in-swift
                                    self?.callSuperSetHighlighted(newValue)
                    },
                                  completion: nil)
            } else {
                self.callSuperSetHighlighted(newValue)
            }
        }
        get {
            return super.isHighlighted
        }
    }

    private func callSuperSetHighlighted(_ newValue: Bool) {
        super.isHighlighted = newValue
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    // MARK: Touch overriding
    // Overriding touches methods for disabling highlighted animation delay in UITableView

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)

        OperationQueue.main.addOperation { [weak self] in
            self?.isHighlighted = true
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)

        performSelector(inBackground: #selector(DefaultButton.setDefaultHighlightedState), with: nil)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)

        performSelector(inBackground: #selector(DefaultButton.setDefaultHighlightedState), with: nil)
    }

    @objc
    private dynamic func setDefaultHighlightedState() {
        OperationQueue.main.addOperation { [weak self] in
            self?.isHighlighted = false
        }
    }
}

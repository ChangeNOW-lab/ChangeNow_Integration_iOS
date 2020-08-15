//
//  UIButton+Additions.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 08/08/16.
//  Copyright © 2016 Pavel Pronin. All rights reserved.
//

extension UIButton {

    // MARK: Block based target action

    private struct AssociatedKeys {
        static var targetClosure = "targetClosure"
    }

    private var targetClosure: UIButtonTargetClosure? {
        get {
            guard let closureWrapper = objc_getAssociatedObject(self, &AssociatedKeys.targetClosure) as? ClosureWrapper else { return nil }
            return closureWrapper.closure
        }
        set(newValue) {
            guard let newValue = newValue else { return }
            objc_setAssociatedObject(self, &AssociatedKeys.targetClosure, ClosureWrapper(newValue), objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    func addTargetClosure(closure: @escaping UIButtonTargetClosure) {
        targetClosure = closure
        addTarget(self, action: #selector(UIButton.closureAction), for: .touchUpInside)
    }

    func removeTargetClosure() {
        targetClosure = nil
    }

    @objc
    func closureAction() {
        guard let targetClosure = targetClosure else { return }
        targetClosure(self)
    }

    func centerTextAndImage(spacing: CGFloat, removeHorizontalOffset: Bool = false, forceLTR: Bool? = nil) {
        let offset: CGFloat = removeHorizontalOffset ? .leastNormalMagnitude : 0
        let insetAmount = spacing / 2
        var sign: CGFloat = UIView.isLTR ? 1 : -1
        if let forceLTR = forceLTR {
            if forceLTR {
                sign = 1
            } else {
                sign = -1
            }
        }
        imageEdgeInsets = UIEdgeInsets(top: 0, left: -insetAmount * sign, bottom: 0, right: insetAmount * sign)
        titleEdgeInsets = UIEdgeInsets(top: 0, left: insetAmount * sign, bottom: 0, right: -insetAmount * sign)
        contentEdgeInsets = UIEdgeInsets(top: offset, left: insetAmount, bottom: offset, right: insetAmount)
    }

    func centerVertically(padding: CGFloat = 6) {
        guard
            let imageViewSize = imageView?.frame.size,
            let titleLabelSize = titleLabel?.frame.size else {
            return
        }

        let totalHeight = imageViewSize.height + titleLabelSize.height + padding

        imageEdgeInsets = UIEdgeInsets(
            top: -(totalHeight - imageViewSize.height),
            left: 0,
            bottom: 0,
            right: -titleLabelSize.width
        )
        titleEdgeInsets = UIEdgeInsets(
            top: 0,
            left: -imageViewSize.width,
            bottom: -(totalHeight - titleLabelSize.height),
            right: 0
        )

        let inset = (bounds.height - totalHeight) / 2
        contentEdgeInsets = UIEdgeInsets(top: inset, left: 0, bottom: inset, right: 0)
    }
}

typealias UIButtonTargetClosure = (UIButton) -> Void

class ClosureWrapper: NSObject {

    let closure: UIButtonTargetClosure

    init(_ closure: @escaping UIButtonTargetClosure) {
        self.closure = closure
    }
}

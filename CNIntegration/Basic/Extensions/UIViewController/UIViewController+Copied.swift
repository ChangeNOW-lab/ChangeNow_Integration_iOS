//
//  UIViewController+Copied.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 09.05.2020.
//  Copyright © 2020 proninps. All rights reserved.
//

import SnapKit

private var copiedLabel: EdgeInsetLabel = {
    let view = EdgeInsetLabel()
    let offset: CGFloat = 12
    view.textInsets = .init(vertical: offset, horizontal: offset)
    view.text = R.string.localizable.copied()
    view.font = .regularText
    view.textColor = .white
    view.backgroundColor = .background
    view.layer.cornerRadius = offset + UIFont.regularText.lineHeight / 2
    view.layer.masksToBounds = true
    return view
}()

private var constraint: Constraint?
private var additionalConstraint: Constraint?

extension UIViewController {

    func showCopiedLabel() {
        guard copiedLabel.superview == nil else { return }
        view.addSubview(copiedLabel)
        copiedLabel.snp.makeConstraints {
            constraint = $0.top.equalTo(view.snp.bottom).constraint
            additionalConstraint = $0.centerX.equalToSuperview().constraint
        }
        view.layoutIfNeeded()
        UIView.animate(withDuration: 0.4,
                       delay: 0,
                       options: [.allowUserInteraction, .curveEaseInOut],
                       animations: {
                        let extraSpace: CGFloat
                        if #available(iOS 11.0, *) {
                            extraSpace = UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0
                        } else {
                            extraSpace = 0
                        }
                        constraint?.update(offset: -(GlobalConsts.buttonHeight + extraSpace + 20))
                        self.view.layoutIfNeeded()
        },
                       completion: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: { [weak self] in
            self?.hideCopiedLabel()
        })
    }

    private func hideCopiedLabel() {
        UIView.animate(withDuration: 0.4,
                       delay: 0,
                       options: [.allowUserInteraction, .curveEaseInOut],
                       animations: {
                        constraint?.update(offset: 0)
                        self.view.layoutIfNeeded()
        },
                       completion: { _ in
                        copiedLabel.removeFromSuperview()
                        constraint?.deactivate()
                        additionalConstraint?.deactivate()
        })
    }
}

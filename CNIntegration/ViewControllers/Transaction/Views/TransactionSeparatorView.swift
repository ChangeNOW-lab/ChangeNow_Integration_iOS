//
//  TransactionSeparatorView.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 25.04.2020.
//  Copyright © 2020 proninps. All rights reserved.
//

import SnapKit

final class TransactionSeparatorView: UIView {

    private lazy var bottomSeparator: CALayer = {
        let separator = CALayer()
        separator.backgroundColor = UIColor.background.withAlphaComponent(0.1).cgColor
        return separator
    }()

    // MARK: - Life Cycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        layer.addSublayer(bottomSeparator)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        bottomSeparator.frame = CGRect(x: 0,
                                       y: bounds.height / 2,
                                       width: bounds.width,
                                       height: 1)
    }
}

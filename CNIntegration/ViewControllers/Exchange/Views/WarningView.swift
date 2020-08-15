//
//  WarningView.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 17.04.2020.
//  Copyright © 2020 proninps. All rights reserved.
//

import SnapKit

final class WarningView: UIView {

    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 0
        view.textColor = .white
        view.font = .smallTitle
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        addSubviews()
        setConstraints()

        backgroundColor = UIColor.certainOrange.withAlphaComponent(0.14)
        layer.cornerRadius = 2
        layer.masksToBounds = true
        layer.borderColor = UIColor.certainOrange.withAlphaComponent(0.63).cgColor
        layer.borderWidth = 1
    }

    // MARK: - Public

    func set(rate: Decimal, rateCurrency: String) {
        titleLabel.text = R.string.localizable.exchangeMinimumAmount(
            "\(rate.rounding(withMode: .down, scale: GlobalConsts.maxMantissa))",
            rateCurrency.uppercased()
        )
    }

    // MARK: - Private

    private func addSubviews() {
        addSubview(titleLabel)
    }

    private func setConstraints() {
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(GlobalConsts.internalSideOffset)
            $0.trailing.equalToSuperview().offset(-GlobalConsts.internalSideOffset)
            $0.top.equalToSuperview().offset(11)
            $0.bottom.equalToSuperview().offset(-11)
        }
    }
}


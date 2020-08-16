//
//  ChooseCurrencyTableViewHeader.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 19.04.2020.
//  Copyright © 2020 proninps. All rights reserved.
//

import Foundation

final class ChooseCurrencyTableViewHeader: UITableViewHeaderFooterView, Reusable {

    enum Style {
        case popular
        case fiat
        case other
    }

    private lazy var iconView: UIImageView = {
        let view = UIImageView()
        view.tintColor = .primarySelection
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 1
        view.textColor = .white
        view.font = .smallText
        return view
    }()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        addSubviews()
        setConstraints()

        contentView.backgroundColor = .background
    }

    // MARK: - Public

    func set(style: Style) {
        switch style {
        case .popular:
            titleLabel.text = R.string.localizable.chooseCurrencyPopular()
            iconView.image = R.image.heart()
        case .fiat:
            titleLabel.text = R.string.localizable.chooseCurrencyFiat()
            iconView.image = R.image.visaAndMastercard()
        case .other:
            titleLabel.text = R.string.localizable.chooseCurrencyOther()
            iconView.image = nil
        }
    }

    // MARK: - Private

    private func addSubviews() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(iconView)
    }

    private func setConstraints() {
        titleLabel.snp.makeConstraints {
            $0.centerY.leadingMargin.equalToSuperview()
        }
        iconView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(titleLabel.snp.trailing).offset(10)
        }
    }
}

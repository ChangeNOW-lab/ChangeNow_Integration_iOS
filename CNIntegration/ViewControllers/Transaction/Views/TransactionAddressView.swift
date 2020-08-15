//
//  TransactionAddressView.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 24.04.2020.
//  Copyright © 2020 proninps. All rights reserved.
//

import SnapKit

final class TransactionAddressView: UIView {

    private struct Consts {
        static let sideHorizontal: CGFloat = 16
        static let sideVertical: CGFloat = 11
        static let topOffset: CGFloat = 4
    }

    // MARK: - Views

    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 1
        view.font = .normalTitle
        view.textColor = UIColor.background.withAlphaComponent(0.6)
        return view
    }()

    private lazy var addressLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 0
        view.font = .mediumTitle
        view.textColor = .background
        return view
    }()

    private lazy var extraIdTitleLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 1
        view.font = .normalTitle
        view.textColor = UIColor.background.withAlphaComponent(0.6)
        return view
    }()

    private lazy var extraIdLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 0
        view.font = .mediumTitle
        view.textColor = .background
        return view
    }()

    private var extraIdTitleTopConstraint: Constraint?
    private var extraIdTopConstraint: Constraint?

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
        addSubviews()
        setConstraints()

        backgroundColor = .white
        layer.masksToBounds = true
        layer.cornerRadius = 6
        layer.borderWidth = 1
        layer.borderColor = UIColor.background.withAlphaComponent(0.1).cgColor
    }

    // MARK: - Public

    func set(address: String, currency: String, extraIdName: String?, extraId: String?) {
        titleLabel.text = R.string.localizable.transactionRecipientAddress(currency.uppercased())
        addressLabel.text = address
        if let extraId = extraId {
            extraIdTitleLabel.text = extraIdName ?? GlobalStrings.extraId
            extraIdLabel.text = extraId
            extraIdTitleTopConstraint?.layoutConstraints.first?.constant = Consts.topOffset
            extraIdTopConstraint?.layoutConstraints.first?.constant = Consts.topOffset
        } else {
            extraIdTitleLabel.text = nil
            extraIdLabel.text = nil
            extraIdTitleTopConstraint?.layoutConstraints.first?.constant = 0
            extraIdTopConstraint?.layoutConstraints.first?.constant = 0
        }
    }

    // MARK: - Private

    private func addSubviews() {
        addSubview(titleLabel)
        addSubview(addressLabel)
        addSubview(extraIdLabel)
        addSubview(extraIdTitleLabel)
    }

    private func setConstraints() {
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(Consts.sideVertical)
            $0.leading.equalToSuperview().offset(Consts.sideHorizontal)
            $0.trailing.equalToSuperview().offset(-Consts.sideHorizontal)
        }
        addressLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(Consts.topOffset)
            $0.leading.equalToSuperview().offset(Consts.sideHorizontal)
            $0.trailing.lessThanOrEqualToSuperview().offset(-Consts.sideHorizontal)
        }
        extraIdTitleLabel.snp.makeConstraints {
            extraIdTitleTopConstraint = $0.top.equalTo(addressLabel.snp.bottom).constraint
            $0.leading.equalToSuperview().offset(Consts.sideHorizontal)
            $0.trailing.lessThanOrEqualToSuperview().offset(-Consts.sideHorizontal)
        }
        extraIdLabel.snp.makeConstraints {
            extraIdTopConstraint = $0.top.equalTo(extraIdTitleLabel.snp.bottom).constraint
            $0.leading.equalToSuperview().offset(Consts.sideHorizontal)
            $0.trailing.equalToSuperview().offset(-Consts.sideHorizontal)
            $0.bottom.equalToSuperview().offset(-Consts.sideVertical)
        }
    }
}


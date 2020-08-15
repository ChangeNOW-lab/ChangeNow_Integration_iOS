//
//  TransactionGetDescriptionView.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 22.05.2020.
//  Copyright © 2020 proninps. All rights reserved.
//

import SnapKit

final class TransactionGetDescriptionView: UIView {

    private struct Consts {
        static let sideHorizontal: CGFloat = 16
        static let sideVertical: CGFloat = 11
        static let topOffset: CGFloat = 5
    }

    // MARK: - Views

    private lazy var valueTitleLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 1
        view.font = .normalDescription
        view.textColor = UIColor.background.withAlphaComponent(0.6)
        view.text = R.string.localizable.transactionYouGet()
        return view
    }()

    private lazy var valueLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 0
        view.font = .regularTitle
        view.textColor = UIColor.background.withAlphaComponent(0.6)
        return view
    }()

    private lazy var addressTitleLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 1
        view.font = .normalDescription
        view.textColor = UIColor.background.withAlphaComponent(0.6)
        return view
    }()

    private lazy var addressLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 0
        view.font = .regularTitle
        view.textColor = UIColor.background.withAlphaComponent(0.6)
        return view
    }()

    private lazy var extraIdTitleLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 1
        view.font = .normalDescription
        view.textColor = UIColor.background.withAlphaComponent(0.6)
        return view
    }()

    private lazy var extraIdLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 0
        view.font = .regularTitle
        view.textColor = UIColor.background.withAlphaComponent(0.6)
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

        backgroundColor = .lightBackground
    }

    // MARK: - Public

    func set(value: String, address: String, currency: String, extraIdName: String?, extraId: String?) {
        addressTitleLabel.text = R.string.localizable.transactionRecipientAddress(currency.uppercased())
        valueLabel.text = value
        addressLabel.text = address
        if let extraId = extraId {
            extraIdTitleLabel.text = extraIdName ?? GlobalStrings.extraId
            extraIdLabel.text = extraId
            extraIdTitleTopConstraint?.layoutConstraints.first?.constant = Consts.sideVertical
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
        addSubview(valueTitleLabel)
        addSubview(valueLabel)
        addSubview(addressTitleLabel)
        addSubview(addressLabel)
        addSubview(extraIdTitleLabel)
        addSubview(extraIdLabel)
    }

    private func setConstraints() {
        valueTitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(3)
            $0.leading.equalToSuperview().offset(Consts.sideHorizontal)
            $0.trailing.equalToSuperview().offset(-Consts.sideHorizontal)
        }
        valueLabel.snp.makeConstraints {
            $0.top.equalTo(valueTitleLabel.snp.bottom).offset(Consts.topOffset)
            $0.leading.equalToSuperview().offset(Consts.sideHorizontal)
            $0.trailing.equalToSuperview().offset(-Consts.sideHorizontal)
        }
        addressTitleLabel.snp.makeConstraints {
            $0.top.equalTo(valueLabel.snp.bottom).offset(Consts.sideVertical)
            $0.leading.equalToSuperview().offset(Consts.sideHorizontal)
            $0.trailing.lessThanOrEqualToSuperview().offset(-Consts.sideHorizontal)
        }
        addressLabel.snp.makeConstraints {
            $0.top.equalTo(addressTitleLabel.snp.bottom).offset(Consts.topOffset)
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
            $0.bottom.equalToSuperview()
        }
    }
}

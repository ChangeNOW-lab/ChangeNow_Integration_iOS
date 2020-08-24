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

    private lazy var transactionIdView = TransactionIdView()

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

    func set(value: String,
             address: String,
             currency: String,
             extraIdName: String?,
             extraId: String?,
             transactionId: String,
             transactionIdAction: Action) {
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
        transactionIdView.set(id: transactionId)
        transactionIdView.onTapAction = transactionIdAction
    }

    // MARK: - Private

    private func addSubviews() {
        addSubview(valueTitleLabel)
        addSubview(valueLabel)
        addSubview(addressTitleLabel)
        addSubview(addressLabel)
        addSubview(extraIdTitleLabel)
        addSubview(extraIdLabel)
        addSubview(transactionIdView)
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
        }
        transactionIdView.snp.makeConstraints {
            $0.top.equalTo(extraIdLabel.snp.bottom).offset(25)
            $0.leading.equalToSuperview().offset(Consts.sideHorizontal)
            $0.trailing.equalToSuperview().offset(-Consts.sideHorizontal)
            $0.bottom.equalToSuperview()
        }
    }
}

final class TransactionIdView: TapActionView {

    private struct Consts {
        static let switchButtonInset: CGFloat = 9
    }

    // MARK: - Views

    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 1
        view.textColor = UIColor.background.withAlphaComponent(0.6)
        view.font = .normalText
        view.text = R.string.localizable.transactionId()
        return view
    }()

    private lazy var idLabel: EdgeInsetLabel = {
        let view = EdgeInsetLabel()
        view.font = .normalText
        view.textColor = .background
        view.numberOfLines = 1
        view.textAlignment = .center
        view.backgroundColor = UIColor.background.withAlphaComponent(0.08)
        view.textInsets = .init(top: 2, left: 8, bottom: 2, right: 8)
        view.layer.masksToBounds = true
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.black.withAlphaComponent(0.1).cgColor
        return view
    }()

    private lazy var copyImageView: UIImageView = {
        let view = UIImageView()
        view.image = R.image.copy()
        view.tintColor = .background
        return view
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
        addSubviews()
        setConstraints()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        idLabel.layer.cornerRadius = idLabel.bounds.height / 2
    }

    // MARK: - Public

    func set(id: String) {
        idLabel.text = id
    }

    override func makeHighlighted() {
        idLabel.alpha = 0.5
        copyImageView.alpha = 0.5
    }

    override func makeUnhighlighted() {
        idLabel.alpha = 1
        copyImageView.alpha = 1
    }

    // MARK: - Private

    private func addSubviews() {
        addSubview(titleLabel)
        addSubview(idLabel)
        addSubview(copyImageView)
    }

    private func setConstraints() {
        titleLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview()
        }
        idLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.height.equalTo(22)
            $0.leading.equalTo(titleLabel.snp.trailing).offset(8)
        }
        copyImageView.snp.makeConstraints {
            $0.leading.equalTo(idLabel.snp.trailing).offset(4)
            $0.top.bottom.equalToSuperview()
            $0.size.equalTo(copyImageView.image?.size ?? .zero)
            $0.trailing.lessThanOrEqualToSuperview()
        }
    }
}

//
//  TransactionStatusDescriptionView.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 24.04.2020.
//  Copyright © 2020 proninps. All rights reserved.
//

final class TransactionStatusDescriptionView: UIView {

    enum Status {
        case deposit
        case exchanging
        case finished
        case finishedMore
        case refunded
    }

    private struct Consts {
        static let side: CGFloat = 12
    }

    // MARK: - Views

    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 2
        view.font = .normalDescription
        view.adjustsFontSizeToFitWidth = true
        view.textColor = UIColor.background.withAlphaComponent(0.6)
        return view
    }()

    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.tintColor = UIColor.background.withAlphaComponent(0.6)
        view.contentMode = .center
        return view
    }()

    private lazy var separator: UIView = {
        let separator = UIView()
        separator.backgroundColor = UIColor.lightBackground
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
        addSubviews()
        setConstraints()

        backgroundColor = .white
        layer.masksToBounds = true
        layer.cornerRadius = 6
        layer.borderWidth = 1
        layer.borderColor = UIColor.background.withAlphaComponent(0.1).cgColor
    }

    // MARK: - Public

    func set(status: Status) {
        switch status {
        case .deposit:
            titleLabel.text = R.string.localizable.transactionStatusDepositDescription()
            imageView.image = R.image.depositIcon()
        case .exchanging:
            titleLabel.text = R.string.localizable.transactionStatusExchangingDescription()
            imageView.image = R.image.exchangingIcon()
        case .finished:
            titleLabel.text = R.string.localizable.transactionStatusFinishedDescription()
            imageView.image = R.image.finishedIcon()
        case .finishedMore:
            titleLabel.text = R.string.localizable.transactionStatusFinishedMoreDescription()
            imageView.image = R.image.finishedMoreIcon()
        case .refunded:
            titleLabel.text = R.string.localizable.transactionStatusRefundedDescription()
            imageView.image = R.image.refundedIcon()
        }
    }

    // MARK: - Private

    private func addSubviews() {
        addSubview(titleLabel)
        addSubview(imageView)
        addSubview(separator)
    }

    private func setConstraints() {
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(Consts.side)
            $0.leading.equalTo(imageView.snp.trailing).offset(Consts.side)
            $0.trailing.equalToSuperview().offset(-Consts.side)
            $0.bottom.equalToSuperview().offset(-Consts.side)
        }
        imageView.snp.makeConstraints {
            $0.top.bottom.leading.equalToSuperview()
            $0.width.equalTo(60)
        }
        separator.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.equalTo(imageView.snp.trailing)
            $0.width.equalTo(1)
        }
    }
}

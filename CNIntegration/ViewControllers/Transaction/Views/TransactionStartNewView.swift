//
//  TransactionStartNewView.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 24.04.2020.
//  Copyright © 2020 proninps. All rights reserved.
//

final class TransactionStartNewView: TapActionView {

    enum Style {
        case success
        case failure
    }

    // MARK: - Views

    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 1
        view.adjustsFontSizeToFitWidth = true
        view.font = .normalDescription
        return view
    }()

    private lazy var actionLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 1
        view.font = .normalTitle
        view.textColor = .white
        view.textAlignment = .center
        view.text = R.string.localizable.transactionStartNewAction()
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

        layer.masksToBounds = true
        layer.cornerRadius = 6
        layer.borderWidth = 1
    }

    // MARK: - Public

    func set(style: Style) {
        switch style {
        case .success:
            layer.borderColor = UIColor.primarySelection.withAlphaComponent(0.2).cgColor
            actionLabel.backgroundColor = UIColor.primarySelection.withAlphaComponent(0.76)
            backgroundColor = UIColor.primarySelection.withAlphaComponent(0.05)
            titleLabel.textColor = .primarySelection
            titleLabel.text = R.string.localizable.transactionStartNewSuccess()
        case .failure:
            layer.borderColor = UIColor.background.withAlphaComponent(0.4).cgColor
            actionLabel.backgroundColor = UIColor.background.withAlphaComponent(0.75)
            backgroundColor = UIColor.background.withAlphaComponent(0.05)
            titleLabel.textColor = .background
            titleLabel.text = R.string.localizable.transactionStartNewFailure()
        }
    }

    // MARK: - Private

    private func addSubviews() {
        addSubview(titleLabel)
        addSubview(actionLabel)
    }

    private func setConstraints() {
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(14)
            $0.leading.equalToSuperview().offset(12)
            $0.trailing.equalTo(actionLabel.snp.leading).offset(-12)
            $0.bottom.equalToSuperview().offset(-14)
        }
        actionLabel.snp.makeConstraints {
            $0.top.bottom.trailing.equalToSuperview()
            $0.width.equalTo(100)
        }
    }
}


//
//  TransactionHeaderView.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 26.06.2020.
//  Copyright © 2020 proninps. All rights reserved.
//

final class TransactionHeaderView: UIView {

    enum Status {
        case deposit
        case exchanging
        case finished
        case refunded
        case failed
    }

    // MARK: - Views

    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 1
        switch Device.model {
        case .iPhone5, .iPhone6:
            view.font = .mediumHeadline
        default:
            view.font = .greatHeadline
        }
        view.textColor = .white
        return view
    }()

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        if #available(iOS 13.0, *) {
            view.style = .medium
        } else {
            view.style = .white
        }
        view.color = .white
        view.hidesWhenStopped = true
        return view
    }()

    private lazy var cancelButton: DefaultButton = {
        let view = DefaultButton()
        view.titleLabel?.font = .normalTitle
        view.setTitle(R.string.localizable.cancel(), for: .normal)
        view.setTitleColor(.placeholder, for: .normal)
        view.addTarget(self, action: #selector(cancelButtonAction), for: .touchUpInside)
        return view
    }()

    private lazy var backButton: DefaultButton = {
        let view = DefaultButton()
        view.setImage(R.image.backIcon(), for: .normal)
        view.imageView?.tintColor = .white
        view.transform.a = UIView.isLTR ? 1 : -1
        view.addTarget(self, action: #selector(backButtonAction), for: .touchUpInside)
        return view
    }()

    private lazy var idButton: DefaultButton = {
        let view = DefaultButton()
        view.titleLabel?.font = .normalTitle
        view.imageView?.tintColor = UIColor.placeholder
        view.setImage(R.image.copy(), for: .normal)
        view.setTitleColor(.placeholder, for: .normal)
        view.addTarget(self, action: #selector(idButtonAction), for: .touchUpInside)
        view.semanticContentAttribute = UIView.isLTR ? .forceRightToLeft : .forceLeftToRight
        return view
    }()

    private let isInNavigationStack: Bool

    // MARK: - Public

    var idAction: Action?
    var cancelAction: Action?
    var backAction: Action?

    // MARK: - Life Cycle

    init(isInNavigationStack: Bool) {
        self.isInNavigationStack = isInNavigationStack
        super.init(frame: .zero)
        commonInit()
    }

    required init?(coder: NSCoder) {
        self.isInNavigationStack = false
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        addSubviews()
        setConstraints()

        preservesSuperviewLayoutMargins = true
    }

    // MARK: - Public

    func set(id: String) {
        idButton.setTitle(id, for: .normal)
    }

    func set(status: Status) {
        switch status {
        case .deposit:
            activityIndicator.stopAnimating()
            titleLabel.text = R.string.localizable.transactionStatusDeposit()
            cancelButton.isHidden = false
            idButton.isHidden = true
        case .exchanging:
            activityIndicator.startAnimating()
            titleLabel.text = R.string.localizable.transactionStatusExchanging()
            cancelButton.isHidden = true
            idButton.isHidden = false
        case .finished:
            activityIndicator.stopAnimating()
            titleLabel.text = R.string.localizable.transactionStatusFinished()
            cancelButton.isHidden = true
            idButton.isHidden = false
        case .refunded:
            activityIndicator.stopAnimating()
            titleLabel.text = R.string.localizable.transactionStatusRefunded()
            cancelButton.isHidden = true
            idButton.isHidden = false
        case .failed:
            activityIndicator.stopAnimating()
            titleLabel.text = R.string.localizable.transactionStatusFailed()
            cancelButton.isHidden = true
            idButton.isHidden = false
        }
    }

    // MARK: - Private

    private func addSubviews() {
        if isInNavigationStack {
            addSubview(backButton)
        }
        addSubview(titleLabel)
        addSubview(activityIndicator)
        addSubview(cancelButton)
        addSubview(idButton)
    }

    private func setConstraints() {
        if isInNavigationStack {
            backButton.snp.makeConstraints {
                $0.centerY.equalTo(titleLabel.snp.centerY)
                $0.leadingMargin.equalToSuperview()
            }
        }
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            if isInNavigationStack {
                $0.leading.equalTo(backButton.snp.trailing).offset(18)
            } else {
                $0.leadingMargin.equalToSuperview()
            }
            $0.bottom.equalToSuperview()
        }
        activityIndicator.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel.snp.centerY)
            $0.leading.equalTo(titleLabel.snp.trailing).offset(10)
            $0.height.equalTo(24)
        }
        cancelButton.snp.makeConstraints {
            $0.bottom.equalToSuperview()
            $0.trailingMargin.equalToSuperview()
        }
        idButton.snp.makeConstraints {
            $0.bottom.equalToSuperview()
            $0.trailingMargin.equalToSuperview()
        }
    }

    @objc
    private func idButtonAction() {
        idAction?.perform()
    }

    @objc
    private func cancelButtonAction() {
        cancelAction?.perform()
    }

    @objc
    private func backButtonAction() {
        backAction?.perform()
    }
}


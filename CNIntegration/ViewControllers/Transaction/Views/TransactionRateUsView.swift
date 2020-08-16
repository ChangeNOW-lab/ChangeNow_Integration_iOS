//
//  TransactionRateUsView.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 26.06.2020.
//  Copyright © 2020 proninps. All rights reserved.
//

final class TransactionRateUsView: UIView {

    private struct Consts {
        static let side: CGFloat = 12
    }

    // MARK: - Views

    private lazy var textLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 2
        view.adjustsFontSizeToFitWidth = true
        view.font = .normalDescription
        view.textColor = UIColor.background.withAlphaComponent(0.6)
        view.textAlignment = .center
        return view
    }()

    private lazy var rateUsButton: DefaultButton = {
        let view = DefaultButton()
        view.titleLabel?.font = .normalTitle
        view.imageView?.tintColor = .primarySelection
        view.setImage(R.image.like(), for: .normal)
        view.setTitleColor(.background, for: .normal)
        view.setTitle(R.string.localizable.transactionRateUsButton(), for: .normal)
        view.centerTextAndImage(spacing: 4, removeHorizontalOffset: true, forceLTR: !UIView.isLTR)
        view.addTarget(self, action: #selector(rateUsButtonAction), for: .touchUpInside)
        view.semanticContentAttribute = UIView.isLTR ? .forceRightToLeft : .forceLeftToRight
        return view
    }()

    private lazy var separator: CALayer = {
        let separator = CALayer()
        separator.backgroundColor = UIColor.background.withAlphaComponent(0.1).cgColor
        return separator
    }()

    // MARK: - Public

    var rateUsAction: Action?

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

    override func layoutSubviews() {
        super.layoutSubviews()

        separator.frame = CGRect(x: 0,
                                 y: rateUsButton.frame.minY,
                                 width: frame.width,
                                 height: 1)
    }

    func set(isMoreThenExpected: Bool) {
        if isMoreThenExpected {
            textLabel.text = R.string.localizable.transactionRateUsTitleMore()
        } else {
            textLabel.text = R.string.localizable.transactionRateUsTitle()
        }
    }

    // MARK: - Private

    private func addSubviews() {
        addSubview(textLabel)
        addSubview(rateUsButton)
        layer.addSublayer(separator)
    }

    private func setConstraints() {
        textLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(Consts.side)
            $0.leading.equalToSuperview().offset(Consts.side)
            $0.trailing.equalToSuperview().offset(-Consts.side)
        }
        rateUsButton.snp.makeConstraints {
            $0.top.equalTo(textLabel.snp.bottom).offset(9)
            $0.leading.equalToSuperview().offset(Consts.side)
            $0.trailing.equalToSuperview().offset(-Consts.side)
            $0.height.equalTo(44)
            $0.bottom.equalToSuperview()
        }
    }

    @objc
    private func rateUsButtonAction() {
        rateUsAction?.perform()
    }
}


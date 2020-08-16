//
//  TransactionSupportView.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 24.04.2020.
//  Copyright © 2020 proninps. All rights reserved.
//

final class TransactionSupportView: UIView {

    private struct Consts {
        static let side: CGFloat = 12
    }

    // MARK: - Views

    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 1
        view.adjustsFontSizeToFitWidth = true
        view.font = .normalHeadline
        view.textColor = UIColor.background.withAlphaComponent(0.6)
        view.textAlignment = .center
        view.text = R.string.localizable.transactionSupportTitle()
        return view
    }()

    private lazy var textLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 3
        view.adjustsFontSizeToFitWidth = true
        view.font = .normalDescription
        view.textColor = UIColor.background.withAlphaComponent(0.6)
        view.textAlignment = .center
        view.text = R.string.localizable.transactionSupportText(ChangeNOW.supportMail)
        return view
    }()

    private lazy var supportButton: DefaultButton = {
        let view = DefaultButton()
        view.titleLabel?.font = .normalTitle
        view.imageView?.tintColor = .primaryRed
        view.setImage(R.image.mail(), for: .normal)
        view.setTitleColor(.primaryRed, for: .normal)
        view.setTitle(R.string.localizable.transactionSupportButton(), for: .normal)
        view.centerTextAndImage(spacing: 8, removeHorizontalOffset: true, forceLTR: !UIView.isLTR)
        view.addTarget(self, action: #selector(supportButtonAction), for: .touchUpInside)
        view.semanticContentAttribute = UIView.isLTR ? .forceRightToLeft : .forceLeftToRight
        return view
    }()
    
    private lazy var separator: CALayer = {
        let separator = CALayer()
        separator.backgroundColor = UIColor.background.withAlphaComponent(0.1).cgColor
        return separator
    }()

    // MARK: - Public

    var supportAction: Action?

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
                                 y: supportButton.frame.minY,
                                 width: frame.width,
                                 height: 1)
    }

    // MARK: - Private

    private func addSubviews() {
        addSubview(titleLabel)
        addSubview(textLabel)
        addSubview(supportButton)
        layer.addSublayer(separator)
    }

    private func setConstraints() {
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(Consts.side)
            $0.leading.equalToSuperview().offset(Consts.side)
            $0.trailing.equalToSuperview().offset(-Consts.side)
        }
        textLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom)
            $0.leading.equalToSuperview().offset(Consts.side)
            $0.trailing.equalToSuperview().offset(-Consts.side)
        }
        supportButton.snp.makeConstraints {
            $0.top.equalTo(textLabel.snp.bottom).offset(9)
            $0.leading.equalToSuperview().offset(Consts.side)
            $0.trailing.equalToSuperview().offset(-Consts.side)
            $0.height.equalTo(44)
            $0.bottom.equalToSuperview()
        }
    }

    @objc
    private func supportButtonAction() {
        supportAction?.perform()
    }
}

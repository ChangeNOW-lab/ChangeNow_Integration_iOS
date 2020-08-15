//
//  TransactionDepositView.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 24.04.2020.
//  Copyright © 2020 proninps. All rights reserved.
//

import SnapKit

final class TransactionDepositView: UIView {

    private struct Consts {
        static let topTitleOffset: CGFloat = 9
        static let topOffset: CGFloat = 3
        static let side: CGFloat = {
            switch Device.model {
            case .iPhone5, .iPhone6:
                return 12
            default:
                return 16
            }
        }()
    }

    // MARK: - Views

    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 1
        view.adjustsFontSizeToFitWidth = true
        let changeNow = R.string.localizable.transactionDepositTitleChangeNOW()
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = UIView.isLTR ? .left : .right
        let attributedText = NSMutableAttributedString(
            string: R.string.localizable.transactionDepositTitle(changeNow),
            attributes: [
                .font: UIFont.normalDescription,
                .foregroundColor: UIColor.background.withAlphaComponent(0.5),
                .paragraphStyle: paragraphStyle
            ]
        )
        if let range = attributedText.string.range(of: changeNow) {
            attributedText.addAttributes([.font: UIFont.normalTitle],
                                         range: NSRange(range, in: attributedText.string))
        }
        view.attributedText = attributedText
        return view
    }()

    private lazy var moneyTitleLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 0
        view.font = .regularDescription
        view.textColor = UIColor.background
        view.text = R.string.localizable.transactionDepositMoney()
        return view
    }()

    private lazy var moneyLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 0
        view.font = .mediumHeadline
        view.textColor = UIColor.background
        return view
    }()

    private lazy var addressTitleLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 0
        view.font = .regularDescription
        view.textColor = UIColor.background
        view.text = R.string.localizable.transactionDepositAddress()
        return view
    }()

    private lazy var addressLabel: LabelButton = {
        let view = LabelButton()
        view.numberOfLines = 0
        return view
    }()

    private lazy var extraIdTitleLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 0
        view.font = .regularDescription
        view.textColor = UIColor.background
        return view
    }()

    private lazy var extraIdLabel: LabelButton = {
        let view = LabelButton()
        view.numberOfLines = 0
        return view
    }()

    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 6
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.certainMain.cgColor
        view.layer.masksToBounds = true
        return view
    }()

    private lazy var appsTitleLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 0
        let oneTap = R.string.localizable.transactionDepositViaAppsOneTap()
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = UIView.isLTR ? .left : .right
        let attributedText = NSMutableAttributedString(
            string: R.string.localizable.transactionDepositViaApps(oneTap),
            attributes: [
                .font: UIFont.normalDescription,
                .foregroundColor: UIColor.background,
                .paragraphStyle: paragraphStyle
            ]
        )
        if let range = attributedText.string.range(of: oneTap) {
            attributedText.addAttributes([.font: UIFont.normalTitle],
                                         range: NSRange(range, in: attributedText.string))
        }
        view.attributedText = attributedText
        return view
    }()

    private lazy var shareButton: DefaultButton = {
        let view = DefaultButton()
        view.titleLabel?.font = .minorDescription
        view.setImage(R.image.shareDark(), for: .normal)
        view.setTitle(R.string.localizable.transactionDepositShare(), for: .normal)
        view.setTitleColor(.black, for: .normal)
        view.setBackgroundImage(UIImage.slightlyGreenImage, for: .normal)
        view.addTarget(self, action: #selector(shareButtonAction), for: .touchUpInside)
        view.centerTextAndImage(spacing: 8)
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 4
        return view
    }()

    private lazy var showQRButton: DefaultButton = {
        let view = DefaultButton()
        view.titleLabel?.font = .minorDescription
        view.setImage(R.image.qrDark(), for: .normal)
        view.setTitle(R.string.localizable.transactionDepositShowQR(), for: .normal)
        view.setTitleColor(.black, for: .normal)
        view.setBackgroundImage(UIImage.slightlyGreenImage, for: .normal)
        view.addTarget(self, action: #selector(showQRButtonAction), for: .touchUpInside)
        view.centerTextAndImage(spacing: 8)
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 4
        return view
    }()

    private lazy var trustWalletButton: DefaultButton = {
        let view = DefaultButton()
        view.setImage(R.image.trustWallet(), for: .normal)
        view.setBackgroundImage(UIImage.whiteImage, for: .normal)
        view.addTarget(self, action: #selector(trustWalletButtonAction), for: .touchUpInside)
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 6
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.background.withAlphaComponent(0.1).cgColor
        return view
    }()

    private lazy var trustWalletIcon: UIImageView = {
        let view = UIImageView()
        view.image = R.image.deeplink()
        return view
    }()

    private var extraIdTitleContsraint: Constraint?
    private var extraIdContsraint: Constraint?

    // MARK: - Public

    var copyAddressAction: Action? {
        didSet {
            addressLabel.action = copyAddressAction
        }
    }
    var copyExtraIdAction: Action? {
        didSet {
            extraIdLabel.action = copyExtraIdAction
        }
    }
    var shareAction: Action?
    var showQRAction: Action?
    var trustWalletAction: Action?
    var guardaWalletAction: Action?

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

    // MARK: - Public

    func set(amount: Decimal, currency: String, address: String, extraIdName: String?, extraId: String?) {
        moneyLabel.text = "\(amount) \(currency.uppercased())".wrapDirection()
        addressLabel.attributedText = attributedCopyText(text: address)
        if let extraId = extraId {
            extraIdTitleContsraint?.update(offset: Consts.topTitleOffset)
            extraIdContsraint?.update(offset: Consts.topOffset)
            extraIdTitleLabel.text = "\(extraIdName ?? GlobalStrings.extraId):".wrapDirection()
            extraIdLabel.attributedText = attributedCopyText(text: extraId)
        } else {
            extraIdTitleContsraint?.update(offset: 0)
            extraIdContsraint?.update(offset: 0)
            extraIdTitleLabel.text = nil
            extraIdLabel.attributedText = nil
        }
    }

    // MARK: - Private

    private func addSubviews() {
        addSubview(titleLabel)
        addSubview(containerView)

        containerView.addSubview(moneyTitleLabel)
        containerView.addSubview(moneyLabel)
        containerView.addSubview(addressTitleLabel)
        containerView.addSubview(addressLabel)
        containerView.addSubview(extraIdTitleLabel)
        containerView.addSubview(extraIdLabel)
        containerView.addSubview(showQRButton)
        containerView.addSubview(shareButton)
        containerView.addSubview(appsTitleLabel)
        containerView.addSubview(trustWalletButton)

        trustWalletButton.addSubview(trustWalletIcon)
    }

    private func setConstraints() {
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(3)
            $0.leading.equalToSuperview().offset(5)
            $0.trailing.equalToSuperview()
        }
        containerView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }

        moneyTitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(Consts.side)
            $0.leading.equalToSuperview().offset(Consts.side)
            $0.trailing.equalToSuperview().offset(-Consts.side)
        }
        moneyLabel.snp.makeConstraints {
            $0.top.equalTo(moneyTitleLabel.snp.bottom).offset(Consts.topOffset)
            $0.leading.equalToSuperview().offset(Consts.side)
            $0.trailing.equalToSuperview().offset(-Consts.side)
        }
        addressTitleLabel.snp.makeConstraints {
            $0.top.equalTo(moneyLabel.snp.bottom).offset(Consts.side)
            $0.leading.equalToSuperview().offset(Consts.side)
            $0.trailing.equalToSuperview().offset(-Consts.side)
        }
        addressLabel.snp.makeConstraints {
            $0.top.equalTo(addressTitleLabel.snp.bottom).offset(Consts.topOffset)
            $0.leading.equalToSuperview().offset(Consts.side)
            $0.trailing.equalToSuperview().offset(-Consts.side)
        }
        extraIdTitleLabel.snp.makeConstraints {
            extraIdTitleContsraint = $0.top.equalTo(addressLabel.snp.bottom).constraint
            $0.leading.equalToSuperview().offset(Consts.side)
            $0.trailing.equalToSuperview().offset(-Consts.side)
        }
        extraIdLabel.snp.makeConstraints {
            extraIdContsraint = $0.top.equalTo(extraIdTitleLabel.snp.bottom).constraint
            $0.leading.equalToSuperview().offset(Consts.side)
            $0.trailing.equalToSuperview().offset(-Consts.side)
        }
        showQRButton.snp.makeConstraints {
            $0.top.equalTo(extraIdLabel.snp.bottom).offset(11)
            $0.leading.equalToSuperview().offset(Consts.side)
            $0.height.equalTo(42)
        }
        shareButton.snp.makeConstraints {
            $0.top.equalTo(showQRButton.snp.top)
            $0.leading.equalTo(showQRButton.snp.trailing).offset(9)
            $0.trailing.equalToSuperview().offset(-Consts.side)
            $0.height.equalTo(showQRButton.snp.height)
            $0.width.equalTo(showQRButton.snp.width)
        }

        let appsTopOffset: CGFloat
        switch Device.model {
        case .iPhone5, .iPhone6:
            appsTopOffset = Consts.side
        default:
            appsTopOffset = 24
        }
        appsTitleLabel.snp.makeConstraints {
            $0.top.equalTo(showQRButton.snp.bottom).offset(appsTopOffset)
            $0.leading.equalToSuperview().offset(Consts.side)
            $0.trailing.equalToSuperview().offset(-Consts.side)
        }
        trustWalletButton.snp.makeConstraints {
            $0.top.equalTo(appsTitleLabel.snp.bottom).offset(7)
            $0.leading.equalToSuperview().offset(Consts.side)
            $0.trailing.equalToSuperview().offset(-Consts.side)
            $0.height.equalTo(44)
            $0.bottom.equalToSuperview().offset(-Consts.side)
        }
        trustWalletIcon.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-12)
        }
    }

    private func attributedCopyText(text: String) -> NSAttributedString {
        let font = UIFont.mediumTitle
        let attributedText = NSMutableAttributedString(
            string: text,
            attributes: [.font: font]
        )
        let image = R.image.copy()?.withRenderingMode(.alwaysTemplate)
        let imageSize = image?.size ?? .zero
        let imageAttachmnet = NSTextAttachment()
        imageAttachmnet.image = image
        imageAttachmnet.bounds = CGRect(x: 0,
                                        y: (font.xHeight - imageSize.height) / 2,
                                        width: imageSize.width,
                                        height: imageSize.height)
        attributedText.append(attachment: imageAttachmnet)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = UIView.isLTR ? .left : .right
        attributedText.addAttributes([
            .foregroundColor: UIColor.certainMain,
            .paragraphStyle: paragraphStyle
        ], range: NSRange(location: 0, length: attributedText.length))
        return attributedText
    }

    // MARK: - Actions

    @objc
    private func shareButtonAction() {
        shareAction?.perform()
    }

    @objc
    private func showQRButtonAction() {
        showQRAction?.perform()
    }

    @objc
    private func trustWalletButtonAction() {
        trustWalletAction?.perform()
    }

    @objc
    private func guardaWalletButtonAction() {
        guardaWalletAction?.perform()
    }
}

//
//  DepositQRView.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 28.04.2020.
//  Copyright © 2020 proninps. All rights reserved.
//

import SnapKit

class DepositQRView: UIView {

    private struct Consts {
        static let qrSize: CGSize = .init(width: 230, height: 230)
    }

    // MARK: - Views

    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 1
        view.textColor = .black
        view.font = .medianTitle
        view.textAlignment = .center
        return view
    }()

    private lazy var addressTitleLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 0
        view.textColor = UIColor.background.withAlphaComponent(0.6)
        view.font = .normalTitle
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
        view.textColor = UIColor.background.withAlphaComponent(0.6)
        view.font = .normalTitle
        return view
    }()

    private lazy var extraIdLabel: LabelButton = {
        let view = LabelButton()
        view.numberOfLines = 0
        return view
    }()

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .gray)
        return view
    }()

    private lazy var qrImageView: UIImageView = {
        let view = UIImageView()
        return view
    }()

    private lazy var closeButton: DefaultButton = {
        let view = DefaultButton()
        view.setImage(R.image.closeLight(), for: .normal)
        view.addTarget(self, action: #selector(closeButtonAction), for: .touchUpInside)
        return view
    }()

    private var extraIdTitleConstraint: Constraint?
    private var extraIdConstraint: Constraint?

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
    var closeAction: Action?

    // MARK: - Life Cycle

    init(qrCode: String, currency: String, extraIdName: String?, extraId: String?) {
        super.init(frame: .zero)
        commonInit()
        set(qrCode: qrCode, currency: currency, extraIdName: extraIdName, extraId: extraId)
    }

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
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        maskByRoundingCorners([.topLeft, .topRight], withRadii: CGSize(width: 13, height: 13))
    }

    // MARK: - Public

    func set(qrCode: String, currency: String, extraIdName: String?, extraId: String?) {
        titleLabel.text = R.string.localizable.depositQRWallet(currency.uppercased())

        addressTitleLabel.text = R.string.localizable.depositQRWallet(currency.uppercased())
        addressLabel.attributedText = attributedCopyText(text: qrCode)
        if let extraId = extraId {
            extraIdTitleConstraint?.update(offset: 12)
            extraIdConstraint?.update(offset: 3)
            extraIdTitleLabel.text = extraIdName ?? GlobalStrings.extraId
            extraIdLabel.attributedText = attributedCopyText(text: extraId)
        } else {
            extraIdTitleConstraint?.update(offset: 0)
            extraIdConstraint?.update(offset: 0)
            extraIdTitleLabel.text = nil
            extraIdLabel.attributedText = nil
        }

        activityIndicator.startAnimating()
        DispatchQueue.global().async {
            let data = qrCode.data(using: .ascii)
            if let filter = CIFilter(name: "CIQRCodeGenerator") {
                filter.setValue(data, forKey: "inputMessage")
                let transform = CGAffineTransform(scaleX: Consts.qrSize.width, y: Consts.qrSize.height)
                if let output = filter.outputImage?.transformed(by: transform) {
                    let image = UIImage(ciImage: output)
                    DispatchQueue.main.async { [weak self] in
                        self?.qrImageView.image = image
                        self?.activityIndicator.stopAnimating()
                    }
                }
            }
        }
    }

    // MARK: - Private

    private func attributedCopyText(text: String) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = UIView.isLTR ? .left : .right
        let attributedText = NSMutableAttributedString(
            string: text,
            attributes: [
                .font: UIFont.mediumTitle,
                .foregroundColor: UIColor.background,
                .paragraphStyle: paragraphStyle
            ]
        )
        if let copyImage = R.image.copy() {
            let imageAttachmnet = NSTextAttachment()
            imageAttachmnet.image = copyImage
            imageAttachmnet.bounds = CGRect(x: 0,
                                            y: (UIFont.mediumTitle.xHeight - copyImage.size.height) / 2,
                                            width: copyImage.size.width,
                                            height: copyImage.size.height)
            attributedText.append(attachment: imageAttachmnet)
        }
        return attributedText
    }

    private func addSubviews() {
        addSubview(titleLabel)
        addSubview(closeButton)
        addSubview(qrImageView)
        qrImageView.addSubview(activityIndicator)
        addSubview(addressTitleLabel)
        addSubview(addressLabel)
        addSubview(extraIdTitleLabel)
        addSubview(extraIdLabel)
    }

    private func setConstraints() {
        let topOffset: CGFloat = 30
        let sideOffset: CGFloat = 6

        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(20)
        }
        closeButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-5)
            $0.top.equalToSuperview().offset(5)
        }
        qrImageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(titleLabel.snp.bottom).offset(topOffset)
            $0.size.equalTo(Consts.qrSize)
        }
        activityIndicator.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        addressTitleLabel.snp.makeConstraints {
            $0.leadingMargin.equalToSuperview().offset(sideOffset)
            $0.trailingMargin.equalToSuperview().offset(-sideOffset)
            $0.top.equalTo(qrImageView.snp.bottom).offset(topOffset)
        }
        addressLabel.snp.makeConstraints {
            $0.leadingMargin.equalToSuperview().offset(sideOffset)
            $0.trailingMargin.equalToSuperview().offset(-sideOffset)
            $0.top.equalTo(addressTitleLabel.snp.bottom).offset(3)
        }
        extraIdTitleLabel.snp.makeConstraints {
            $0.leadingMargin.equalToSuperview().offset(sideOffset)
            $0.trailingMargin.equalToSuperview().offset(-sideOffset)
            extraIdTitleConstraint = $0.top.equalTo(addressLabel.snp.bottom).constraint
        }
        extraIdLabel.snp.makeConstraints {
            $0.leadingMargin.equalToSuperview().offset(sideOffset)
            $0.trailingMargin.equalToSuperview().offset(-sideOffset)
            extraIdConstraint = $0.top.equalTo(extraIdTitleLabel.snp.bottom).constraint
            let extraSpace: CGFloat
            if #available(iOS 11.0, *) {
                extraSpace = UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0
            } else {
                extraSpace = 0
            }
            $0.bottom.equalToSuperview().offset(-50 - extraSpace)
        }
    }

    // MARK: - Actions

    @objc
    private func closeButtonAction() {
        closeAction?.perform()
    }
}


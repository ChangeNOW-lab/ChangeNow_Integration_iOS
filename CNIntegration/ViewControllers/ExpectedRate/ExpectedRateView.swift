//
//  ExpectedRateView.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 18.04.2020.
//  Copyright © 2020 proninps. All rights reserved.
//

import SnapKit

class ExpectedRateView: UIView {

    private enum Consts {
        static let side: CGFloat = 29
    }

    // MARK: - Views

    private lazy var firstTitleLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 0
        view.textColor = .background
        view.font = .regularHeader
        view.text = R.string.localizable.exchangeExpectedRateTitle()
        return view
    }()

    private lazy var firstTextLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 0
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = UIView.isLTR ? .left : .right
        let text = NSMutableAttributedString(
            string: R.string.localizable.exchangeExpectedRateDescription(),
            attributes: [
                .foregroundColor: UIColor.background.withAlphaComponent(0.8),
                .font: UIFont.normalTitle,
                .paragraphStyle: paragraphStyle
        ])
        if let range = text.string.range(of: R.string.localizable.exchangeExpectedRateDescriptionBest()) {
            text.addAttributes([.font: UIFont.normalHeader], range: NSRange(range, in: text.string))
        }
        view.attributedText = text
        return view
    }()

    private lazy var secondTextLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 0
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = UIView.isLTR ? .left : .right
        let text = NSMutableAttributedString(
                   string: R.string.localizable.exchangeExpectedRateFees(),
                   attributes: [
                       .foregroundColor: UIColor.background.withAlphaComponent(0.8),
                       .font: UIFont.normalTitle,
                       .paragraphStyle: paragraphStyle
               ])
               if let range = text.string.range(of: R.string.localizable.exchangeExpectedRateFeesIncluded()) {
                   text.addAttributes([.font: UIFont.normalHeader], range: NSRange(range, in: text.string))
               }
        view.attributedText = text
        return view
    }()

    private lazy var thirdTextLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 0
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = UIView.isLTR ? .left : .right
        let text = NSMutableAttributedString(
            string: R.string.localizable.exchangeExpectedRateNoExtraCosts(),
            attributes: [
                .foregroundColor: UIColor.background.withAlphaComponent(0.8),
                .font: UIFont.normalTitle,
                .paragraphStyle: paragraphStyle
        ])
        if let range = text.string.range(of: R.string.localizable.exchangeExpectedRateNoExtraCostsGuarantee()) {
            text.addAttributes([.font: UIFont.normalHeader], range: NSRange(range, in: text.string))
        }
        view.attributedText = text
        return view
    }()

    private lazy var closeButton: DefaultButton = {
        let view = DefaultButton()
        view.setImage(R.image.closeLight(), for: .normal)
        view.addTarget(self, action: #selector(closeButtonAction), for: .touchUpInside)
        return view
    }()

    // MARK: - Public

    var closeAction: Action?

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

        backgroundColor = UIColor.white.withAlphaComponent(0.72)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        maskByRoundingCorners([.topLeft, .topRight], withRadii: CGSize(width: 13, height: 13))
    }

    // MARK: - Private

    private func addSubviews() {
        addSubview(firstTitleLabel)
        addSubview(closeButton)
        addSubview(firstTextLabel)
        addSubview(secondTextLabel)
        addSubview(thirdTextLabel)
    }

    private func setConstraints() {
        firstTitleLabel.snp.makeConstraints {
            $0.leadingMargin.equalToSuperview().offset(Consts.side)
            $0.trailingMargin.equalTo(closeButton.snp.leading)
            $0.top.equalToSuperview().offset(27)
        }
        closeButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-5)
            $0.top.equalToSuperview().offset(5)
            $0.size.equalTo(CGSize(width: 44, height: 44))
        }
        let topOffset: CGFloat = 18
        firstTextLabel.snp.makeConstraints {
            $0.leadingMargin.equalToSuperview().offset(Consts.side)
            $0.trailingMargin.equalTo(closeButton.snp.leading)
            $0.top.equalTo(firstTitleLabel.snp.bottom).offset(topOffset)
        }
        secondTextLabel.snp.makeConstraints {
            $0.leadingMargin.equalToSuperview().offset(Consts.side)
            $0.trailingMargin.equalTo(closeButton.snp.leading)
            $0.top.equalTo(firstTextLabel.snp.bottom).offset(topOffset)
        }
        thirdTextLabel.snp.makeConstraints {
            $0.leadingMargin.equalToSuperview().offset(Consts.side)
            $0.trailingMargin.equalTo(closeButton.snp.leading)
            $0.top.equalTo(secondTextLabel.snp.bottom).offset(topOffset)
            $0.bottom.equalToSuperview().offset(-50)
        }
    }

    @objc
    private func closeButtonAction() {
        closeAction?.perform()
    }
}

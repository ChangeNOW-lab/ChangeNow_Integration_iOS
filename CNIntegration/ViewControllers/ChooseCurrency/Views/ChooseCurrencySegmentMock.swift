//
//  ChooseCurrencySegmentMock.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 26.07.2020.
//  Copyright © 2020 Pavel Pronin. All rights reserved.
//

import SnapKit

final class ChooseCurrencySegmentMock: UIView {

    // MARK: - Private

    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.textAlignment = .center
        return view
    }()

    private lazy var bottomSeparator: CALayer = {
        let separator = CALayer()
        separator.backgroundColor = UIColor.mainSelection.cgColor
        return separator
    }()

    // MARK: - Life Cycle

    init() {
        super.init(frame: .zero)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit() {
        preservesSuperviewLayoutMargins = true

        addSubviews()
        setConstraints()

        backgroundColor = .background
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let height = 1 / UIScreen.main.scale
        bottomSeparator.frame = CGRect(x: 0,
                                       y: bounds.height - height,
                                       width: bounds.width,
                                       height: height)
    }

    func set(fromCurrency: String, toCurrency: String) {
        let toCurrencyString = toCurrency.uppercased()
        let fromCurrencyString = fromCurrency.uppercased()
        let string = R.string.localizable.chooseCurrencyGetSpecific(toCurrencyString,
                                                                    fromCurrencyString)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        let attributedText = NSMutableAttributedString(
            string: string,
            attributes: [.foregroundColor: UIColor.white,
                         .font: UIFont.mediumText,
                         .paragraphStyle: paragraphStyle])
        if let range = string.range(of: toCurrencyString) {
            attributedText.addAttributes([.font: UIFont.mediumHeadline],
                                         range: NSRange(range, in: attributedText.string))
        }
        if let range = string.range(of: fromCurrencyString) {
            attributedText.addAttributes([.foregroundColor: UIColor.mainSelection,
                                          .font: UIFont.mediumHeadline],
                                         range: NSRange(range, in: attributedText.string))
        }
        titleLabel.attributedText = attributedText
    }

    // MARK: - Private

    private func addSubviews() {
        addSubview(titleLabel)
        layer.addSublayer(bottomSeparator)
    }

    private func setConstraints() {
        titleLabel.snp.makeConstraints {
            $0.leadingMargin.trailingMargin.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
    }
}


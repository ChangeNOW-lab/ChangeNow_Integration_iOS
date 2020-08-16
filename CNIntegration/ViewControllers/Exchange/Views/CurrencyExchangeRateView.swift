//
//  CurrencyExchangeRateView.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 17.04.2020.
//  Copyright © 2020 proninps. All rights reserved.
//

import SnapKit
import NVActivityIndicatorView

final class CurrencyExchangeRateView: TapActionView {

    private struct Consts {
        static let switchButtonInset: CGFloat = 9
        static let switchButtonOffset: CGFloat = 10
    }

    // MARK: - Views

    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 1
        view.textColor = .white
        view.font = .normalText
        return view
    }()

    private lazy var rateImage: UIImageView = {
        let view = UIImageView()
        view.image = R.image.growArrow()
        view.isHidden = true
        return view
    }()

    private lazy var rateButton: DefaultButton = {
        let view = DefaultButton()
        view.titleLabel?.font = .normalText
        view.titleLabel?.lineBreakMode = .byTruncatingTail
        view.setTitleColor(.primarySelection, for: .normal)
        view.setBackgroundImage(.darkBackgroundImage, for: .normal)
        view.contentEdgeInsets = .init(top: 0, left: 4, bottom: 0, right: 4)
        view.layer.cornerRadius = 2
        view.layer.masksToBounds = true
        view.isHidden = true
        view.addTarget(self, action: #selector(rateButtonAction), for: .touchUpInside)
        return view
    }()

    private lazy var fieldActivityIndicator: NVActivityIndicatorView = {
        let view = NVActivityIndicatorView(frame: .zero, type: .ballBeat, color: .primarySelection, padding: nil)
//        view.padding = 7
        view.backgroundColor = .darkBackground
        view.layer.cornerRadius = 4
        view.layer.masksToBounds = true
        return view
    }()

    private lazy var switchButton: DefaultButton = {
        let view = DefaultButton()
        view.setImage(R.image.switchArrows(), for: .normal)
        view.setBackgroundImage(.mainImage, for: .normal)
        view.contentEdgeInsets = .init(offset: Consts.switchButtonInset)
        view.layer.cornerRadius = 2
        view.layer.masksToBounds = true
        view.addTarget(self, action: #selector(switchButtonAction), for: .touchUpInside)
        return view
    }()
    private lazy var switchButtonWidth: CGFloat = (switchButton.image(for: .normal)?.size.width ?? 0) + 2 * Consts.switchButtonInset

    private(set) lazy var warningView: WarningView = {
        let view = WarningView()
        view.isHidden = true
        return view
    }()

    // MARK: - Private

    private var warningViewTrailingConstraint: Constraint?

    private var rateAction: Action?
    private var switchAction: Action?

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

        isHighlightEnabled = false
        onTapAction = Action { [unowned self] in
            self.rateAction?.perform()
        }
    }

    // MARK: - Public

    func set(isSwitchButtonHidden: Bool) {
        switchButton.isHidden = isSwitchButtonHidden
        if isSwitchButtonHidden {
            warningViewTrailingConstraint?.layoutConstraints.first?.constant = 0
        } else {
            warningViewTrailingConstraint?.layoutConstraints.first?.constant = -(switchButtonWidth + Consts.switchButtonOffset)
        }
    }

    func set(rateAction: Action?, switchAction: Action?) {
        self.rateAction = rateAction
        self.switchAction = switchAction
    }

    func set(currency: String) {
        titleLabel.text = "1 \(currency.uppercased()) ~".wrapDirection()
    }

    func set(rate: Decimal?, rateCurrency: String) {
        guard warningView.isHidden else { return }
        if let rate = rate {
            rateButton.isHidden = false
            let rateTitle = "\(rate.rounding(withMode: .down, scale: GlobalConsts.maxMantissa)) \(rateCurrency.uppercased())".wrapDirection()
            rateButton.setTitle(rateTitle, for: .normal)
            fieldActivityIndicator.stopAnimating()
        } else {
            rateButton.isHidden = true
            rateButton.setTitle("", for: .normal)
            fieldActivityIndicator.startAnimating()
        }
    }

    func setWarning(isHidden: Bool) {
        if isHidden {
            titleLabel.isHidden = false
            fieldActivityIndicator.isHidden = false
            warningView.isHidden = true
        } else {
            titleLabel.isHidden = true
            rateButton.isHidden = true
            fieldActivityIndicator.isHidden = true
            warningView.isHidden = false
        }
    }

    // MARK: - Private

    private func addSubviews() {
        addSubview(titleLabel)
        addSubview(rateButton)
        addSubview(fieldActivityIndicator)
        addSubview(rateImage)
        addSubview(switchButton)
        addSubview(warningView)
    }

    private func setConstraints() {
        titleLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(GlobalConsts.internalSideOffset)
        }

        rateButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.height.equalTo(18)
            $0.leading.equalTo(titleLabel.snp.trailing).offset(4)
        }
        fieldActivityIndicator.snp.makeConstraints {
            $0.leading.equalTo(rateButton.snp.leading)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(CGSize(width: 40, height: 20))
        }

        rateImage.snp.makeConstraints {
            $0.width.equalTo(rateImage.image?.size.width ?? 0)
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(rateButton.snp.trailing).offset(4)
            $0.trailing.lessThanOrEqualTo(switchButton.snp.leading).offset(-Consts.switchButtonOffset)
        }

        warningView.snp.makeConstraints {
            $0.leading.centerY.equalToSuperview()
            warningViewTrailingConstraint = $0.trailing.equalToSuperview().constraint
        }

        switchButton.snp.makeConstraints {
            $0.centerY.trailing.equalToSuperview()
            $0.width.equalTo(switchButtonWidth)
        }
    }

    // MARK: - Actions

    @objc
    private func rateButtonAction() {
        rateAction?.perform()
    }

    @objc
    private func switchButtonAction() {
        switchAction?.perform()
    }
}

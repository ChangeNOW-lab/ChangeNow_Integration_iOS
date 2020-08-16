//
//  CurrencyExchangeField.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 17.04.2020.
//  Copyright © 2020 proninps. All rights reserved.
//

import SnapKit
import Kingfisher
import NVActivityIndicatorView

final class CurrencyExchangeField: UIView {

    // MARK: - Views

    private lazy var fieldContainer: UIView = {
        let view = UIView()
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 1
        view.font = .minorTitle
        return view
    }()

    private lazy var field: UITextField = {
        let view = UITextField()
        view.font = .largeTitle
        view.tintColor = .primarySelection
        view.keyboardType = .decimalPad
        view.textAlignment = UIView.isLTR ? .left : .right
        view.addTarget(self, action: #selector(editingDidBeginAction), for: .editingDidBegin)
        view.addTarget(self, action: #selector(editingDidEndAction), for: .editingDidEnd)
        return view
    }()

    private lazy var fieldActivityIndicator: NVActivityIndicatorView = {
        let view = NVActivityIndicatorView(frame: .zero, type: .ballBeat, color: .white, padding: nil)
        return view
    }()

    private lazy var currencyContainer: DefaultButton = {
        let view = DefaultButton()
        view.addTarget(self, action: #selector(chooseCurrencyButtonAction), for: .touchUpInside)
        return view
    }()

    private lazy var currencyImageView: UIImageView = {
        let view = UIImageView()
        view.tintColor = .white
        return view
    }()

    private lazy var currencyLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 1
        view.textColor = .white
        view.font = .mediumTitle
        return view
    }()

    private lazy var currencyDescription: UILabel = {
        let view = UILabel()
        view.numberOfLines = 1
        view.textColor = .placeholder
        view.font = .minorText
        return view
    }()

    private lazy var currencyArrow: UIImageView = {
        let view = UIImageView()
        view.image = R.image.expandArrow()
        view.tintColor = .mainSelection
        return view
    }()

    // MARK: - Private

    private var isFieldSelected = false
    private var chooseCurrencyAction: Action?

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

        layer.cornerRadius = 4
        layer.masksToBounds = true
    }

    // MARK: - Public

    override var isFirstResponder: Bool {
        return field.isFirstResponder
    }

    override func becomeFirstResponder() -> Bool {
        field.becomeFirstResponder()
    }

    func isNotEmpty() -> Bool {
        return field.text?.isNotEmpty == true
    }

    func isSame(textField: UITextField) -> Bool {
        return field == textField
    }

    func set(fieldDelegate: UITextFieldDelegate,
             fieldIsEditable: Bool = true,
             chooseCurrencyAction: Action?) {
        field.delegate = fieldDelegate
        field.isUserInteractionEnabled = fieldIsEditable
        if fieldIsEditable {
            titleLabel.textColor = UIColor.transactionSubTitle.withAlphaComponent(0.4)
            fieldContainer.backgroundColor = .white
            field.textColor = .black
            updateFieldSelection()
        } else {
            titleLabel.textColor = .placeholder
            fieldContainer.backgroundColor = UIColor.main.withAlphaComponent(0.38)
            field.textColor = .white
            layer.borderColor = UIColor.main.cgColor
            layer.borderWidth = 1
        }

        self.chooseCurrencyAction = chooseCurrencyAction
        if chooseCurrencyAction == nil {
            currencyContainer.setBackgroundImage(UIImage.backgroundImage, for: .normal)
            currencyArrow.isHidden = true
        } else {
            currencyContainer.setBackgroundImage(UIImage.mainImage, for: .normal)
            currencyArrow.isHidden = false
        }
    }

    func set(title: String) {
        titleLabel.text = title
    }

    func set(value: Decimal?) {
        if let value = value {
            field.text = "\(value.rounding(withMode: .down, scale: GlobalConsts.maxMantissa))"
            fieldActivityIndicator.stopAnimating()
        } else {
            field.text = ""
            fieldActivityIndicator.startAnimating()
        }
    }

    func set(currency: String, currencyImageURL: URL?) {
        let components = Currency.currencyComponents(currency: currency)
        currencyLabel.text = components.ticker.uppercased()
        currencyDescription.text = components.description

        if let currencyImage = UIImage(named: currency, in: Bundle(for: Self.self), compatibleWith: nil) {
            currencyImageView.image = currencyImage
        } else if let currencyImageURL = currencyImageURL ?? ChangeNOW.url(currency: currency) {
            KingfisherManager.shared.retrieveImage(
                with: currencyImageURL,
                options: [.processor(SVGProcessor.sharedForCurrencies),
                          .originalCache(ImageCache.default)]) { [weak self] result in
                    switch result {
                    case let .success(value):
                        self?.currencyImageView.image = value.image.withRenderingMode(.alwaysTemplate)
                    case let .failure(error):
                        log.debug(error.localizedDescription)
                    }
            }
        } else {
            currencyImageView.image = R.image.currencyPlaceholder()
        }
    }

    func setFieldSelection(state: Bool) {
        isFieldSelected = state
        UIView.transition(
            with: self,
            duration: 0.3,
            options: .transitionCrossDissolve,
            animations: {
                self.updateFieldSelection()
            },
            completion: nil)
    }

    // MARK: - Private

    private func addSubviews() {
        addSubview(fieldContainer)
        fieldContainer.addSubview(titleLabel)
        fieldContainer.addSubview(field)
        fieldContainer.addSubview(fieldActivityIndicator)
        addSubview(currencyContainer)
        currencyContainer.addSubview(currencyImageView)
        currencyContainer.addSubview(currencyDescription)
        currencyContainer.addSubview(currencyLabel)
        currencyContainer.addSubview(currencyArrow)
    }

    private func setConstraints() {
        fieldContainer.snp.makeConstraints {
            $0.top.bottom.leading.equalToSuperview()
            $0.trailing.equalTo(currencyContainer.snp.leading)
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(6)
            $0.leading.equalToSuperview().offset(GlobalConsts.internalSideOffset)
            $0.trailing.equalToSuperview().offset(-GlobalConsts.internalSideOffset)
        }

        field.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(7)
            $0.leading.equalToSuperview().offset(GlobalConsts.internalSideOffset)
            $0.trailing.equalToSuperview().offset(-GlobalConsts.internalSideOffset)
        }
        fieldActivityIndicator.snp.makeConstraints {
            $0.leading.equalTo(titleLabel.snp.leading)
            $0.centerY.equalTo(field.snp.centerY)
            $0.size.equalTo(CGSize(width: 20, height: 20))
        }

        currencyContainer.snp.makeConstraints {
            $0.width.equalTo(120)
            $0.top.bottom.trailing.equalToSuperview()
        }

        currencyImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(8)
            $0.size.equalTo(CGSize(width: 20, height: 20))
        }

        currencyLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(currencyImageView.snp.trailing).offset(6)
            $0.trailing.lessThanOrEqualTo(currencyArrow.snp.leading).offset(-6)
        }
        currencyDescription.snp.makeConstraints {
            $0.leading.equalTo(currencyLabel.snp.leading)
            $0.bottom.equalTo(currencyLabel.snp.top).offset(-3)
            $0.trailing.equalToSuperview().offset(-GlobalConsts.internalSideOffset)
        }

        currencyArrow.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-GlobalConsts.internalSideOffset)
            $0.width.equalTo(currencyArrow.image?.size.width ?? 0)
        }
    }

    private func updateFieldSelection() {
        if isFieldSelected {
            layer.borderColor = UIColor.primaryOrange.withAlphaComponent(0.63).cgColor
            layer.borderWidth = 2
        } else {
            if isFirstResponder {
                layer.borderColor = UIColor.primarySelection.cgColor
                layer.borderWidth = 2
            } else {
                layer.borderColor = nil
                layer.borderWidth = 0
            }
        }
    }

    private func setSelection(state: Bool) {
        updateFieldSelection()
    }

    // MARK: - Actions

    @objc
    private func chooseCurrencyButtonAction() {
        chooseCurrencyAction?.perform()
    }

    @objc
    private func editingDidBeginAction() {
        UIView.transition(with: self,
                          duration: 0.3,
                          options: .transitionCrossDissolve,
                          animations: { self.setSelection(state: true) },
                          completion: nil)
    }

    @objc
    private func editingDidEndAction() {
        UIView.transition(with: self,
                          duration: 0.3,
                          options: .transitionCrossDissolve,
                          animations: { self.setSelection(state: false) },
                          completion: nil)
    }
}

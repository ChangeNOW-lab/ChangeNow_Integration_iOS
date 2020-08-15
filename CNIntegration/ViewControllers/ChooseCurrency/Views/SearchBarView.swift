//
//  SearchBarView.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 24.04.2020.
//  Copyright © 2020 proninps. All rights reserved.
//

import SnapKit

protocol SearchBarViewDelegate: class {

    func searchBarReturnButtonPressed()
    func searchBarDidChangeText(searchText: String)
}

extension SearchBarViewDelegate {

    func searchBarReturnButtonPressed() { }
}

final class SearchBarView: UIView, UITextFieldDelegate {

    // MARK: - Properties

    weak var delegate: SearchBarViewDelegate?

    var text: String {
        get {
            return textField.text ?? ""
        }
        set {
            textField.text = newValue
        }
    }

    // MARK: - Private

    private lazy var searchIcon: UIImageView = {
        let searchIcon = UIImageView()
        searchIcon.image = R.image.searchIcon()
        searchIcon.tintColor = UIColor.white.withAlphaComponent(0.7)
        return searchIcon
    }()

    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.font = .regularText
        textField.textColor = .white
        textField.tintColor = .mainSelection
        textField.backgroundColor = .clear
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = UIView.isLTR ? .left : .right
        textField.attributedPlaceholder = NSAttributedString(
            string: R.string.localizable.chooseCurrencySearchPlaceholder(),
            attributes: [.font: UIFont.regularText,
                         .foregroundColor: UIColor.white.withAlphaComponent(0.7),
                         .paragraphStyle: paragraphStyle]
        )
        textField.clearButtonMode = .never
        textField.returnKeyType = .done
        textField.autocorrectionType = .no
        textField.spellCheckingType = .no
        textField.textAlignment = UIView.isRTL ? .right : .left
        textField.delegate = self
        return textField
    }()

    private lazy var clearButton: ButtonExtendedTapArea = {
        let clearButton = ButtonExtendedTapArea()
        clearButton.setImage(R.image.searchClear(), for: .normal)
        clearButton.imageView?.tintColor = UIColor.white.withAlphaComponent(0.7)
        clearButton.addTargetClosure { [unowned self] _ in
            self.text = ""
            self.clearButton.isHidden = true
            self.delegate?.searchBarDidChangeText(searchText: "")
        }
        clearButton.isHidden = true
        return clearButton
    }()

    // MARK: - Life Cycle

    init() {
        super.init(frame: .zero)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        return UIView.layoutFittingExpandedSize
    }

    private func commonInit() {
        addSubviews()
        makeConstraints()

        backgroundColor = .darkBackground
        layer.masksToBounds = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        layer.cornerRadius = bounds.height / 2
    }

    override func becomeFirstResponder() -> Bool {
        return textField.becomeFirstResponder()
    }

    override var isFirstResponder: Bool {
        return textField.isFirstResponder
    }

    func reset() {
        textField.text = ""
        clearButton.isHidden = true
    }

    // MARK: - Private

    private func addSubviews() {
        addSubview(searchIcon)
        addSubview(textField)
        addSubview(clearButton)
    }

    private func makeConstraints() {
        searchIcon.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(10)
            make.width.equalTo(searchIcon.image?.size.width ?? 0)
        }
        textField.snp.makeConstraints { make in
            make.leading.equalTo(searchIcon.snp.trailing)
            make.trailing.equalTo(clearButton.snp.leading)
            make.centerY.equalToSuperview()
        }
        clearButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-15)
            make.width.equalTo(clearButton.image(for: .normal)?.size.width ?? 0)
        }
    }

    // MARK: - UITextFieldDelegate

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        if let text = textField.text,
            let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange, with: string)
            textField.text = updatedText
            delegate?.searchBarDidChangeText(searchText: updatedText)
            clearButton.isHidden = updatedText.isEmpty
        } else {
            clearButton.isHidden = true
        }
        return false
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        delegate?.searchBarReturnButtonPressed()
        textField.resignFirstResponder()
        return true
    }
}

//
//  DefaultTextField.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 19/08/2019.
//  Copyright © 2019 Pavel Pronin. All rights reserved.
//

class DefaultTextField: SkyFloatingLabelTextField {

    // MARK: - Public

    var titleToTextOffset: CGFloat = 2
    var textToLineOffset: CGFloat = 10

    var fieldContentDidChange: ActionWith<String?>?
    var fieldDidEndEditing: Action?

    // MARK: - Private

    private var isNeedUpdateControl: Bool = true
    private var mutableErrorMessage: String? {
        didSet {
            guard isNeedUpdateControl else { return }
            updateControl(true)
        }
    }

    // MARK: - Life Cycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        addTarget(self, action: #selector(contentDidChange), for: .editingChanged)
        addTarget(self, action: #selector(didEndEditing), for: .editingDidEnd)

        titleFormatter = { $0 }

        lineHeight = 1 / UIScreen.main.scale
        selectedLineHeight = 1 / UIScreen.main.scale
        textAlignment = UIView.isRTL ? .right : .left
    }

    // MARK: - Actions

    @objc
    func contentDidChange() {
        fieldContentDidChange?.perform(with: text)
    }

    @objc
    private func didEndEditing() {
        fieldDidEndEditing?.perform()
    }

    // MARK: - Overrided

    @IBInspectable override var errorMessage: String? {
        get {
            return mutableErrorMessage
        }
        set {
            mutableErrorMessage = newValue
        }
    }

    internal override func updateControl(_ animated: Bool = false) {
        isNeedUpdateControl = false
        if text?.isEmpty == true && displayAsValidIfEmpty {
            errorMessage = ""
        } else {
            if let validationRules = validationRules {
                if super.isEditing,
                    displayAsValidIfCanBecomeValid,
                    validationRules.possibleToBecomeValid(text) {
                    errorMessage = ""
                } else {
                    errorMessage = Validator.validate(input: text, rules: validationRules).firstErrorMessage
                }
            }
        }
        isNeedUpdateControl = true
        super.updateControl(animated)
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        let superRect = super.textRect(forBounds: bounds)

        let rect = CGRect(
            x: superRect.origin.x,
            y: superRect.origin.y + titleToTextOffset,
            width: superRect.size.width,
            height: superRect.size.height - titleToTextOffset - textToLineOffset
        )
        return rect
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let superRect = super.editingRect(forBounds: bounds)

        let rect = CGRect(
            x: superRect.origin.x,
            y: superRect.origin.y + titleToTextOffset,
            width: superRect.size.width,
            height: superRect.size.height - titleToTextOffset - textToLineOffset
        )
        return rect
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        let titleHeight = self.titleHeight()
        let rect = CGRect(
            x: 0,
            y: titleHeight + titleToTextOffset,
            width: bounds.size.width,
            height: textHeight()
        )
        return rect
    }

    override func titleLabelRectForBounds(_ bounds: CGRect, editing: Bool) -> CGRect {
        let titleHeight = self.titleHeight()
        if editing {
            return CGRect(x: 0, y: 0, width: bounds.size.width, height: titleHeight)
        }
        return CGRect(x: 0,
                      y: titleHeight + titleToTextOffset,
                      width: bounds.size.width,
                      height: titleHeight)
    }

    override func lineViewRectForBounds(_ bounds: CGRect, editing: Bool) -> CGRect {
        let height = editing ? selectedLineHeight : lineHeight
        return CGRect(x: 0,
                      y: bounds.size.height - height,
                      width: bounds.size.width,
                      height: height)
    }

    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.leftViewRect(forBounds: bounds)
        return rect
    }

    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.rightViewRect(forBounds: bounds)
        return rect
    }

    override func titleHeight() -> CGFloat {
        if let titleLabel = titleLabel,
            let font = titleLabel.font {
            return font.lineHeight.rounded(.up)
        }
        return 14.0
    }

    override func textHeight() -> CGFloat {
        guard let font = self.font else {
            return 0.0
        }
        return font.lineHeight.rounded(.up)
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: bounds.size.width,
                      height: titleHeight() + textHeight() + titleToTextOffset + textToLineOffset)
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: size.width,
                      height: titleHeight() + textHeight() + titleToTextOffset + textToLineOffset)
    }

    // MARK: - Validation

    // Should show invalid results as valid if current result can become valid
    var displayAsValidIfEmpty: Bool = true {
        didSet {
            updateControl()
        }
    }

    var displayAsValidIfCanBecomeValid: Bool = true {
        didSet {
            updateControl()
        }
    }

    // Validation rules that will produce error messages
    var validationRules: ValidationRuleSet<String>? {
        didSet {
            updateControl()
        }
    }

    var isValid: Bool {
        return validationRules?.validateInput(text) ?? true
    }
}

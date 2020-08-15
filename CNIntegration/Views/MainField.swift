//
//  MainField.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 17.04.2020.
//  Copyright © 2020 proninps. All rights reserved.
//

class MainField: DefaultTextField {

    private let validColor: UIColor = .certainMain
    private let selectedColor: UIColor = .certainMain

    private var currentValidState: Bool = false {
        didSet {
            if oldValue != currentValidState {
                updateValidColors(isValid: currentValidState)
                updateControl(true)
            }
        }
    }

    override var text: String? {
        didSet {
            sendActions(for: .editingChanged)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    override func contentDidChange() {
        super.contentDidChange()
        currentValidState = isValid && (text ?? "").isNotEmpty
    }

    private func commonInit() {
        clearButtonMode = .never
        returnKeyType = .done
        autocorrectionType = .no
        spellCheckingType = .no

        font = .normalText
        titleFont = .smallText
        placeholderFont = .normalText

        textColor = .white
        placeholderColor = .placeholder

        updateValidColors(isValid: false)
    }

    private func updateValidColors(isValid: Bool) {
        tintColor = isValid ? validColor : selectedColor
        selectedLineColor = isValid ? validColor : selectedColor
        selectedTitleColor = isValid ? validColor : selectedColor

        titleColor = isValid ? validColor : .placeholder
        lineColor = isValid ? validColor : .placeholder
    }
}


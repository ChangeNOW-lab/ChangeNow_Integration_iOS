//
//  MainButton.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 17.04.2020.
//  Copyright © 2020 proninps. All rights reserved.
//

class MainButton: DefaultButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        titleLabel?.font = .regularHeader
        setTitleColor(.white, for: .normal)
        setBackgroundImage(.certainGreenImage, for: .normal)
        layer.masksToBounds = true
    }

    func set(title: String) {
        setTitle(title, for: .normal)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if let cornerRadius = ThemeManager.current.mainButtonCornerRadius {
            layer.cornerRadius = cornerRadius
        } else {
            layer.cornerRadius = bounds.size.height / 2
        }
    }
}

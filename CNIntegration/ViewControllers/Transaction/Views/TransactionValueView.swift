//
//  TransactionValueView.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 24.04.2020.
//  Copyright © 2020 proninps. All rights reserved.
//

import SnapKit

final class TransactionValueView: UIView {

    enum Style {
        case normal
        case green

        var border: CGColor {
            switch self {
            case .normal:
                return UIColor.clear.cgColor
            case .green:
                return UIColor.primarySelection.cgColor
            }
        }
    }

    private struct Consts {
        static let sideTitle: CGFloat = 16
        static let sideValue: CGFloat = 8
    }

    // MARK: - Views

    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 1
        view.textColor = UIColor.background.withAlphaComponent(0.6)
        view.font = .normalTitle
        return view
    }()

    private lazy var valueLabel: EdgeInsetLabel = {
        let view = EdgeInsetLabel()
        view.font = .mediumTitle
        view.textColor = .background
        view.numberOfLines = 1
        view.textAlignment = .center
        view.textInsets = .init(top: 3, left: Consts.sideValue, bottom: 3, right: Consts.sideValue)
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 9
        return view
    }()

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

        backgroundColor = .white
        layer.masksToBounds = true
        layer.cornerRadius = 6
        layer.borderWidth = 1
        setSelection(style: .normal)
    }

    // MARK: - Public

    func set(title: String) {
        titleLabel.text = title
    }

    func set(value: String) {
        valueLabel.text = value
    }

    func setSelection(style: Style) {
        if style == .normal {
            layer.borderColor = UIColor.background.withAlphaComponent(0.1).cgColor
        } else {
            layer.borderColor = style.border
        }
    }

    // MARK: - Private

    private func addSubviews() {
        addSubview(titleLabel)
        addSubview(valueLabel)
    }

    private func setConstraints() {
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(11)
            $0.leading.equalToSuperview().offset(Consts.sideTitle)
            $0.trailing.equalToSuperview().offset(-Consts.sideTitle)
        }
        valueLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom)
            $0.leading.equalToSuperview().offset(Consts.sideValue)
            $0.trailing.lessThanOrEqualToSuperview().offset(-Consts.sideValue)
            $0.bottom.equalToSuperview().offset(-Consts.sideValue)
        }
    }
}

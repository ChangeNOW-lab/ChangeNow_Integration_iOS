//
//  InternetAlertView.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 17.04.2020.
//  Copyright © 2020 proninps. All rights reserved.
//

import SnapKit

final class InternetAlertView: UIView {

    enum Style {
        case exchange
        case transaction
    }

    private let style: Style

    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 0
        view.textColor = .white
        view.font = .normalDescription
        view.textAlignment = .center
        return view
    }()

    init(style: Style = .exchange) {
        self.style = style
        super.init(frame: .zero)
        commonInit()
    }

    required init?(coder: NSCoder) {
        self.style = .exchange
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        addSubviews()
        setConstraints()

        switch style {
        case .exchange:
            backgroundColor = UIColor.white.withAlphaComponent(0.16)
            titleLabel.text = R.string.localizable.internetErrorRefresh()
        case .transaction:
            backgroundColor = .mainLight
            titleLabel.text = R.string.localizable.internetErrorWaiting()
        }
        layer.cornerRadius = 9
        layer.masksToBounds = true
    }

    // MARK: - Private

    private func addSubviews() {
        addSubview(titleLabel)
    }

    private func setConstraints() {
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(GlobalConsts.internalSideOffset)
            $0.trailing.equalToSuperview().offset(-GlobalConsts.internalSideOffset)
            $0.top.equalToSuperview().offset(17)
            $0.bottom.equalToSuperview().offset(-17)
        }
    }
}

//
//  ChooseCurrencySegmentControl.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 19.04.2020.
//  Copyright © 2020 proninps. All rights reserved.
//

import SnapKit

final class ChooseCurrencySegmentControl: UIView {

    // MARK: - Private

    private lazy var fromButton: DefaultButton = {
        let view = DefaultButton()
        view.setTitleColor(.placeholder, for: .normal)
        view.setTitleColor(.white, for: .selected)
        view.titleLabel?.font = .mediumTitle
        view.addTarget(self, action: #selector(fromButtonAction), for: .touchUpInside)
        return view
    }()

    private lazy var toButton: DefaultButton = {
        let view = DefaultButton()
        view.setTitleColor(.placeholder, for: .normal)
        view.setTitleColor(.white, for: .selected)
        view.titleLabel?.font = .mediumTitle
        view.addTarget(self, action: #selector(toButtonAction), for: .touchUpInside)
        return view
    }()

    private lazy var arrowView: UIImageView = {
        let view = UIImageView()
        view.image = R.image.nextArrow()
        return view
    }()

    private lazy var underlineView: UIImageView = {
        let view = UIImageView()
        view.image = R.image.underline()
        return view
    }()

    private lazy var bottomSeparator: CALayer = {
        let separator = CALayer()
        separator.backgroundColor = UIColor.mainSelection.cgColor
        return separator
    }()

    private var underlineViewFromConstraint: Constraint?

    // MARK: - Public

    var selectedState: ChooseCurrencyState {
        didSet {
            updateSelection(animated: true)
        }
    }

    var selectedStateDidChanged: ActionWith<ChooseCurrencyState>?

    // MARK: - Life Cycle

    init(selectedState: ChooseCurrencyState) {
        self.selectedState = selectedState
        super.init(frame: .zero)
        commonInit()
    }

    required init?(coder: NSCoder) {
        self.selectedState = .from
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        translatesAutoresizingMaskIntoConstraints = false

        addSubviews()
        setConstraints()

        backgroundColor = .background
        updateButtonSelection()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let height = 1 / UIScreen.main.scale
        bottomSeparator.frame = CGRect(x: 0,
                                       y: bounds.height - height,
                                       width: bounds.width,
                                       height: height)
        updateUnderlineSelection()
    }

    // MARK: - Public

    func set(fromTitle: String, toTitle: String) {
        fromButton.setTitle(fromTitle, for: .normal)
        toButton.setTitle(toTitle, for: .normal)
    }

    // MARK: - Private

    private func updateSelection(animated: Bool = false) {
        if animated {
            UIView.animate(withDuration: 0.3,
                           animations: {
                            self.updateButtonSelection()
                            self.updateUnderlineSelection()
                            self.layoutIfNeeded()
            }, completion: nil)
        } else {
            updateButtonSelection()
            updateUnderlineSelection()
        }
    }

    private func updateButtonSelection() {
        switch selectedState {
        case .from:
            fromButton.isSelected = true
            toButton.isSelected = false
        case .to:
            fromButton.isSelected = false
            toButton.isSelected = true
        }
    }

    private func updateUnderlineSelection() {
        switch selectedState {
        case .from:
            underlineViewFromConstraint?.layoutConstraints.first?.constant = 0
        case .to:
            underlineViewFromConstraint?.layoutConstraints.first?.constant = toButton.center.x - fromButton.center.x
        }
    }

    private func addSubviews() {
        addSubview(fromButton)
        addSubview(toButton)
        addSubview(arrowView)

        layer.addSublayer(bottomSeparator)

        addSubview(underlineView)
    }

    private func setConstraints() {
        fromButton.snp.makeConstraints {
            $0.height.leading.centerY.equalToSuperview()
            $0.width.equalTo(toButton.snp.width)
        }
        toButton.snp.makeConstraints {
            $0.height.trailing.centerY.equalToSuperview()
        }
        arrowView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(fromButton.snp.trailing)
            $0.trailing.equalTo(toButton.snp.leading)
            $0.size.equalTo(arrowView.image?.size ?? .zero)
        }
        underlineView.snp.makeConstraints {
            underlineViewFromConstraint = $0.centerX.equalTo(fromButton.snp.centerX).constraint
            $0.size.equalTo(underlineView.image?.size ?? .zero)
            $0.bottom.equalToSuperview()
        }
    }

    // MARK: - Actions

    @objc
    private func fromButtonAction() {
        selectedState = .from
        selectedStateDidChanged?.perform(with: selectedState)
    }

    @objc
    private func toButtonAction() {
        selectedState = .to
        selectedStateDidChanged?.perform(with: selectedState)
    }
}

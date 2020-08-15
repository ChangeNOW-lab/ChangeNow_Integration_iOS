//
//  TransactionStepperView.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 26.06.2020.
//  Copyright © 2020 proninps. All rights reserved.
//

final class TransactionStepperView: UIView {

    enum Step {
        case first
        case second
        case third
    }

    // MARK: - Views

    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 1
        view.font = .mediumTitle
        view.textColor = .background
        view.textAlignment = .center
        return view
    }()

    private lazy var firstImageView: UIImageView = {
        let view = UIImageView()
        view.image = R.image.circleActive()
        view.tintColor = .certainMain
        return view
    }()
    private lazy var firstLabel: UILabel = numberLabel(text: "1")

    private lazy var secondImageView: UIImageView = {
        let view = UIImageView()
        view.tintColor = .certainMain
        return view
    }()
    private lazy var secondLabel: UILabel = numberLabel(text: "2")

    private lazy var thirdImageView: UIImageView = {
        let view = UIImageView()
        view.tintColor = .certainMain
        return view
    }()
    private lazy var thirdLabel: UILabel = numberLabel(text: "3")

    private lazy var firstSeparator: UIView = {
        let separator = UIView()
        return separator
    }()

    private lazy var secondSeparator: UIView = {
        let separator = UIView()
        return separator
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
    }

    // MARK: - Public

    func set(fromCurrency: String, toCurrency: String) {
        titleLabel.text = R.string.localizable.transactionTitle(fromCurrency.uppercased(), toCurrency.uppercased())
    }

    func set(step: Step) {
        switch step {
        case .first:
            firstSeparator.backgroundColor = UIColor.slightlyGray
            secondSeparator.backgroundColor = UIColor.slightlyGray
            secondImageView.image = R.image.circleInactive()
            thirdImageView.image = R.image.circleInactive()
        case .second:
            firstSeparator.backgroundColor = UIColor.certainMain
            secondSeparator.backgroundColor = UIColor.slightlyGray
            secondImageView.image = R.image.circleActive()
            thirdImageView.image = R.image.circleInactive()
        case .third:
            firstSeparator.backgroundColor = UIColor.certainMain
            secondSeparator.backgroundColor = UIColor.certainMain
            secondImageView.image = R.image.circleActive()
            thirdImageView.image = R.image.circleActive()
        }
    }

    // MARK: - Private

    private func numberLabel(text: String) -> UILabel {
        let view = UILabel()
        view.numberOfLines = 1
        view.font = .littleHeader
        view.textColor = .white
        view.textAlignment = .center
        view.text = text
        return view
    }

    private func addSubviews() {
        addSubview(firstSeparator)
        addSubview(secondSeparator)

        addSubview(titleLabel)
        addSubview(firstImageView)
        firstImageView.addSubview(firstLabel)
        addSubview(secondImageView)
        secondImageView.addSubview(secondLabel)
        addSubview(thirdImageView)
        thirdImageView.addSubview(thirdLabel)
    }

    private func setConstraints() {
        let offset: CGFloat = 26
        firstImageView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(offset)
        }
        firstLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        firstSeparator.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.centerY.equalTo(firstImageView.snp.centerY)
            $0.leading.equalTo(firstImageView.snp.trailing)
            $0.trailing.equalTo(secondImageView.snp.leading)
        }
        secondImageView.snp.makeConstraints {
            $0.centerY.equalTo(firstImageView.snp.centerY)
            $0.centerX.equalToSuperview()
        }
        secondLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        secondSeparator.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.centerY.equalTo(secondImageView.snp.centerY)
            $0.leading.equalTo(secondImageView.snp.trailing)
            $0.trailing.equalTo(thirdImageView.snp.leading)
        }
        thirdImageView.snp.makeConstraints {
            $0.centerY.equalTo(firstImageView.snp.centerY)
            $0.trailing.equalToSuperview().offset(-offset)
        }
        thirdLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(secondImageView.snp.bottom).offset(9)
            $0.leading.equalToSuperview().offset(offset)
            $0.trailing.equalToSuperview().offset(-offset)
            switch Device.model {
            case .iPhone5, .iPhone6:
                $0.bottom.equalToSuperview().offset(-3)
            default:
                $0.bottom.equalToSuperview().offset(-11)
            }
        }
    }
}

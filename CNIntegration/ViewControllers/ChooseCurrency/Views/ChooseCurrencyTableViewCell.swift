//
//  ChooseCurrencyTableViewCell.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 19.04.2020.
//  Copyright © 2020 proninps. All rights reserved.
//

import SnapKit
import Kingfisher

final class ChooseCurrencyTableViewCell: UITableViewCell, Reusable {

    // MARK: - Views

    private lazy var selectionView: UIView = {
        let view = UIView()
        view.alpha = 0.15
        view.layer.masksToBounds = true
        view.layer.cornerRadius = ThemeManager.current.cellSelectionCornerRadius
        return view
    }()

    private lazy var currencyImageView: UIImageView = {
        let view = UIImageView()
        view.tintColor = .white
        view.image = R.image.currencyPlaceholder()
        return view
    }()

    private lazy var tickerLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 1
        view.textColor = .white
        view.font = .regularTitle
        return view
    }()

    private lazy var nameLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 1
        view.textColor = .placeholder
        view.font = .smallTitle
        return view
    }()

    // MARK: - Life Cycle

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        addSubviews()
        setConstraints()

        backgroundColor = .background
        contentView.backgroundColor = .background
    }

    // MARK: - Public

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)

        contentView.alpha = highlighted ? 0.5 : 1
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        currencyImageView.image = R.image.currencyPlaceholder()
    }

    func set(ticker: String, name: String, currencyImageURL: URL?) {
        tickerLabel.text = ticker.uppercased()
        nameLabel.text = name
        if let currencyImage = UIImage(named: ticker, in: Bundle(for: Self.self), compatibleWith: nil) {
            currencyImageView.image = currencyImage
        } else if let currencyImageURL = currencyImageURL ?? ChangeNOW.url(currency: ticker) {
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
        }
        updateSelection()
    }

    // MARK: - Private

    private func updateSelection() {
        if isSelected {
            selectionView.backgroundColor = .mainSelection
        } else {
            selectionView.backgroundColor = .clear
        }
    }

    private func addSubviews() {
        contentView.addSubview(selectionView)
        contentView.addSubview(currencyImageView)
        contentView.addSubview(tickerLabel)
        contentView.addSubview(nameLabel)
    }

    private func setConstraints() {
        selectionView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leadingMargin.trailingMargin.equalToSuperview()
        }
        currencyImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leadingMargin.equalToSuperview().offset(11)
            $0.size.equalTo(CGSize(width: 18, height: 18))
        }
        tickerLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(currencyImageView.snp.trailing).offset(15)
        }
        nameLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(tickerLabel.snp.trailing).offset(20)
        }
    }
}

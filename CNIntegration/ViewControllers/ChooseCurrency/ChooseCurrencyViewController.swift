//
//  ChooseCurrencyViewController.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 18.04.2020.
//  Copyright © 2020 proninps. All rights reserved.
//

import SnapKit

protocol ChooseCurrencyDelegate: AnyObject {

    func currencyPairDidSelected(fromCurrencyTicker: String, toCurrencyTicker: String)
}

enum ChooseCurrencyState {
    case from
    case to
}

final class ChooseCurrencyViewController: UIViewController {

    @Injected private var currenciesService: CurrenciesService

    weak var delegate: ChooseCurrencyDelegate?

    private enum Consts {
        static let doneButtonBottomOffset: CGFloat = 10
    }

    // MARK: - Views

    private lazy var searchBar: SearchBarView = {
        let view = SearchBarView()
        view.layer.masksToBounds = true
        view.delegate = self
        return view
    }()

    private lazy var closeButton: DefaultButton = {
        let view = DefaultButton()
        view.setImage(R.image.close(), for: .normal)
        view.imageView?.tintColor = .white
        view.addTarget(self, action: #selector(closeButtonAction), for: .touchUpInside)
        return view
    }()

    private lazy var segmentControl: ChooseCurrencySegmentControl = {
        let view = ChooseCurrencySegmentControl(selectedState: selectedState)
        view.selectedStateDidChanged = ActionWith { [weak self] selectedState in
            self?.update(selectedState: selectedState)
        }
        return view
    }()

    private lazy var segmentMock: ChooseCurrencySegmentMock = {
        let view = ChooseCurrencySegmentMock()
        view.set(fromCurrency: fromCurrencyTicker, toCurrency: toCurrencyTicker)
        return view
    }()

    private lazy var tableView: UITableView = {
        let view = UITableView()
        view.backgroundColor = .background
        view.keyboardDismissMode = .onDrag
        view.separatorStyle = .none
        view.delegate = self
        view.dataSource = self
        view.registerReusableCell(ChooseCurrencyTableViewCell.self)
        view.registerReusableHeaderFooter(ChooseCurrencyTableViewHeader.self)
        return view
    }()

    private lazy var doneButton: MainButton = {
        let view = MainButton()
        view.set(title: R.string.localizable.done())
        view.addTarget(self, action: #selector(doneButtonAction), for: .touchUpInside)
        return view
    }()

    private lazy var emptyLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 0
        view.textColor = .white
        view.font = .regularText
        view.text = R.string.localizable.chooseCurrencyEmpty()
        view.textAlignment = .center
        view.isHidden = true
        return view
    }()

    // MARK: - Private

    private var fromCurrencyTicker: String
    private var toCurrencyTicker: String
    private var selectedState: ChooseCurrencyState
    private let exchangeType: ExchangeType

    private var isFiatExchange: Bool {
        return GlobalExchange.fiat.contains(fromCurrencyTicker)
    }

    private lazy var currencies: [Currency] = {
        return currenciesService.currencies.filter { !$0.isFiat }
    }()
    private lazy var fiatCurrencies = [Currency.defaultUSD, Currency.defaultEUR]
    private lazy var fromCurrencies: [Currency] = {
        switch exchangeType {
        case .any:
            return currencies.filter {
                currenciesService.pairs[$0.ticker]?.isNotEmpty == true
            } + fiatCurrencies
        case let .specific(currency, _):
            let specificCurrency = currency.lowercased()
            return currencies.filter {
                currenciesService.pairs[$0.ticker]?.contains(specificCurrency) == true
            } + fiatCurrencies
        }
    }()
    private lazy var popularFromCurrencies: [Currency] = fromCurrencies.filter {
        currenciesService.popularFrom.contains($0.ticker)
    }
    private var defiFromCurrencies: [Currency] = []
    private var otherFromCurrencies: [Currency] = []
    private var toCurrencies: [Currency] = []
    private var popularToCurrencies: [Currency] = []
    private var defiToCurrencies: [Currency] = []
    private var otherToCurrencies: [Currency] = []
    private var searchableCurrencies: [Currency] = []

    private var isSearchActive: Bool {
        return searchBar.text.isNotEmpty
    }

    private var doneButtonConstraint: Constraint?

    // MARK: - Life Cycle

    init(fromCurrencyTicker: String,
         toCurrencyTicker: String,
         selectedState: ChooseCurrencyState,
         exchangeType: ExchangeType) {
        self.fromCurrencyTicker = fromCurrencyTicker
        self.toCurrencyTicker = toCurrencyTicker
        self.selectedState = selectedState
        self.exchangeType = exchangeType
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .background

        addSubviews()
        setConstraints()

        registerForKeyboardNotifications(self)

        updateData()
    }

    deinit {
        unregisterFromKeyboardNotifications()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        searchBar.layer.cornerRadius = searchBar.bounds.height / 2
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // MARK: - Private

    private func update(selectedState: ChooseCurrencyState) {
        searchBar.reset()
        updateSearchData(searchText: "")
        self.selectedState = selectedState
        updateData()
    }

    private func updateData() {
        switch exchangeType {
        case .any:
            segmentControl.set(fromTitle: titleForSegment(state: .from),
                               toTitle: titleForSegment(state: .to))
        case .specific:
            segmentMock.set(fromCurrency: fromCurrencyTicker, toCurrency: toCurrencyTicker)
        }

        // From
        defiFromCurrencies = fromCurrencies.filter { GlobalExchange.defi.contains($0.ticker) }
        otherFromCurrencies = fromCurrencies.filter {
            !popularFromCurrencies.contains($0) && !fiatCurrencies.contains($0) && !defiFromCurrencies.contains($0)
        }

        // To
        if isFiatExchange {
            toCurrencies = currencies
        } else {
            let pairs = currenciesService.pairs[fromCurrencyTicker] ?? []
            toCurrencies = currencies.filter { pairs.contains($0.ticker) }
        }
        popularToCurrencies = toCurrencies.filter { currenciesService.popularTo.contains($0.ticker) }
        defiToCurrencies = toCurrencies.filter { GlobalExchange.defi.contains($0.ticker) }
        otherToCurrencies = toCurrencies.filter {
            !popularToCurrencies.contains($0) && !defiToCurrencies.contains($0)
        }

        tableView.reloadData()
    }

    private func updateSearchData(searchText: String) {
        if searchText.isEmpty {
            searchableCurrencies = []
            emptyLabel.isHidden = true
        } else {
            switch selectedState {
            case .from:
                searchableCurrencies = fromCurrencies.filter {
                    $0.ticker.contains(searchText) || $0.name.contains(searchText)
                }
            case .to:
                searchableCurrencies = toCurrencies.filter {
                    $0.ticker.contains(searchText) || $0.name.contains(searchText)
                }
            }
            emptyLabel.isHidden = searchableCurrencies.isNotEmpty
        }
    }

    private func addSubviews() {
        view.addSubview(searchBar)
        view.addSubview(closeButton)
        switch exchangeType {
        case .any:
            view.addSubview(segmentControl)
        case .specific:
            view.addSubview(segmentMock)
        }
        view.addSubview(tableView)
        view.addSubview(doneButton)
        view.addSubview(emptyLabel)
    }

    private func setConstraints() {
        searchBar.snp.makeConstraints {
            if #available(iOS 11.0, *) {
                $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            } else {
                $0.top.equalTo(topLayoutGuide.snp.bottom).offset(10)
            }
            $0.leadingMargin.equalToSuperview()
            $0.trailing.equalTo(closeButton.snp.leading).offset(-9)
            $0.height.equalTo(40)
        }
        closeButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-9)
            $0.centerY.equalTo(searchBar.snp.centerY)
            $0.size.equalTo(closeButton.imageView?.image?.size ?? .zero)
        }

        let segmentView: UIView
        switch exchangeType {
        case .any:
            segmentView = segmentControl
            segmentControl.snp.makeConstraints {
                $0.top.equalTo(searchBar.snp.bottom)
                $0.trailing.leading.equalToSuperview()
                $0.height.equalTo(55)
            }
        case .specific:
            segmentView = segmentMock
            segmentMock.snp.makeConstraints {
                $0.top.equalTo(searchBar.snp.bottom).offset(8)
                $0.trailing.leading.equalToSuperview()
                $0.height.equalTo(47)
            }
        }

        tableView.snp.makeConstraints {
            $0.top.equalTo(segmentView.snp.bottom).offset(5)
            $0.trailing.leading.equalToSuperview()
            $0.bottom.equalTo(doneButton.snp.top).offset(-10)
        }
        emptyLabel.snp.makeConstraints {
            $0.top.equalTo(tableView.snp.top)
            $0.bottom.equalTo(tableView.snp.bottom)
            $0.trailingMargin.leadingMargin.equalToSuperview()
        }
        doneButton.snp.makeConstraints {
            $0.leadingMargin.trailingMargin.equalToSuperview()
            if #available(iOS 11.0, *) {
                doneButtonConstraint = $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
                    .offset(-Consts.doneButtonBottomOffset)
                    .constraint
            } else {
                doneButtonConstraint = $0.bottom.equalTo(bottomLayoutGuide.snp.top)
                    .offset(-Consts.doneButtonBottomOffset)
                    .constraint
            }
            $0.height.equalTo(GlobalConsts.buttonHeight)
        }
    }

    // MARK: - Actions

    @objc
    private func closeButtonAction() {
        dismiss(animated: true, completion: nil)
    }

    @objc
    private func doneButtonAction() {
        delegate?.currencyPairDidSelected(fromCurrencyTicker: fromCurrencyTicker,
                                          toCurrencyTicker: toCurrencyTicker)
        dismiss(animated: true, completion: nil)
    }

    @objc
    private func hideKeyboard() {
        view.endEditing(true)
    }

    // MARK: - Helpers

    private func titleForSegment(state: ChooseCurrencyState) -> String {
        switch state {
        case .from:
            return R.string.localizable.chooseCurrencyFrom(fromCurrencyTicker.uppercased())
        case .to:
            return R.string.localizable.chooseCurrencyTo(toCurrencyTicker.uppercased())
        }
    }

    private func currenciesFor(section: Int) -> [Currency] {
        if isSearchActive {
            return searchableCurrencies
        } else {
            switch selectedState {
            case .from:
                switch section {
                case 0:
                    return popularFromCurrencies
                case 1:
                    return fiatCurrencies
                case 2:
                    return defiFromCurrencies
                case 3:
                    return otherFromCurrencies
                default:
                    return []
                }
            case .to:
                switch section {
                case 0:
                    return popularToCurrencies
                case 1:
                    return defiToCurrencies
                case 2:
                    return otherToCurrencies
                default:
                    return []
                }
            }
        }
    }
}

extension ChooseCurrencyViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        if isSearchActive {
            return 1
        } else {
            switch selectedState {
            case .from:
                return 4
            case .to:
                return 3
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currenciesFor(section: section).count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ChooseCurrencyTableViewCell.reuseIdentifier, for: indexPath) as? ChooseCurrencyTableViewCell
        cell?.selectionStyle = .none
        if let currency = currenciesFor(section: indexPath.section)[safe: indexPath.row] {
            switch selectedState {
            case .from:
                cell?.isSelected = currency.ticker == fromCurrencyTicker
            case .to:
                cell?.isSelected = currency.ticker == toCurrencyTicker
            }
            cell?.set(ticker: currency.ticker,
                      name: currency.name,
                      currencyImageURL: URL(string: currency.image))
        }
        return cell ?? UITableViewCell()
    }
}

extension ChooseCurrencyViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let ticker = currenciesFor(section: indexPath.section)[safe: indexPath.row]?.ticker else { return }
        switch selectedState {
        case .from:
            if toCurrencyTicker == ticker {
                toCurrencyTicker = fromCurrencyTicker
            }
            fromCurrencyTicker = ticker

            if isFiatExchange,
                let pairs = currenciesService.pairs[ticker],
                pairs.contains(toCurrencyTicker) == false {
                toCurrencyTicker = pairs.first ?? Currency.defaultBTC.ticker
            }
        case .to:
            if fromCurrencyTicker == ticker {
                fromCurrencyTicker = toCurrencyTicker
            }
            toCurrencyTicker = ticker
        }
        updateData()
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 42
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard !isSearchActive else {
            return nil
        }
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: ChooseCurrencyTableViewHeader.reuseIdentifier) as?  ChooseCurrencyTableViewHeader
        if currenciesFor(section: section).isNotEmpty {
            switch selectedState {
            case .from:
                switch section {
                case 0:
                    headerView?.set(style: .popular)
                case 1:
                    headerView?.set(style: .fiat)
                case 2:
                    headerView?.set(style: .defi)
                case 3:
                    headerView?.set(style: .other)
                default:
                    return nil
                }
            case .to:
                switch section {
                case 0:
                    headerView?.set(style: .popular)
                case 1:
                    headerView?.set(style: .defi)
                case 2:
                    headerView?.set(style: .other)
                default:
                    return nil
                }
            }
        } else {
            return nil
        }
        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if isSearchActive || currenciesFor(section: section).isEmpty {
            return .leastNormalMagnitude
        }
        return 40
    }
}

extension ChooseCurrencyViewController: KeyboardStateDelegate {

    func keyboardWillTransition(_ state: KeyboardState) { }

    func keyboardTransitionAnimation(_ state: KeyboardState) {
        guard UIApplication.shared.applicationState == .active else { return }
        updateKeyboardState(state)
    }

    func keyboardDidTransition(_ state: KeyboardState) { }

    private func updateKeyboardState(_ state: KeyboardState) {
        switch state {
        case let .activeWithHeight(height):
            let bottomInset: CGFloat
            if #available(iOS 11.0, *) {
                bottomInset = view.safeAreaInsets.bottom - Consts.doneButtonBottomOffset
            } else {
                bottomInset = -Consts.doneButtonBottomOffset
            }
            doneButtonConstraint?.layoutConstraints.first?.constant = -height + bottomInset
            view.layoutIfNeeded()
        case .hidden:
            doneButtonConstraint?.layoutConstraints.first?.constant = -Consts.doneButtonBottomOffset
            view.layoutIfNeeded()
        }
    }
}

extension ChooseCurrencyViewController: SearchBarViewDelegate {

    func searchBarReturnButtonPressed() {
        doneButtonAction()
    }

    func searchBarDidChangeText(searchText: String) {
        updateSearchData(searchText: searchText)
        tableView.reloadData()
    }
}

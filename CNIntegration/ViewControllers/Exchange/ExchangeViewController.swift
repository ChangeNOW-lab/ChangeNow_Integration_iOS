//
//  ExchangeViewController.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 17.04.2020.
//  Copyright © 2020 proninps. All rights reserved.
//

import SnapKit

final class ExchangeViewController: UIViewController {

    @Injected private var coordinatorService: CoordinatorService
    @Injected private var currenciesService: CurrenciesService
    @Injected private var validatorService: ValidatorService
    @Injected private var transactionService: TransactionService
    @Injected private var exchangeService: ExchangeService

    private enum Consts {
        static let exchangeFieldHeight: CGFloat = 60
        static let exchangeButtonBottomOffset: CGFloat = 8
        static let navigationButtonSize: CGSize = .init(width: GlobalConsts.buttonHeight,
                                                        height: GlobalConsts.buttonHeight)
        static let navigationButtonBeetwenOffset: CGFloat = 8
    }

    // MARK: - Views

    private lazy var logoView: UIImageView = {
        let view = UIImageView()
        view.image = R.image.miniLogo()
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.font = .bigHeadline
        view.textColor = .white
        view.textAlignment = .center
        view.text = "ChangeNOW"
        return view
    }()

    private lazy var backButton: DefaultButton = {
        let view = DefaultButton()
        view.setImage(R.image.backIcon(), for: .normal)
        view.imageView?.tintColor = .white
        view.transform.a = UIView.isLTR ? 1 : -1
        view.addTarget(self, action: #selector(backButtonAction), for: .touchUpInside)
        return view
    }()

    private lazy var refreshControl: UIRefreshControl = {
        let view = UIRefreshControl()
        view.tintColor = .primarySelection
        view.addTarget(self, action: #selector(refreshControlAction), for: .valueChanged)
        return view
    }()

    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.backgroundColor = .background
        view.keyboardDismissMode = .onDrag
        view.isScrollEnabled = true
        view.alwaysBounceVertical = true
        view.alwaysBounceHorizontal = false
        view.showsVerticalScrollIndicator = false
        view.refreshControl = refreshControl
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
        return view
    }()

    private lazy var scrollContentView: UIView = {
        let view = UIView()
        view.backgroundColor = .background
        view.isUserInteractionEnabled = true
        return view
    }()

    private lazy var internetAlertView: InternetAlertView = {
        let view = InternetAlertView()
        view.isHidden = true
        return view
    }()

    private lazy var exchangeButton: MainButton = {
        let view = MainButton()
        view.set(title: R.string.localizable.exchangeExchange())
        view.addTarget(self, action: #selector(exchangeButtonAction), for: .touchUpInside)
        return view
    }()

    private lazy var nextButton: DefaultButton = {
        let view = navigationButton
        let image = R.image.expandArrow()
        view.setImage(image, for: .normal)
        view.addTarget(self, action: #selector(nextButtonAction), for: .touchUpInside)
        return view
    }()

    private lazy var previousButton: DefaultButton = {
        let view = navigationButton
        let image = R.image.hideArrow()
        view.setImage(image, for: .normal)
        view.addTarget(self, action: #selector(previousButtonAction), for: .touchUpInside)
        return view
    }()

    private var navigationButton: DefaultButton {
        let view = DefaultButton()
        view.extendedSize = .zero
        view.imageView?.tintColor = .white
        view.setBackgroundImage(.darkBackgroundImage, for: .normal)
        view.contentEdgeInsets = .init(top: 19, left: 19, bottom: 19, right: 19)
        view.layer.cornerRadius = 4
        view.layer.masksToBounds = true
        view.isHidden = true
        return view
    }

    private lazy var fromExchangeField: CurrencyExchangeField = {
        let view = CurrencyExchangeField()
        view.set(title: R.string.localizable.exchangeSend())
        view.set(fieldDelegate: self, chooseCurrencyAction: Action { [weak self] in
            guard let self = self else { return }
            self.coordinatorService.showChooseCurrencyScreen(
                fromCurrencyTicker: self.presenter.fromCurrency.ticker,
                toCurrencyTicker: self.presenter.toCurrency.ticker,
                selectedState: .from,
                exchangeType: self.exchangeType,
                delegate: self.presenter
            )
        })
        return view
    }()

    private lazy var toExchangeField: CurrencyExchangeField = {
        let view = CurrencyExchangeField()
        view.set(title: R.string.localizable.exchangeGet())
        let chooseCurrencyAction: Action?
        switch exchangeType {
        case .any:
            chooseCurrencyAction = Action { [weak self] in
                guard let self = self,
                    self.currenciesService.currencies.isNotEmpty,
                    self.currenciesService.pairs.isNotEmpty else {
                        return
                }
                self.coordinatorService.showChooseCurrencyScreen(
                    fromCurrencyTicker: self.presenter.fromCurrency.ticker,
                    toCurrencyTicker: self.presenter.toCurrency.ticker,
                    selectedState: .to,
                    exchangeType: self.exchangeType,
                    delegate: self.presenter
                )
            }
        case .specific:
            chooseCurrencyAction = nil
        }
        view.set(fieldDelegate: self, fieldIsEditable: false, chooseCurrencyAction: chooseCurrencyAction)
        return view
    }()

    private lazy var exchangeRateView: CurrencyExchangeRateView = {
        let view = CurrencyExchangeRateView()
        switch exchangeType {
        case .any:
            view.set(isSwitchButtonHidden: false)
        case .specific:
            view.set(isSwitchButtonHidden: true)
        }
        view.set(
            rateAction: Action { [weak self] in
                let newVC = ExpectedRateViewController()
                if #available(iOS 13.0, *) {
                    newVC.modalPresentationStyle = .automatic
                } else {
                    newVC.modalPresentationStyle = .overCurrentContext
                }
                self?.present(newVC, animated: true, completion: nil)
            }, switchAction: Action { [weak self] in
                guard let self = self else { return }
                let fromCurrencyTicker = self.presenter.fromCurrency.ticker
                let toCurrencyTicker = self.presenter.toCurrency.ticker
                let isSwitchEnabled = self.currenciesService.pairs[toCurrencyTicker]?.contains(fromCurrencyTicker) == true
                if isSwitchEnabled {
                    self.presenter.switchCurrencies()
                } else {
                    self.showMessage(R.string.localizable.exchangeUnavailableSwitchText(toCurrencyTicker.uppercased(),
                                                                                        fromCurrencyTicker.uppercased()),
                                     title: R.string.localizable.exchangePairNotAvailable()
                    )
                }
            }
        )
        return view
    }()

    private lazy var subTitleLabel: UILabel = {
        let view = UILabel()
        view.numberOfLines = 1
        view.textColor = .white
        view.font = .regularTitle
        switch exchangeType {
        case .any:
            view.text = R.string.localizable.exchangeRecipientAddress()
        case let .specific(currency, _):
            view.text = R.string.localizable.exchangeToSpecific(currency.uppercased())
        }
        return view
    }()

    private lazy var addressField: MainField = {
        let view = MainField()
        view.delegate = self
        switch exchangeType {
        case .any:
            break
        case let .specific(_, address):
            view.text = address
        }
        return view
    }()

    private lazy var extraIdField: MainField = {
        let view = MainField()
        view.delegate = self
        view.isHidden = true
        return view
    }()

    private lazy var qrCodeButton: DefaultButton = {
        let view = DefaultButton()
        view.setImage(R.image.qrLogo(), for: .normal)
        view.setBackgroundImage(.certainLightWhiteImage, for: .normal)
        view.contentEdgeInsets = .init(top: 2, left: 2, bottom: 2, right: 2)
        view.layer.cornerRadius = 2
        view.layer.masksToBounds = true
        view.addTarget(self, action: #selector(qrCodeButtonAction), for: .touchUpInside)
        return view
    }()

    // MARK: - Private

    private let exchangeType: ExchangeType
    private let isInNavigationStack: Bool

    private var exchangeButtonConstraint: Constraint?
    private var exchangeButtonTrailingConstraint: Constraint?

    private var isStarted = false

    private lazy var fields: [UIView] = [fromExchangeField, addressField, extraIdField]

    private lazy var presenter = ExchangePresenter(viewController: self,
                                                   exchangeService: exchangeService,
                                                   currenciesService: currenciesService,
                                                   exchangeType: exchangeType)

    // MARK: - Public

    var isMinimumExchangeWarningHidden: Bool {
        return exchangeRateView.warningView.isHidden
    }

    // MARK: - Life Cycle

    init(exchangeType: ExchangeType,
         isInNavigationStack: Bool) {
        self.exchangeType = exchangeType
        self.isInNavigationStack = isInNavigationStack
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        coordinatorService.prepareStart(viewController: self)
        view.backgroundColor = .background
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))

        addSubviews()
        setConstraints()

        registerForKeyboardNotifications(self)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didBecomeActiveNotification),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)

        presenter.viewDidLoad()

        _ = fromExchangeField.becomeFirstResponder()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isStarted = true
    }

    deinit {
        unregisterFromKeyboardNotifications()
        NotificationCenter.default.removeObserver(self,
                                                  name: UIApplication.didBecomeActiveNotification,
                                                  object: nil)
        coordinatorService.prepareStop(viewController: self)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        scrollView.contentSize = scrollContentView.bounds.size
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // MARK: - Public

    func startRefreshIndicator() {
        refreshControl.beginRefreshing()
    }

    func stopRefreshIndicator() {
        refreshControl.endRefreshing()
    }

    func set(exchangeData: ExchangeData) {
        let fromCurrencyTicker = exchangeData.fromCurrency.ticker
        let toCurrencyTicker = exchangeData.toCurrency.ticker
        fromExchangeField.set(value: exchangeData.fromAmount)
        fromExchangeField.set(currency: fromCurrencyTicker,
                              currencyImageURL: URL(string: exchangeData.fromCurrency.image))
        toExchangeField.set(currency: toCurrencyTicker,
                            currencyImageURL: URL(string: exchangeData.toCurrency.image))
        exchangeRateView.set(currency: fromCurrencyTicker)

        set(toAmount: exchangeData.toAmount, rate: nil)

        addressField.validationRules = .init(rules: [CurrencyValidationRule(
            ticker: toCurrencyTicker,
            extraId: nil,
            validatorService: validatorService)
        ])
    }

    func set(toAmount: Decimal?, rate: Decimal?) {
        let toCurrencyTicker = presenter.toCurrency.ticker
        toExchangeField.set(value: toAmount)
        exchangeRateView.set(rate: rate, rateCurrency: toCurrencyTicker)
    }

    func set(address: String) {
        addressField.text = address
    }

    func set(addressTitle: String, extraIdTitle: String?) {
        addressField.title = addressTitle
        addressField.placeholder = addressTitle
        if let extraIdTitle = extraIdTitle {
            extraIdField.isHidden = false
            extraIdField.title = R.string.localizable.exchangeExtraId(extraIdTitle)
            extraIdField.placeholder = R.string.localizable.exchangeExtraId(extraIdTitle)
            extraIdField.validationRules = .init(rules: [
                CurrencyValidationRule(ticker: presenter.toCurrency.ticker,
                                       extraId: extraIdTitle,
                                       validatorService: validatorService)
            ])
        } else {
            extraIdField.isHidden = true
            extraIdField.text = ""
            extraIdField.validationRules = ValidationRuleSet()
        }
    }

    func networkReachabilityDidChanged(isReachable: Bool) {
        if internetAlertView.isHidden != isReachable {
            internetAlertView.isHidden = isReachable
        }
    }

    func setMinimumExchangeWarning(isHidden: Bool) {
        if !isHidden, let rate = presenter.minimumExchangeAmount {
            let fromCurrencyTicker = presenter.fromCurrency.ticker
            exchangeRateView.warningView.set(rate: rate, rateCurrency: fromCurrencyTicker)
        }
        exchangeRateView.setWarning(isHidden: isHidden)
        fromExchangeField.setFieldSelection(state: !isHidden)
    }

    // MARK: - Private

    private func addSubviews() {
        if isInNavigationStack {
            view.addSubview(titleLabel)
            view.addSubview(backButton)
        } else if !ChangeNOW.isOriginalApp {
            view.addSubview(titleLabel)
        } else {
            view.addSubview(logoView)
        }
        view.addSubview(scrollView)
        view.addSubview(exchangeButton)
        view.addSubview(nextButton)
        view.addSubview(previousButton)
        view.addSubview(internetAlertView)

        scrollContentView.addSubview(refreshControl)
        scrollContentView.addSubview(fromExchangeField)
        scrollContentView.addSubview(exchangeRateView)
        scrollContentView.addSubview(toExchangeField)
        scrollContentView.addSubview(subTitleLabel)
        scrollContentView.addSubview(addressField)
        scrollContentView.addSubview(qrCodeButton)
        scrollContentView.addSubview(extraIdField)
        scrollView.addSubview(scrollContentView)
    }

    private func setConstraints() {
        if isInNavigationStack {
            titleLabel.snp.makeConstraints {
                $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(8)
                $0.centerX.equalToSuperview()
            }
            backButton.snp.makeConstraints {
                $0.centerY.equalTo(titleLabel.snp.centerY)
                $0.leadingMargin.equalToSuperview()
            }
        } else if !ChangeNOW.isOriginalApp {
            titleLabel.snp.makeConstraints {
                $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(8)
                $0.centerX.equalToSuperview()
            }
        } else {
            logoView.snp.makeConstraints {
                $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
                $0.leadingMargin.equalToSuperview().offset(5)
            }
        }
        scrollView.snp.makeConstraints {
            if isInNavigationStack || !ChangeNOW.isOriginalApp {
                $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            } else {
                $0.top.equalTo(logoView.snp.bottom).offset(8)
            }
            $0.leadingMargin.trailingMargin.equalToSuperview()
            $0.bottom.equalTo(exchangeButton.snp.top).offset(-16)
        }
        exchangeButton.snp.makeConstraints {
            $0.leadingMargin.equalToSuperview()
            exchangeButtonTrailingConstraint = $0.trailingMargin.equalToSuperview().constraint
            exchangeButtonConstraint = $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
                .offset(-Consts.exchangeButtonBottomOffset)
                .constraint
            $0.height.equalTo(GlobalConsts.buttonHeight)
        }
        previousButton.snp.makeConstraints {
            $0.leading.equalTo(exchangeButton.snp.trailing).offset(GlobalConsts.internalSideOffset)
            $0.centerY.equalTo(exchangeButton.snp.centerY)
            $0.size.equalTo(Consts.navigationButtonSize)
        }
        nextButton.snp.makeConstraints {
            $0.leading.equalTo(previousButton.snp.trailing).offset(Consts.navigationButtonBeetwenOffset)
            $0.centerY.equalTo(exchangeButton.snp.centerY)
            $0.size.equalTo(Consts.navigationButtonSize)
        }

        internetAlertView.snp.makeConstraints {
            $0.leadingMargin.trailingMargin.equalToSuperview()
            $0.bottom.equalTo(exchangeButton.snp.top).offset(-16)
        }

        scrollContentView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.width.centerX.equalToSuperview()
        }
        fromExchangeField.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(Consts.exchangeFieldHeight)
        }
        exchangeRateView.snp.makeConstraints {
            $0.top.equalTo(fromExchangeField.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(52)
        }
        toExchangeField.snp.makeConstraints {
            $0.top.equalTo(exchangeRateView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(Consts.exchangeFieldHeight)
        }
        subTitleLabel.snp.makeConstraints {
            $0.top.equalTo(toExchangeField.snp.bottom).offset(44)
            $0.leading.trailing.equalToSuperview()
        }
        qrCodeButton.snp.makeConstraints {
            $0.top.equalTo(subTitleLabel.snp.bottom).offset(18)
            $0.trailing.equalToSuperview()
            $0.height.width.equalTo(42)
        }
        addressField.snp.makeConstraints {
            $0.centerY.equalTo(qrCodeButton.snp.centerY)
            $0.leading.equalToSuperview()
            $0.trailing.equalTo(qrCodeButton.snp.leading).offset(-8)
        }
        extraIdField.snp.makeConstraints {
            $0.top.equalTo(addressField.snp.bottom).offset(20)
            $0.leading.equalToSuperview()
            $0.trailing.equalTo(qrCodeButton.snp.leading).offset(-8)
            $0.bottom.equalToSuperview()
        }
    }

    // MARK: - Actions

    @objc
    func backButtonAction() {
        coordinatorService.dismiss()
    }

    @objc
    func didBecomeActiveNotification() {
        resumeRefreshing()
    }

    @objc
    private func resumeRefreshing() {
        guard isStarted else { return }
        if !refreshControl.isHidden, refreshControl.isRefreshing {
            refreshControl.beginRefreshing()
        }
        presenter.refresh()
    }

    @objc
    private func refreshControlAction() {
        presenter.refresh()
    }

    @objc
    private func exchangeButtonAction() {
        hideKeyboard()

        let isAmountReady = fromExchangeField.isNotEmpty() && presenter.fromAmount > 0
        let isAddressReady = addressField.text?.isNotEmpty == true && addressField.isValid
        let isExtraIdReady = extraIdField.isValid || (extraIdField.text?.isEmpty == true)
        switch (isAmountReady, isAddressReady) {
        case (true, true):
            guard presenter.isReadyToExchange, isExtraIdReady else {
                showMessage(R.string.localizable.exchangeNoDataText(), title: R.string.localizable.exchangeNoDataTitle())
                return
            }
        case (false, true):
            showMessage(R.string.localizable.exchangeNoAmountText())
            return
        case (true, false):
            showMessage(R.string.localizable.exchangeNoAddressText(), title: R.string.localizable.exchangeNoAddressTitle())
            return
        default:
            showMessage(R.string.localizable.exchangeNoDataText(), title: R.string.localizable.exchangeNoDataTitle())
            return
        }

        showActivityIndicator()
        transactionService.createTransaction(
            from: presenter.fromCurrency.ticker,
            to: presenter.toCurrency.ticker,
            address: addressField.text!,
            amount: presenter.fromAmount,
            extraId: extraIdField.text ?? "") { [weak self] result in
                switch result {
                case let .success(transaction):
                    self?.transactionService.getTransactionStatus(id: transaction.id) { [weak self] result in
                        switch result {
                        case let .success(transactionStatusData):
                            self?.coordinatorService.showTransactionScreen(transaction: transactionStatusData)
                        case let .failure(error):
                            self?.showError(error.localizedDescription)
                        }
                        self?.hideActivityIndicator()
                    }
                case let .failure(error):
                    if let changeNowError = error as? ChangeNowError,
                        changeNowError.type == .notValidAddress {
                        self?.showMessage(changeNowError.message,
                                          title: R.string.localizable.exchangeIncorrectRecipientAddress())
                    } else {
                        self?.showError(error.localizedDescription)
                    }
                    self?.hideActivityIndicator()
                }
        }
    }

    @objc
    private func previousButtonAction() {
        guard let index = fields.firstIndex(where: { $0.isFirstResponder }) else { return }
        UIView.performWithoutAnimation {
            fields[safe: index - 1]?.becomeFirstResponder()
        }
    }

    @objc
    private func nextButtonAction() {
        guard let index = fields.firstIndex(where: { $0.isFirstResponder }) else { return }
        UIView.performWithoutAnimation {
            fields[safe: index + 1]?.becomeFirstResponder()
        }
    }

    @objc
    private func qrCodeButtonAction() {
        coordinatorService.showScannerScreen(delegate: presenter)
    }

    @objc
    private func hideKeyboard() {
        view.endEditing(true)
    }

    // MARK: - Helpers

    private let fromAmountScheduler = ActionScheduler(dispatch: .main)
    private func set(fromAmountString: String) {
        guard let fromAmount = Decimal(string: fromAmountString), presenter.fromAmount != fromAmount else { return }
        presenter.stopUpdateEstimatedExchangeAmount()
        fromAmountScheduler.execute(after: 0.3) { [weak self] in
            self?.presenter.set(fromAmountString: fromAmountString)
        }
    }

    private func updateNavigationButtons(isVisible: Bool) {
        nextButton.isHidden = !isVisible
        previousButton.isHidden = !isVisible
        if isVisible {
            exchangeButtonTrailingConstraint?.layoutConstraints.first?.constant = -(
                2 * Consts.navigationButtonSize.width +
                    Consts.navigationButtonBeetwenOffset +
                    GlobalConsts.internalSideOffset
            )
        } else {
            exchangeButtonTrailingConstraint?.layoutConstraints.first?.constant = 0
        }
    }

    private enum NavigationButtonsState {
        case first
        case middle
        case last
    }
    private func updateNavigationButtons(state: NavigationButtonsState) {
        switch state {
        case .first:
            nextButton.isEnabled = true
            previousButton.isEnabled = false
        case .middle:
            nextButton.isEnabled = true
            previousButton.isEnabled = true
        case .last:
            nextButton.isEnabled = false
            previousButton.isEnabled = true
        }
    }
}

extension ExchangeViewController: KeyboardStateDelegate {

    func keyboardWillTransition(_ state: KeyboardState) { }

    func keyboardTransitionAnimation(_ state: KeyboardState) {
        updateKeyboardState(state)
    }

    func keyboardDidTransition(_ state: KeyboardState) { }

    private func updateKeyboardState(_ state: KeyboardState) {
        switch state {
        case let .activeWithHeight(height):
            let bottomInset: CGFloat
            if #available(iOS 11.0, *) {
                bottomInset = view.safeAreaInsets.bottom - Consts.exchangeButtonBottomOffset
            } else {
                bottomInset = -Consts.exchangeButtonBottomOffset
            }
            exchangeButtonConstraint?.layoutConstraints.first?.constant = -height + bottomInset
            updateNavigationButtons(isVisible: true)
            view.layoutIfNeeded()
        case .hidden:
            exchangeButtonConstraint?.layoutConstraints.first?.constant = -Consts.exchangeButtonBottomOffset
            updateNavigationButtons(isVisible: false)
            view.layoutIfNeeded()
        }
    }
}

extension ExchangeViewController: UITextFieldDelegate {

    func textFieldDidBeginEditing(_ textField: UITextField) {
        if fromExchangeField.isSame(textField: textField) {
            updateNavigationButtons(state: .first)
        } else if toExchangeField.isSame(textField: textField) {
            updateNavigationButtons(state: .middle)
        } else if addressField == textField {
            updateNavigationButtons(state: extraIdField.isHidden ? .last : .middle)
        } else if extraIdField == textField, !extraIdField.isHidden {
            updateNavigationButtons(state: .last)
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {

    }

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        func onlyFloatDigits() {
            let positionOriginal = textField.beginningOfDocument
            let cursorLocation = textField.position(from: positionOriginal,
                                                    offset: (range.location + NSString(string: string).length))

            let filteredString = String(string
                .replacingOccurrences(of: ",", with: ".")
                .unicodeScalars
                .filter { CharacterSet.floatDigits.contains($0) }
            )
            if let text = textField.text,
                let textRange = Range(range, in: text) {
                var updatedText = text.replacingCharacters(in: textRange, with: filteredString)
                var components = updatedText.components(separatedBy: ".")
                if components.count == 2, components[1].count > GlobalConsts.maxMantissa {
                    components[1] = String(components[1].prefix(GlobalConsts.maxMantissa))
                    updatedText = components.joined(separator: ".")
                }
                textField.text = updatedText.floatDigit
            }
            if let cursorLoc = cursorLocation {
                textField.selectedTextRange = textField.textRange(from: cursorLoc, to: cursorLoc)
            }
        }

        if fromExchangeField.isSame(textField: textField) {
            onlyFloatDigits()
            set(fromAmountString: textField.text ?? "")
            return false
        } else if toExchangeField.isSame(textField: textField) {
            onlyFloatDigits()
            return false
        } else if addressField == textField {
            return true
        } else if extraIdField == textField {
            return true
        }
        return false
    }
}

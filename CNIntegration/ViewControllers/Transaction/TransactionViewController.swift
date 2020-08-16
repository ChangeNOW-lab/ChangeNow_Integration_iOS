//
//  TransactionViewController.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 24.04.2020.
//  Copyright © 2020 proninps. All rights reserved.
//

import SnapKit
import Moya

struct TransactionViewModel {

    let transactionId: String
    let fromCurrencyTicker: String
    let toCurrencyTicker: String
    let fromAmount: Decimal
    let toAmount: Decimal
    let address: String
}

final class TransactionViewController: UIViewController {

    @Injected private var coordinatorService: CoordinatorService
    @Injected private var currenciesService: CurrenciesService
    @Injected private var transactionService: TransactionService
    @Injected private var reachabilityService: ReachabilityService

    private struct Consts {
        static let refreshInterval: TimeInterval = 15

        static let spacing: CGFloat = 8
        static let corner: CGFloat = 13
        static let scrollViewTopOffset: CGFloat = {
            switch Device.model {
            case .iPhone5:
                return 10
            case .iPhone6:
                return 15
            default:
                return 20
            }
        }()
        static let titleTopOffset: CGFloat = {
            switch Device.model {
            case .iPhone5, .iPhone6:
                return 10
            default:
                return 20
            }
        }()
        static let bottomOffset: CGFloat = 10
    }

    // MARK: - Views

    private lazy var headerView: TransactionHeaderView = {
        let view = TransactionHeaderView(isInNavigationStack: isInNavigationStack)
        view.cancelAction = Action { [weak self] in
            self?.cancelButtonAction()
        }
        view.backAction = Action { [weak self] in
            self?.backButtonAction()
        }
        view.idAction = Action { [weak self] in
            UIPasteboard.general.string = self?.transaction.id
            self?.impactFeedback()
            self?.showCopiedLabel()
        }
        view.set(id: transaction.id)
        return view
    }()

    private lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightBackground
        view.layer.masksToBounds = true
        view.layer.cornerRadius = Consts.corner
        return view
    }()

    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.alwaysBounceHorizontal = false
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        view.backgroundColor = .clear
        return view
    }()

    private lazy var stackView: UIStackView = {
        let view = UIStackView()
        view.alignment = .fill
        view.distribution = .fill
        view.spacing = Consts.spacing
        view.axis = .vertical
        return view
    }()

    private lazy var nextButton: DefaultButton = {
        let view = DefaultButton()
        view.titleLabel?.font = .normalTitle
        view.setTitle("Next", for: .normal)
        view.setTitleColor(.placeholder, for: .normal)
        view.addTarget(self, action: #selector(nextButtonAction), for: .touchUpInside)
        return view
    }()

    private lazy var addressView: TransactionAddressView = {
        let view = TransactionAddressView()
        view.set(address: transaction.payoutAddress,
                 currency: transaction.toCurrency,
                 extraIdName: transaction.payoutExtraIdName ?? currenciesService.anonyms[transaction.toCurrency],
                 extraId: transaction.payoutExtraId)
        return view
    }()
    private lazy var depositView: TransactionDepositView = {
        let view = TransactionDepositView()
        view.copyAddressAction = Action { [weak self] in
            self?.copy(string: self?.transaction.payinAddress, viewController: self)
        }
        view.copyExtraIdAction = Action { [weak self] in
            self?.copy(string: self?.transaction.payinExtraId, viewController: self)
        }
        view.set(amount: amountSend,
                 currency: self.transaction.fromCurrency,
                 address: self.transaction.payinAddress,
                 extraIdName: currenciesService.anonyms[self.transaction.fromCurrency],
                 extraId: self.transaction.payinExtraId)
        view.shareAction = Action { [weak self] in
            guard let self = self else { return }
            if let payinExtraId = self.transaction.payinExtraId {
                self.showShare(items: [self.transaction.payinAddress, payinExtraId])
            } else {
                self.showShare(items: [self.transaction.payinAddress])
            }
        }
        view.showQRAction = Action { [weak self] in
            guard let self = self else { return }
            let newVC = DepositQRViewController(qrCode: self.transaction.payinAddress,
                                                currency: self.transaction.fromCurrency,
                                                extraId: self.transaction.payinExtraId)
            newVC.set(
                copyAddressAction: Action { [weak self, weak newVC] in
                    self?.copy(string: self?.transaction.payinAddress, viewController: newVC)
                },
                copyExtraIdAction: Action { [weak self, weak newVC] in
                    self?.copy(string: self?.transaction.payinExtraId, viewController: newVC)
            })
            if #available(iOS 13.0, *) {
                newVC.modalPresentationStyle = .automatic
            } else {
                newVC.modalPresentationStyle = .overCurrentContext
            }
            self.present(newVC, animated: true, completion: nil)
        }
        view.trustWalletAction = Action { [weak self] in
            guard let self = self else { return }
            if !WalletsService.sendViaTrustWallet(ticker: self.transaction.fromCurrency,
                                                  address: self.transaction.payinAddress,
                                                  memo: self.transaction.payinExtraId,
                                                  amount: self.expectedSendAmount) {
                self.showError(R.string.localizable.transactionDepositTrustWalletNotSupported(self.transaction.fromCurrency.uppercased()))
            }
        }
        view.guardaWalletAction = Action { [weak self] in
            guard let self = self else { return }
            WalletsService.sendViaGuardaWallet(ticker: self.transaction.fromCurrency,
                                               address: self.transaction.payinAddress,
                                               memo: self.transaction.payinExtraId,
                                               amount: self.expectedSendAmount)
        }
        return view
    }()
    private lazy var supportView: TransactionSupportView = {
        let view = TransactionSupportView()
        view.supportAction = Action { [weak self] in
            guard let self = self else { return }
            let subject = "\(self.transaction.fromCurrency.uppercased()) to \(self.transaction.toCurrency.uppercased()) Transaction ID: \(self.transaction.id)"
            let message = "<p>Hello ChangeNOW support team,</p><p>Please keep me inform of the status of the solution to the problem in my transaction.</p><p>Thanks</p>"
            self.showEmail(subject: subject, message: message)
        }
        return view
    }()
    private lazy var startNewView: TransactionStartNewView = {
        let view = TransactionStartNewView()
        view.onTapAction = Action { [weak self] in
            self?.showMessage(
                R.string.localizable.transactionStartNewAlert(),
                cancelTitle: R.string.localizable.no(),
                actionTitle: R.string.localizable.yes(),
                action: Action { [weak self] in
                    self?.transactionService.removeTransaction()
                    self?.coordinatorService.showMainScreen()
                }
            )
        }
        return view
    }()

    private lazy var stepperView: TransactionStepperView = {
        let view = TransactionStepperView()
        view.set(fromCurrency: transaction.fromCurrency, toCurrency: transaction.toCurrency)
        return view
    }()
    private lazy var getDescriptionView = TransactionGetDescriptionView()
    private lazy var sendView = TransactionValueView()
    private lazy var getView = TransactionValueView()
    private lazy var refundedView = TransactionValueView()
    private lazy var statusDescriptionView = TransactionStatusDescriptionView()
    private lazy var refundedSeparatorView = TransactionSeparatorView()
    private lazy var rateUsView: TransactionRateUsView = {
        let view = TransactionRateUsView()
        view.rateUsAction = Action {
            RateAppService.makeRequest()
        }
        return view
    }()

    private lazy var internetAlertView: InternetAlertView = {
        let view = InternetAlertView(style: .transaction)
        view.isHidden = true
        return view
    }()

    // MARK: - Private

    private var transaction: TransactionStatusData
    private var status: TransactionStatus {
        didSet {
            updateByStatus(animated: true)
            feedbackOn(status: status)
        }
    }
    private let isInNavigationStack: Bool
    private let isNeedReload: Bool

    private var expectedSendAmount: Decimal {
        return transaction.expectedSendAmount?.rounding(withMode: .down, scale: GlobalConsts.maxMantissa) ??
            transaction.amountSend?.rounding(withMode: .down, scale: GlobalConsts.maxMantissa) ?? 0
    }
    private var expectedReceiveAmount: Decimal {
        return transaction.expectedReceiveAmount?.rounding(withMode: .down, scale: GlobalConsts.maxMantissa) ??
            transaction.amountReceive?.rounding(withMode: .down, scale: GlobalConsts.maxMantissa) ?? 0
    }
    private var amountSend: Decimal {
        return transaction.amountSend?.rounding(withMode: .down, scale: GlobalConsts.maxMantissa) ??
            transaction.expectedSendAmount?.rounding(withMode: .down, scale: GlobalConsts.maxMantissa) ?? 0
    }
    private var amountReceive: Decimal {
        return transaction.amountReceive?.rounding(withMode: .down, scale: GlobalConsts.maxMantissa) ??
            transaction.expectedReceiveAmount?.rounding(withMode: .down, scale: GlobalConsts.maxMantissa) ?? 0
    }

    private var isStarted = false
    private let refreshTransactionScheduler = ActionScheduler(dispatch: .main)
    private var refreshTransactionRequest: Cancellable?

    private var scrollViewBottomConstraint: Constraint?

    private let impactFeedbackGenerator: UIImpactFeedbackGenerator = {
        if #available(iOS 13.0, *) {
            return UIImpactFeedbackGenerator(style: .heavy)
        } else {
            return UIImpactFeedbackGenerator(style: .heavy)
        }
    }()
    private let notificationFeedbackGenerator = UINotificationFeedbackGenerator()
    private var stackViewObserver: NSKeyValueObservation?

    // MARK: - Life Cycle

    init(transaction: TransactionStatusData,
         isInNavigationStack: Bool,
         isNeedReload: Bool) {
        self.transaction = transaction
        self.status = TransactionStatus(rawValue: transaction.status) ?? .new
        self.isInNavigationStack = isInNavigationStack
        self.isNeedReload = isNeedReload
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        coordinatorService.prepareStart(viewController: self)
        view.backgroundColor = .transactionBackground

        addSubviews()
        setConstraints()

        updateByStatus()
        if isNeedReload {
            refreshTransactionScheduler.execute(after: 1) { [weak self] in
                self?.refreshStatus()
            }
        } else {
            refreshTransactionScheduler.execute(after: Consts.refreshInterval) { [weak self] in
                self?.refreshStatus()
            }
        }

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(refreshStatus),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
        reachabilityService.add(listener: self)

        stackViewObserver = stackView.observe(\UIStackView.bounds, options: [.new, .old]) { [weak self] stackView, change in
            guard let self = self else { return }
            if change.newValue != change.oldValue {
                let contentHeight = stackView.bounds.height + Consts.scrollViewTopOffset
                self.scrollView.contentSize = .init(width: self.scrollView.bounds.width, height: contentHeight)
                let isNeedScroll = self.scrollView.bounds.height < contentHeight
                if self.scrollView.isScrollEnabled != isNeedScroll {
                    self.scrollView.isScrollEnabled = isNeedScroll
                    self.scrollView.alwaysBounceVertical = isNeedScroll
                }
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isStarted = true
    }

    deinit {
        NotificationCenter.default.removeObserver(self,
                                                  name: UIApplication.didBecomeActiveNotification,
                                                  object: nil)
        reachabilityService.remove(listener: self)
        stackViewObserver?.invalidate()
        coordinatorService.prepareStop(viewController: self)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        updateBottomConstraint()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // MARK: - Status

    private func updateByStatus(animated: Bool = false) {
        func update() {
            updateHeaderView()
            updateStepperView()
            updateDeposit()
            updateRefunded()
            updateStarNew()
            updateSend()
            updateGet()
            updateAddress()
            updateGetDescription()
            updateDescription()
            updateSupportView()
            updateRateUsView()
            stackView.layoutIfNeeded()
            view.layoutIfNeeded()
        }
        if animated {
            UIView.animate(withDuration: 0.3,
                           delay: 0,
                           options: [.allowUserInteraction, .curveEaseInOut],
                           animations: { update() },
                           completion: nil)
        } else {
            update()
        }
    }

    private func updateHeaderView() {
        switch status {
        case .new, .waiting:
            headerView.set(status: .deposit)
        case .verifying, .confirming, .exchanging, .sending:
            headerView.set(status: .exchanging)
        case .finished:
            headerView.set(status: .finished)
        case .refunded:
            headerView.set(status: .refunded)
        case .failed, .expired:
            headerView.set(status: .failed)
        }
    }

    private func updateStepperView() {
        switch status {
        case .new, .waiting:
            stepperView.set(step: .first)
            showStackView(subview: stepperView)
        case .verifying, .confirming, .exchanging, .sending:
            stepperView.set(step: .second)
            showStackView(subview: stepperView)
        case .finished:
            stepperView.set(step: .third)
            showStackView(subview: stepperView)
        case .refunded, .failed, .expired:
            hideStackView(subview: stepperView)
        }
    }

    private func updateGetDescription() {
        func expectedValue() -> String {
            return "~ \(expectedReceiveAmount) \(transaction.toCurrency.uppercased())".wrapDirection()
        }
        switch status {
        case .new, .waiting:
            getDescriptionView.set(value: expectedValue(),
                                   address: transaction.payoutAddress,
                                   currency: transaction.toCurrency,
                                   extraIdName: transaction.payoutExtraIdName ?? currenciesService.anonyms[transaction.toCurrency],
                                   extraId: transaction.payoutExtraId)
            showStackView(subview: getDescriptionView)
        case .verifying, .confirming, .exchanging, .sending, .finished, .refunded, .failed, .expired:
            hideStackView(subview: getDescriptionView)
        }
    }

    private func updateDeposit() {
        switch status {
        case .new, .waiting:
            showStackView(subview: depositView)
        case .verifying, .confirming, .exchanging, .sending, .finished, .refunded, .failed, .expired:
            hideStackView(subview: depositView)
        }
    }

    private func updateRefunded() {
        switch status {
        case .refunded:
            refundedView.set(title: R.string.localizable.transactionRefunded())
            refundedView.set(value: "\(amountReceive) \(transaction.fromCurrency.uppercased())".wrapDirection())
            refundedView.setSelection(style: .green)
            showStackView(subview: refundedSeparatorView)
            showStackView(subview: refundedView)
        case .new, .waiting, .verifying, .confirming, .exchanging, .sending, .finished, .failed, .expired:
            hideStackView(subview: refundedSeparatorView)
            hideStackView(subview: refundedView)
        }
    }

    private func updateStarNew() {
        switch status {
        case .new, .waiting, .verifying, .confirming, .exchanging, .sending:
            startNewView.isHidden = true
        case .finished:
            startNewView.isHidden = false
            startNewView.set(style: .success)
        case .refunded, .failed, .expired:
            startNewView.isHidden = false
            startNewView.set(style: .failure)
        }
    }

    private func updateGet() {
        func expectedValue() -> String {
            return "~ \(expectedReceiveAmount) \(transaction.toCurrency.uppercased())".wrapDirection()
        }
        func expectedActualValue() -> String {
            return "~ \(amountReceive) \(transaction.toCurrency.uppercased())".wrapDirection()
        }
        func actualValue() -> String {
            return "\(amountReceive) \(transaction.toCurrency.uppercased())".wrapDirection()
        }
        func updateTitle(isFinished: Bool = false) {
            getView.set(title: isFinished ?
                R.string.localizable.transactionReceived() :
                R.string.localizable.transactionYouGet()
            )
        }
        switch status {
        case .new, .waiting:
            hideStackView(subview: getView)
        case .verifying, .confirming, .exchanging, .sending:
            updateTitle()
            getView.setSelection(style: .normal)
            getView.set(value: expectedActualValue())
            showStackView(subview: getView)
        case .finished:
            updateTitle(isFinished: true)
            getView.setSelection(style: .green)
            getView.set(value: actualValue())
            showStackView(subview: getView)
        case .refunded, .failed, .expired:
            updateTitle()
            getView.setSelection(style: .normal)
            getView.set(value: expectedValue())
            showStackView(subview: getView)
        }
    }

    private func updateSend() {
        switch status {
        case .new, .waiting:
            hideStackView(subview: sendView)
        case .verifying, .confirming, .exchanging, .sending, .finished, .refunded, .failed, .expired:
            sendView.set(title: R.string.localizable.transactionYouSent())
            sendView.set(value: "\(amountSend) \(transaction.fromCurrency.uppercased())".wrapDirection())
            showStackView(subview: sendView)
        }
    }

    private func updateAddress() {
        switch status {
        case .new, .waiting:
            hideStackView(subview: addressView)
        case .verifying, .confirming, .exchanging, .sending, .finished, .refunded, .failed, .expired:
            showStackView(subview: addressView)
        }
    }

    private func updateDescription() {
        func hide() {
            if #available(iOS 11.0, *) {
                switch Device.model {
                case .iPhone5, .iPhone6:
                    break
                default:
                    stackView.setCustomSpacing(Consts.spacing, after: statusDescriptionView)
                }
            }
            hideStackView(subview: statusDescriptionView)
        }
        switch status {
        case .new, .waiting:
            if #available(iOS 11.0, *) {
                switch Device.model {
                case .iPhone5, .iPhone6:
                    break
                default:
                    stackView.setCustomSpacing(50, after: statusDescriptionView)
                }
            }
            showStackView(subview: statusDescriptionView)
            statusDescriptionView.set(status: .deposit)
        case .verifying, .confirming, .exchanging, .sending:
            showStackView(subview: statusDescriptionView)
            statusDescriptionView.set(status: .exchanging)
        case .refunded:
            showStackView(subview: statusDescriptionView)
            statusDescriptionView.set(status: .refunded)
        case .finished:
            if ChangeNOW.isOriginalApp {
                hide()
            } else {
                showStackView(subview: statusDescriptionView)
                statusDescriptionView.set(status:
                    amountReceive > expectedReceiveAmount ? .finishedMore : .finished
                )
            }
        case .failed, .expired:
            hide()
        }
    }

    private func updateSupportView() {
        switch status {
        case .failed, .expired:
            showStackView(subview: supportView)
        case .new, .waiting, .verifying, .confirming, .exchanging, .sending, .refunded, .finished:
            hideStackView(subview: supportView)
        }
    }

    private func updateRateUsView() {
        switch status {
        case .finished:
            if ChangeNOW.isOriginalApp {
                rateUsView.set(isMoreThenExpected: amountReceive > expectedReceiveAmount)
                showStackView(subview: rateUsView)
            } else {
                hideStackView(subview: rateUsView)
            }
        case .new, .waiting, .verifying, .confirming, .exchanging, .sending, .refunded, .failed, .expired:
            hideStackView(subview: rateUsView)
        }
    }

    private func showStackView(subview: UIView) {
        if subview.isHidden {
            subview.isHidden = false
            subview.alpha = 1
            stackView.setNeedsLayout()
        }
    }

    private func hideStackView(subview: UIView) {
        if !subview.isHidden {
            subview.isHidden = true
            subview.alpha = 0
            stackView.setNeedsLayout()
        }
    }

    private func updateBottomConstraint() {
        var offset: CGFloat = 0
        if !startNewView.isHidden {
            offset = view.frame.size.height - startNewView.frame.minY
        }
        if !internetAlertView.isHidden {
            offset = view.frame.size.height - internetAlertView.frame.minY
        }
        if offset != 0, #available(iOS 11.0, *) {
            offset -= view.safeAreaInsets.bottom
        }
        offset += Consts.bottomOffset
        scrollViewBottomConstraint?.layoutConstraints.first?.constant = -offset
    }

    // MARK: - Views

    private func addSubviews() {
        let isNeedSeparators: Bool
        switch Device.model {
        case .iPhone5:
            isNeedSeparators = false
        default:
            isNeedSeparators = true
        }
        view.addSubview(headerView)
        #if DEVTOOLS
        view.addSubview(nextButton)
        #endif
        view.addSubview(contentView)
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        stackView.addArrangedSubview(stepperView)
        stackView.addArrangedSubview(depositView)
        stackView.addArrangedSubview(sendView)
        stackView.addArrangedSubview(getView)
        stackView.addArrangedSubview(addressView)
        if isNeedSeparators {
            stackView.addArrangedSubview(refundedSeparatorView)
        }
        stackView.addArrangedSubview(refundedView)
        stackView.addArrangedSubview(statusDescriptionView)
        stackView.addArrangedSubview(rateUsView)
        stackView.addArrangedSubview(supportView)
        stackView.addArrangedSubview(getDescriptionView)
        view.addSubview(startNewView)
        view.addSubview(internetAlertView)
    }

    private func setConstraints() {
        headerView.snp.makeConstraints {
            if #available(iOS 11.0, *) {
                $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(Consts.titleTopOffset)
            } else {
                $0.top.equalTo(topLayoutGuide.snp.bottom).offset(Consts.titleTopOffset)
            }
            $0.leading.trailing.equalToSuperview()
        }
        #if DEVTOOLS
        nextButton.snp.makeConstraints {
            if #available(iOS 11.0, *) {
                $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            } else {
                $0.top.equalTo(topLayoutGuide.snp.bottom)
            }
            $0.centerX.equalToSuperview()
        }
        #endif
        contentView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().offset(Consts.corner)
        }
        scrollView.snp.makeConstraints {
            $0.top.equalTo(contentView.snp.top)
            $0.leadingMargin.trailingMargin.equalToSuperview()
            if #available(iOS 11.0, *) {
                scrollViewBottomConstraint = $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
                    .offset(-Consts.bottomOffset)
                    .constraint
            } else {
                scrollViewBottomConstraint = $0.bottom.equalTo(bottomLayoutGuide.snp.top)
                    .offset(-Consts.bottomOffset)
                    .constraint
            }
        }

        startNewView.snp.makeConstraints {
            $0.leadingMargin.trailingMargin.equalToSuperview()
            if #available(iOS 11.0, *) {
                $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-Consts.bottomOffset)
            } else {
                $0.bottom.equalTo(bottomLayoutGuide.snp.top).offset(-Consts.bottomOffset)
            }
        }
        internetAlertView.snp.makeConstraints {
            $0.leadingMargin.trailingMargin.equalToSuperview()
            if #available(iOS 11.0, *) {
                $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-Consts.bottomOffset)
            } else {
                $0.bottom.equalTo(bottomLayoutGuide.snp.top).offset(-Consts.bottomOffset)
            }
        }
        stackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(Consts.scrollViewTopOffset)
            $0.centerX.width.equalToSuperview()
        }
        refundedSeparatorView.snp.makeConstraints {
            $0.height.equalTo(10)
        }
    }

    // MARK: - Actions

    private func copy(string: String?, viewController: UIViewController?) {
        UIPasteboard.general.string = string
        impactFeedback()
        viewController?.showCopiedLabel()
    }

    private func backButtonAction() {
        coordinatorService.dismiss()
    }

    @objc
    private func cancelButtonAction() {
        showMessage(
            R.string.localizable.transactionCancelText(),
            title: R.string.localizable.transactionCancelTitle(),
            cancelTitle: R.string.localizable.no(),
            actionTitle: R.string.localizable.yes(),
            action: Action { [weak self] in
                self?.transactionService.removeTransaction()
                self?.coordinatorService.showMainScreen()
            }
        )
    }

    @objc
    private func nextButtonAction() {
        refreshTransactionScheduler.invalidate()
        let cases = TransactionStatus.allCases.filter {
            switch $0 {
            case .new, .waiting, .exchanging, .finished, .refunded, .failed:
                return true
            case .verifying, .expired, .confirming, .sending:
                return false
            }
        }
        if status == .new || status == .waiting {
            status = .exchanging
        } else if let index = cases.firstIndex(of: status) {
            status = cases[safe: index + 1] ?? cases.first!
        }
    }

    @objc
    private func refreshStatus() {
        guard isStarted else { return }
        refreshTransactionRequest?.cancel()
        refreshTransactionRequest = transactionService.getTransactionStatus(id: transaction.id) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(transaction):
                self.transaction = transaction
                if let status = TransactionStatus(rawValue: transaction.status), status != self.status {
                    self.status = status
                }
            case let .failure(error):
                log.error(error.localizedDescription)
            }
            self.refreshTransactionScheduler.execute(after: Consts.refreshInterval) { [weak self] in
                self?.refreshStatus()
            }
        }
    }

    private func feedbackOn(status: TransactionStatus) {
        switch status {
        case .new, .waiting:
            break
        case .verifying, .confirming, .exchanging, .sending:
            impactFeedback()
        case .finished:
            notificationFeedback(type: .success)
        case .refunded:
            notificationFeedback(type: .warning)
        case .failed, .expired:
            notificationFeedback(type: .error)
        }
    }

    private func impactFeedback() {
        impactFeedbackGenerator.prepare()
        impactFeedbackGenerator.impactOccurred()
    }

    private func notificationFeedback(type: UINotificationFeedbackGenerator.FeedbackType = .success) {
        notificationFeedbackGenerator.prepare()
        notificationFeedbackGenerator.notificationOccurred(type)
    }
}

extension TransactionViewController: ReachabilityServiceDelegate {

    func networkReachabilityDidChanged(isReachable: Bool) {
        if internetAlertView.isHidden != isReachable {
            internetAlertView.isHidden = isReachable
        }
    }
}

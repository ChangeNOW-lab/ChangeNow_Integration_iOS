//
//  DepositQRViewController.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 28.04.2020.
//  Copyright © 2020 proninps. All rights reserved.
//

import SnapKit

class DepositQRViewController: UIViewController {

    @Injected private var currenciesService: CurrenciesService

    private lazy var depositQRView: DepositQRView = {
        let view = DepositQRView(qrCode: qrCode,
                                 currency: currency,
                                 extraIdName: currenciesService.anonyms[currency],
                                 extraId: extraId)
        view.closeAction = Action { [weak self] in
            self?.closeAction()
        }
        view.preservesSuperviewLayoutMargins = true
        return view
    }()

    private let qrCode: String
    private let currency: String
    private let extraId: String?

    init(qrCode: String, currency: String, extraId: String?) {
        self.qrCode = qrCode
        self.currency = currency
        self.extraId = extraId
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 13.0, *) {
            view.backgroundColor = .clear
        } else {
            view.backgroundColor = UIColor.black.withAlphaComponent(0.2)
            view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(closeAction)))
        }

        view.addSubview(depositQRView)
        depositQRView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }

    func set(copyAddressAction: Action?,
             copyExtraIdAction: Action?) {
        depositQRView.copyAddressAction = copyAddressAction
        depositQRView.copyExtraIdAction = copyExtraIdAction
    }

    @objc
    private func closeAction() {
        dismiss(animated: true, completion: nil)
    }
}

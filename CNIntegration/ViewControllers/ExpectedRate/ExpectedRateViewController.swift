//
//  ExpectedRateViewController.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 24.04.2020.
//  Copyright © 2020 proninps. All rights reserved.
//

import SnapKit

class ExpectedRateViewController: UIViewController {

    private lazy var expectedRateView: UIView = {
        let view = ExpectedRateView()
        view.closeAction = Action { [weak self] in
            self?.closeAction()
        }
        return view
    }()

    private lazy var visualEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .light)
        let view = UIVisualEffectView(effect: blurEffect)
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 13.0, *) {
            view.backgroundColor = .clear
        } else {
            view.backgroundColor = UIColor.black.withAlphaComponent(0.2)
            view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(closeAction)))
        }

        view.addSubview(visualEffectView)
        view.addSubview(expectedRateView)
        expectedRateView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
        }
        visualEffectView.snp.makeConstraints {
            $0.edges.equalTo(expectedRateView.snp.edges)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        visualEffectView.maskByRoundingCorners([.topLeft, .topRight], withRadii: CGSize(width: 13, height: 13))
    }

    @objc
    private func closeAction() {
        dismiss(animated: true, completion: nil)
    }
}

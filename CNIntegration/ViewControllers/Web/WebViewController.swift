//
//  WebViewController.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 22.08.2020.
//  Copyright © 2020 Pavel Pronin. All rights reserved.
//

import WebKit
import SnapKit

final class WebViewController: UIViewController {

    private lazy var webView: WKWebView = {
        let view = WKWebView()
        view.navigationDelegate = self
        return view
    }()

    private let url: URL

    init(url: URL, title: String) {
        self.url = url
        super.init(nibName: nil, bundle: nil)

        navigationItem.title = title
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        view.addSubview(webView)

        navigationItem.rightBarButtonItem = .init(image: R.image.cross(),
                                                  style: .plain,
                                                  target: self,
                                                  action: #selector(close))

        webView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        webView.load(URLRequest(url: url))
        showActivityIndicator()
    }

    @objc
    private func close() {
        dismiss(animated: true, completion: nil)
    }
}

extension WebViewController:  WKNavigationDelegate {

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        hideActivityIndicator()
    }
}

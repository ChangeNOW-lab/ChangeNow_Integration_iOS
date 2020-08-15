//
//  RateAppService.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 26.06.2020.
//  Copyright © 2020 proninps. All rights reserved.
//

import StoreKit

struct RateAppService {

    static let minimumReviewWorthyActionCount = 3

    static func makeRequest() {
        if shoudRequestRating() {
            requestRating()
        } else {
            requestReview()
        }
    }

    private static func shoudRequestRating() -> Bool {
        guard #available(iOS 10.3, *) else { return false }

        let date: Date? = UserDefaultsStorage.value(forKey: .lastReviewRequestDate)
        let actionCount: Int = UserDefaultsStorage.value(forKey: .reviewWorthyActionCount) ?? 0
        if date == nil || actionCount < minimumReviewWorthyActionCount {
            let currentVersion = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String
            let lastVersion: String? = UserDefaultsStorage.value(forKey: .lastReviewRequestAppVersion)
            guard lastVersion == nil || lastVersion != currentVersion else {
                return false
            }
            return true
        } else if let date = date, Date().years(from: date) >= 1 {
            UserDefaultsStorage.set(0, forKey: .reviewWorthyActionCount)
            return shoudRequestRating()
        }
        return false
    }

    private static func requestRating() {
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
        }
        var actionCount: Int = UserDefaultsStorage.value(forKey: .reviewWorthyActionCount) ?? 0
        actionCount += 1
        let currentVersion = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String
        UserDefaultsStorage.set(actionCount, forKey: .reviewWorthyActionCount)
        UserDefaultsStorage.set(currentVersion, forKey: .lastReviewRequestAppVersion)
        UserDefaultsStorage.set(Date(), forKey: .lastReviewRequestDate)
    }

    private static func requestReview() {
        guard let productURL = URL(string: "itms-apps://itunes.apple.com/app/1518003605") else { return }
        var components = URLComponents(url: productURL, resolvingAgainstBaseURL: false)
        components?.queryItems = [
            URLQueryItem(name: "action", value: "write-review")
        ]
        guard let writeReviewURL = components?.url else { return }
        UIApplication.shared.open(writeReviewURL)
    }
}

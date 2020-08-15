//
//  ReachabilityService.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 18.04.2020.
//  Copyright © 2020 proninps. All rights reserved.
//

import Alamofire

protocol ReachabilityServiceDelegate: AnyObject {

    func networkReachabilityDidChanged(isReachable: Bool)
}

class ReachabilityService {

    /// Singleton
    static let shared = ReachabilityService()

    var isReachable: Bool {
        return manager?.isReachable ?? false
    }

    var isReachableOnCellular: Bool {
        return manager?.isReachableOnCellular ?? false
    }

    var isReachableOnEthernetOrWiFi: Bool {
        return manager?.isReachableOnEthernetOrWiFi ?? false
    }

    private lazy var manager = NetworkReachabilityManager()

    private var listenersContainer = ListenerContainer<ReachabilityServiceDelegate>()

    init() {
        self.manager?.startListening(onUpdatePerforming: { [unowned self] _ in
            self.listenersContainer.forEach({ listener in
                listener.networkReachabilityDidChanged(isReachable: self.isReachable)
            })
        })
    }

    // MARK: - Listeners

    func add(listener: ReachabilityServiceDelegate) {
        listenersContainer.add(listener: listener)
    }

    func remove(listener: ReachabilityServiceDelegate) {
        listenersContainer.remove(listener: listener)
    }
}

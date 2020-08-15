//
//  ActionScheduler.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 29/03/2019.
//  Copyright © 2019 Pavel Pronin. All rights reserved.
//

final class ActionScheduler {

    // MARK: - Properties

    private let dispatch: DispatchQueue
    private var currentWorkItem: DispatchWorkItem?
    private var action: (() -> Void)?

    private var monitor = os_unfair_lock_s()

    // MARK: - Public

    init(dispatch: DispatchQueue = .global(qos: .default)) {
        self.dispatch = dispatch
    }

    func execute(after interval: TimeInterval, action: @escaping (() -> Void)) {
        os_unfair_lock_lock(&monitor)
        invalidate()
        self.action = action
        weak var item: DispatchWorkItem?
        currentWorkItem = DispatchWorkItem { [weak self] in
            if item?.isCancelled == false {
                self?.action?()
            }
        }
        item = currentWorkItem
        dispatch.asyncAfter(deadline: .now() + interval, execute: currentWorkItem!)
        os_unfair_lock_unlock(&monitor)
    }

    func invalidate() {
        currentWorkItem?.cancel()
        currentWorkItem = nil
        action = nil
    }
}

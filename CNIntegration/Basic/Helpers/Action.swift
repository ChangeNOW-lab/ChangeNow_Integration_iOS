//
//  Action.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 26.07.2020.
//  Copyright © 2018 Pavel Pronin. All rights reserved.
//

@objcMembers
final class Action: Equatable {
    private let closure: () -> Void

    init(closure: @escaping () -> Void) {
        self.closure = closure
    }

    func perform() {
        closure()
    }

    static func == (lhs: Action, rhs: Action) -> Bool {
        return true
    }
}

@objcMembers
final class ActionWith<T>: Equatable {
    private let closure: (T) -> Void

    init(closure: @escaping (T) -> Void) {
        self.closure = closure
    }

    func perform(with argument: T) {
        closure(argument)
    }

    static func == (lhs: ActionWith<T>, rhs: ActionWith<T>) -> Bool {
        return true
    }
}

@objcMembers
final class ActionWithResult<T, R>: Equatable {
    private let closure: (T) -> R

    init(closure: @escaping (T) -> R) {
        self.closure = closure
    }

    func perform(with argument: T) -> R {
        return closure(argument)
    }

    static func == (lhs: ActionWithResult<T, R>, rhs: ActionWithResult<T, R>) -> Bool {
        return true
    }
}

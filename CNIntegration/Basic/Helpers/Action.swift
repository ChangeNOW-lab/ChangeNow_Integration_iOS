//
//  Action.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 26.07.2020.
//  Copyright © 2018 Pavel Pronin. All rights reserved.
//

@objcMembers
public final class Action: Equatable {
    private let closure: () -> Void

    public init(closure: @escaping () -> Void) {
        self.closure = closure
    }

    public func perform() {
        closure()
    }

    public static func == (lhs: Action, rhs: Action) -> Bool {
        return true
    }
}

@objcMembers
public final class ActionWith<T>: Equatable {
    private let closure: (T) -> Void

    public init(closure: @escaping (T) -> Void) {
        self.closure = closure
    }

    public func perform(with argument: T) {
        closure(argument)
    }

    public static func == (lhs: ActionWith<T>, rhs: ActionWith<T>) -> Bool {
        return true
    }
}

@objcMembers
public final class ActionWithResult<T, R>: Equatable {
    private let closure: (T) -> R

    public init(closure: @escaping (T) -> R) {
        self.closure = closure
    }

    public func perform(with argument: T) -> R {
        return closure(argument)
    }

    public static func == (lhs: ActionWithResult<T, R>, rhs: ActionWithResult<T, R>) -> Bool {
        return true
    }
}

//
//  Injected.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 25.07.2020.
//  Copyright © 2020 proninps. All rights reserved.
//

import Resolver

@propertyWrapper
struct Injected<Service> {

    private var service: Service!

    public var container: Resolver?
    public var name: String?

    public init() {}

    public init(name: String? = nil, container: Resolver? = nil) {
        self.name = name
        self.container = container
    }

    public var wrappedValue: Service {
        mutating get {
            if self.service == nil {
                self.service = container?.resolve(Service.self, name: name) ?? Resolver.resolve(Service.self, name: name)
            }
            return service
        }
        mutating set {
            service = newValue
        }
    }

    public var projectedValue: Injected<Service> {
        get { return self }
        mutating set { self = newValue }
    }
}

@propertyWrapper
public struct LazyInjected<Service> {

    private var service: Service

    public init() {
        self.service = Resolver.resolve(Service.self)
    }

    public init(name: String? = nil, container: Resolver? = nil) {
        self.service = container?.resolve(Service.self, name: name) ?? Resolver.resolve(Service.self, name: name)
    }

    public var wrappedValue: Service {
        get { return service }
        mutating set { service = newValue }
    }

    public var projectedValue: LazyInjected<Service> {
        get { return self }
        mutating set { self = newValue }
    }
}

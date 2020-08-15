//
//  UITableView+Additions.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 22/07/16.
//  Copyright © 2016 Pavel Pronin. All rights reserved.
//

protocol ReusableIdentifierProvider: class {
    static var reuseIdentifier: String { get }
}

extension ReusableIdentifierProvider {
    static var reuseIdentifier: String {
        return String(describing: Self.self)
    }
}

protocol Reusable: class {
    static var reuseIdentifier: String { get }
    static var nib: UINib? { get }
}

extension Reusable {

    static var nib: UINib? {
        return nil
    }

    private static func nib(for bundle: Bundle?) -> UINib {
        return UINib(nibName: self.reuseIdentifier, bundle: bundle)
    }

    static func loadViewFromNib() -> UIView? {
        return self.nib(for: Bundle(for: self)).instantiate(withOwner: nil, options: nil).first as? UIView
    }
}

extension Reusable where Self: UIView {
    static var reuseIdentifier: String {
        return String(describing: Self.self)
    }
}

extension UITableView {

    func registerReusableCell<T: UITableViewCell>(_: T.Type, identifierProvider: ReusableIdentifierProvider) {
        self.register(T.self, forCellReuseIdentifier: type(of: identifierProvider).reuseIdentifier)
    }

    func registerReusableCell<T: UITableViewCell>(_: T.Type) where T: Reusable {
        if let nib = T.nib {
            self.register(nib, forCellReuseIdentifier: T.reuseIdentifier)
        } else {
            self.register(T.self, forCellReuseIdentifier: T.reuseIdentifier)
        }
    }

    func registerReusableHeaderFooter<T: UITableViewHeaderFooterView>(_: T.Type, identifierProvider: ReusableIdentifierProvider) {
        self.register(T.self, forHeaderFooterViewReuseIdentifier: type(of: identifierProvider).reuseIdentifier)
    }

    func registerReusableHeaderFooter<T: UITableViewHeaderFooterView>(_: T.Type) where T: Reusable {
        if let nib = T.nib {
            self.register(nib, forHeaderFooterViewReuseIdentifier: T.reuseIdentifier)
        } else {
            self.register(T.self, forHeaderFooterViewReuseIdentifier: T.reuseIdentifier)
        }
    }

    func dequeueReusableCell<T: UITableViewCell>(_ indexPath: IndexPath, identifierProvider: ReusableIdentifierProvider) -> T {
        return self.dequeueReusableCell(withIdentifier: type(of: identifierProvider).reuseIdentifier, for: indexPath) as! T
    }

    func dequeueReusableCell<T: Reusable>(_ indexPath: IndexPath) -> T {
        return self.dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: indexPath) as! T
    }

    func dequeueReusableHeaderFooter<T: UITableViewHeaderFooterView>(identifierProvider: ReusableIdentifierProvider) -> T {
        return self.dequeueReusableHeaderFooterView(withIdentifier: type(of: identifierProvider).reuseIdentifier) as! T
    }

    func dequeueReusableHeaderFooter<T: Reusable>() -> T {
        return self.dequeueReusableHeaderFooterView(withIdentifier: T.reuseIdentifier) as! T
    }
}

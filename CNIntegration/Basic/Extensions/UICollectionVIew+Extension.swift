//
//  UICollectionVIew+Additions.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 02/08/2017.
//  Copyright © 2017 Pavel Pronin. All rights reserved.
//

extension UICollectionView {

    func registerReusableCell<T: UICollectionViewCell>(_: T.Type, identifierProvider: ReusableIdentifierProvider) {
        self.register(T.self, forCellWithReuseIdentifier: type(of: identifierProvider).reuseIdentifier)
    }

    func registerReusableCell<T: UICollectionViewCell>(_: T.Type) where T: Reusable {
        if let nib = T.nib {
            self.register(nib, forCellWithReuseIdentifier: T.reuseIdentifier)
        } else {
            self.register(T.self, forCellWithReuseIdentifier: T.reuseIdentifier)
        }
    }

    func dequeueReusableCell<T: UICollectionViewCell>(_ indexPath: IndexPath, identifierProvider: ReusableIdentifierProvider) -> T {
        return self.dequeueReusableCell(withReuseIdentifier: type(of: identifierProvider).reuseIdentifier, for: indexPath) as! T
    }

    func dequeueReusableCell<T: Reusable>(_ indexPath: IndexPath) -> T {
        return self.dequeueReusableCell(withReuseIdentifier: T.reuseIdentifier, for: indexPath) as! T
    }
}

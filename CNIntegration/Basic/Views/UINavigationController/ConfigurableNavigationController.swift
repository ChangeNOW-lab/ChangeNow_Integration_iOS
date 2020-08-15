//
//  ConfigurableNavigationController.swift
//  CNIntegration
//
//  Created by Pavel Pronin on 20/03/2019.
//  Copyright © 2019 Pavel Pronin. All rights reserved.
//

class ConfigurableNavigationController: UINavigationController {
    
    private var isFirstLoad: Bool = true
    private var hideConfiguration: NavigationBarHideConfiguration?
    private var navigationBarAppearanceConfiguration = NavigationBarAppearanceConfiguration.common
    
    private lazy var mutablePreferredStatusBarStyle: UIStatusBarStyle = {
        return navigationBarAppearanceConfiguration.statusBarStyle
    }()
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return mutablePreferredStatusBarStyle
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        navigationBar.backItem?.title = ""
        delegate = self
        interactivePopGestureRecognizer?.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isFirstLoad,
            let vc = topViewController {
            isFirstLoad = false
            setNavBarStyle(for: vc)
        }
    }
    
    private func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
    
    private func applyAppearanceConfiguration(of viewController: UIViewController,
                                              to navigationBar: UINavigationBar) {
        let configuration = viewController.navBarAppearanceConfiguration
        guard configuration != self.navigationBarAppearanceConfiguration else {
            return
        }
        self.navigationBarAppearanceConfiguration = configuration
        navigationBar.setBackgroundImage(configuration.backgroundImage, for: .default)
        navigationBar.shadowImage = configuration.shadowImage
        navigationBar.isTranslucent = configuration.isTranslucent
        navigationBar.tintColor = configuration.tintColor
        navigationBar.barTintColor = configuration.barTintColor
        view.backgroundColor = configuration.navigationControllerViewColor
        view.setNeedsLayout()
        navigationBar.titleTextAttributes = makeTitleTextAttributes(textColor: configuration.titleTextColor,
                                                                    oldAttributes: navigationBar.titleTextAttributes)
        if mutablePreferredStatusBarStyle != configuration.statusBarStyle {
            mutablePreferredStatusBarStyle = configuration.statusBarStyle
            setNeedsStatusBarAppearanceUpdate()
        }
    }
}

private func makeTitleTextAttributes(textColor: UIColor?,
                                     oldAttributes: [NSAttributedString.Key: Any]?) -> [NSAttributedString.Key: Any]? {
    if var newAttributes = oldAttributes {
        newAttributes[NSAttributedString.Key.foregroundColor] = textColor
        return newAttributes
    }
    if let textColor = textColor {
        return [NSAttributedString.Key.foregroundColor: textColor]
    }
    return nil
}

extension ConfigurableNavigationController: UIGestureRecognizerDelegate {
    
}

extension ConfigurableNavigationController: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController,
                              willShow viewController: UIViewController, animated: Bool) {
        if viewController.navigationBarHideConfiguration == .shown {
            applyAppearanceConfiguration(of: viewController, to: navigationBar)
        }
        setNavBarStyle(for: viewController)
        
        if let coordinator = navigationController.topViewController?.transitionCoordinator {
            coordinator.notifyWhenInteractionChanges { [weak self] (context) in
                guard let self = self else {
                    return
                }
                if context.isCancelled,
                    let fromVC = context.viewController(forKey: UITransitionContextViewControllerKey.from) {
                    self.setNavBarStyle(for: fromVC, animated: false)
                    self.applyAppearanceConfiguration(of: fromVC, to: self.navigationBar)
                }
            }
        }
    }
    
    func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationController.Operation,
                              from fromVC: UIViewController,
                              to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        applyAppearanceConfiguration(of: toVC, to: navigationBar)
        setNavBarStyle(for: toVC)
        return nil
    }
    
    private func setNavBarStyle(for viewController: UIViewController,
                                animated: Bool = true) {
        let controllerHideConfiguration = viewController.navigationBarHideConfiguration
        if hideConfiguration != controllerHideConfiguration {
            hideConfiguration = controllerHideConfiguration
            setNavigationBarHidden(state: controllerHideConfiguration.isHidden, animated: animated)
        } else {
            setNavigationBarHidden(state: controllerHideConfiguration.isHidden, animated: false)
        }
    }
    
    private func setNavigationBarHidden(state: Bool, animated: Bool) {
        guard navigationBar.isHidden != state else {
            return
        }
        if animated {
            setNavigationBarHidden(state, animated: true)
        } else {
            navigationBar.isHidden = state
        }
    }
}

private extension UIViewController {
    
    var navigationBarHideConfiguration: NavigationBarHideConfiguration {
        return (self as? NavigationBarHideConfigurator)?.navigationBarHideConfiguration ?? .shown
    }
    
    var navBarAppearanceConfiguration: NavigationBarAppearanceConfiguration {
        return (self as? NavigationBarAppearanceConfigurator)?.navigationBarAppearanceConfiguration
            ?? NavigationBarAppearanceConfiguration.common
    }
}

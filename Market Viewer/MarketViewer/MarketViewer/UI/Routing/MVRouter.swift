//
//  MVRouter.swift
//  MarketViewer
//
//  Created by Alin Gorgan on 09/08/2018.
//  Copyright © 2018 ACME. All rights reserved.
//

import UIKit

protocol MVRouting: class {
    
    func navigateToRootViewController(with window: UIWindow)
    
    func navigateToMarketWatchlistViewController()
    
    func navigateToLogInScreen()
    
    func navigateToAlertScreen(with title: String, and message: String)
    
    func navigateToMarketDetailsScreen(with marketEpic: String)
    
    func close(view: MVView)
}

final class MVRouter: MVRouting {
    
    private let wireframe: MVViewCreating
    private var navigationController: UINavigationController!
    
    init(wireframe: MVViewCreating) {
        self.wireframe = wireframe
    }
    
    func navigateToRootViewController(with window: UIWindow) {
        navigationController = wireframe.makeNavigationController()
        window.rootViewController = navigationController
    }
    
    func navigateToMarketWatchlistViewController() {
        let marketWatchlistViewController = wireframe.makeMarketWatchlistViewController()
        navigationController.pushViewController(marketWatchlistViewController, animated: false)
    }
    
    func navigateToLogInScreen() {
        let logInScreenViewController = wireframe.makeLogInScreen()
        navigationController.present(logInScreenViewController, animated: true, completion: nil)
    }
    
    func navigateToAlertScreen(with title: String, and message: String) {
        let alertViewController = wireframe.makeAlertController(with: title, and: message)
        navigationController.present(alertViewController, animated: true, completion: nil)
    }
    
    func navigateToMarketDetailsScreen(with marketEpic: String) {
        let marketDetailsViewController = wireframe.makeMarketDetailsScreen(with: marketEpic)
        navigationController.pushViewController(marketDetailsViewController, animated: true)
    }
    
    func close(view: MVView) {
        guard let viewController = view as? UIViewController else {
            fatalError("view is not a UIViewController instance")
        }
        
        guard viewController.presentingViewController == nil else {
            viewController.dismiss(animated: true, completion: nil)
            return
        }
        
        guard let lastViewController = navigationController.viewControllers.last,
            lastViewController == viewController
        else {
            fatalError("the view controller is not at the top of the stack")
        }
        
        navigationController.popViewController(animated: true)
    }
}

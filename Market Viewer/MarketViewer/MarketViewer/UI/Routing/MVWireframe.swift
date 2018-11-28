//
//  MVWireframe.swift
//  MarketViewer
//
//  Created by Alin Gorgan on 09/08/2018.
//  Copyright © 2018 ACME. All rights reserved.
//

import UIKit

protocol MVViewCreating {
    
    func makeNavigationController() -> UINavigationController
    
    func makeMarketWatchlistViewController() -> UIViewController
    
    func makeLogInScreen() -> UIViewController
    
    func makeMarketDetailsScreen(with marketEpic: String) -> UIViewController
    
    func makeAlertController(with title: String, and message: String) -> UIViewController
    
}

final class MVWireframe: MVViewCreating {
    
    private let storyboard: UIStoryboard
    private let tokenStore: MVAuthTokenStoring
    private let lightStreamerConfigurationStore: MVLightStreamerConfigurationStoring
    private let marketUpdateChecker: MVMarketLightStreaming
    
    weak var router: MVRouting!
    
    convenience init(storyboard: UIStoryboard) {
        let tokenStore = MVAuthTokenStore()
        let lightStreamerConfigurationStore = MVLightStreamerConfigurationStore()
        let marketUpdateChecker = MarketLightstreamer()
        
        self.init(storyboard: storyboard,
                  tokenStore: tokenStore,
                  lightStreamerConfigurationStore: lightStreamerConfigurationStore,
                  marketUpdateChecker: marketUpdateChecker)
    }
    
    init(storyboard: UIStoryboard,
         tokenStore: MVAuthTokenStoring,
         lightStreamerConfigurationStore: MVLightStreamerConfigurationStoring,
         marketUpdateChecker: MVMarketLightStreaming) {
        
        self.storyboard = storyboard
        self.tokenStore = tokenStore
        self.lightStreamerConfigurationStore = lightStreamerConfigurationStore
        self.marketUpdateChecker = marketUpdateChecker
    }
    
    func makeNavigationController() -> UINavigationController {
        guard let viewController = storyboard.instantiateInitialViewController() as? UINavigationController else {
            fatalError("No navigation controller found")
        }
        
        return viewController
    }
    
    func makeMarketWatchlistViewController() -> UIViewController {
        let viewController: MVMarketWatchlistViewController = storyboard.makeViewController()
        let httpHeaderProvider = MVHTTPHeaderProvider(tokenStore: tokenStore)
        let marketRequestFactory = MVMarketRequestFactory(httpHeaderProvider: httpHeaderProvider)
        let interactor = MVMarketWatchlistInteractor(marketRequestFactory: marketRequestFactory,
                                                     authTokenStore: tokenStore,
                                                     lightStreamerConfigurationStore: lightStreamerConfigurationStore,
                                                     marketUpdateChecker: marketUpdateChecker)
        let presenter = MVMarketWatchlistPresenter(view: viewController, interactor: interactor, router: router)
        interactor.delegate = presenter
        
        viewController.presenter = presenter
        
        return viewController
    }
    
    func makeLogInScreen() -> UIViewController {
        let httpHeaderProvider = MVHTTPHeaderProvider(tokenStore: tokenStore)
        let loginRequestFactory = MVLoginRequestFactory(httpHeaderProvider: httpHeaderProvider)
        let userAuthenticator = MVUserAuthenticator(loginRequestFactory: loginRequestFactory,
                                                    authTokenStore: tokenStore,
                                                    lightStreamerConfigurationStore: lightStreamerConfigurationStore)
        let interactor = MVLoginViewInteractor(userAuthenticator: userAuthenticator)
        
        let viewController: MVLoginViewController = storyboard.makeViewController()
        let presenter = MVLoginViewPresenter(view: viewController, interactor: interactor, router: router)
        viewController.presenter = presenter
        
        return viewController
    }
    
    func makeMarketDetailsScreen(with marketEpic: String) -> UIViewController {
        let viewController: MVMarketDetailsViewController = storyboard.makeViewController()
        let httpHeaderProvider = MVHTTPHeaderProvider(tokenStore: tokenStore)
        let marketRequestFactory = MVMarketDetailsRequestFactory(httpHeaderProvider: httpHeaderProvider)
        let interactor = MVMarketDetailsInteractor(marketEpic: marketEpic, marketRequestFactory: marketRequestFactory)
        let presenter = MVMarketDetailsViewPresenter(view: viewController,
                                                     interactor: interactor,
                                                     router: router)
        viewController.presenter = presenter
        
        return viewController
    }
    
    func makeAlertController(with title: String, and message: String) -> UIViewController {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let OKAction = UIAlertAction(title: "OK", style: .default) { [weak alertController] (action) in
            alertController?.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(OKAction)
        
        return alertController
    }
    
}

extension UIStoryboard {
    
    func makeViewController<ViewController: UIViewController>() -> ViewController {
        let storyboardIdentifier = String(describing: ViewController.self)
        guard let viewController = instantiateViewController(withIdentifier: storyboardIdentifier) as? ViewController else {
            fatalError("No view controller found with identifier \(storyboardIdentifier)")
        }
        
        return viewController
    }
    
}

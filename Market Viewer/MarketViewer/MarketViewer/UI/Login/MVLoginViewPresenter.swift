//
//  MVLoginViewPresenter.swift
//  MarketViewer
//
//  Created by Alin Gorgan on 09/08/2018.
//  Copyright © 2018 ACME. All rights reserved.
//

import Foundation

protocol MVLoginViewPresenting {
    
    func viewIsReady()
    
    func handleLoginAction(with username: String, and password: String)
    
}

final class MVLoginViewPresenter: MVLoginViewPresenting {
    
    private unowned let view: MVLoginView
    private let interactor: MVLoginViewInteracting
    private let router: MVRouting
    
    init(view: MVLoginView, interactor: MVLoginViewInteracting, router: MVRouting) {
        self.view = view
        self.interactor = interactor
        self.router = router
    }
    
    func viewIsReady() {
        view.viewModel = MVLoginViewModel(
            title: "Log in to see popular markets.",
            userName: "DEMO-IGIOSCANDIDATE003-LIVE",
            password: "Qazqaz123",
            loginButtonTitle: "Login")
    }
    
    func handleLoginAction(with username: String, and password: String) {
        interactor.loginUser(with: username, and: password) { [weak self] (success) in
            guard let `self` = self else {
                return
            }
            
            DispatchQueue.main.async {
                if success {
                    self.router.close(view: self.view)
                }
                else {
                    let title = "Oops"
                    let message = "Login failed. Please check your credentials and try again"
                    self.router.navigateToAlertScreen(with: title, and: message)
                }
            }
        }
    }
    
}

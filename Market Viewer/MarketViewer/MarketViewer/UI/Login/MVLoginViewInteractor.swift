//
//  MVLoginViewInteractor.swift
//  MarketViewer
//
//  Created by Alin Gorgan on 09/08/2018.
//  Copyright © 2018 ACME. All rights reserved.
//

import Foundation

protocol MVLoginViewInteracting {
    func loginUser(with username: String, and password: String, completion: @escaping (_ success: Bool) -> Void)
}

final class MVLoginViewInteractor: MVLoginViewInteracting {
    
    private let userAuthenticator: MVUserAuthenticating
    
    init(userAuthenticator: MVUserAuthenticating) {
        self.userAuthenticator = userAuthenticator
    }
    
    func loginUser(with username: String, and password: String, completion: @escaping (Bool) -> Void) {
        userAuthenticator.authenticateUser(with: username, password: password, completion: completion)
    }
    
}

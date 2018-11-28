//
//  MVUserAuthenticator.swift
//  MarketViewer
//
//  Created by Alin Gorgan on 09/08/2018.
//  Copyright © 2018 ACME. All rights reserved.
//

import Foundation

protocol MVUserAuthenticating {
    func authenticateUser(with userName: String, password: String, completion: @escaping (_ success: Bool) -> Void)
}

final class MVUserAuthenticator: MVUserAuthenticating {
    
    private let loginRequestFactory: MVLoginRequestCreating
    private let authTokenStore: MVAuthTokenStoring
    private let lightStreamerConfigurationStore: MVLightStreamerConfigurationStoring
    
    init(loginRequestFactory: MVLoginRequestCreating,
         authTokenStore: MVAuthTokenStoring,
         lightStreamerConfigurationStore: MVLightStreamerConfigurationStoring) {
        
        self.loginRequestFactory = loginRequestFactory
        self.authTokenStore = authTokenStore
        self.lightStreamerConfigurationStore = lightStreamerConfigurationStore
    }
    
    func authenticateUser(with userName: String, password: String, completion: @escaping (_ success: Bool) -> Void) {
        guard let request = loginRequestFactory.makeLoginRequest(with: userName, and: password) else {
            completion(false)
            return
        }
        
        URLSession.shared.dataTask(with: request) { [weak self] (data, urlResponse, error) in
            
            guard let `self` = self else { return }
            
            guard let response = urlResponse as? HTTPURLResponse, let data = data, error == nil,
            let loginRawModel = try? JSONDecoder().decode(LoginRawModel.self, from: data) else {
                completion(false)
                return
            }

            self.lightStreamerConfigurationStore.update(with: loginRawModel)
            self.authTokenStore[.cst] = response.allHeaderFields["CST"] as? String
            self.authTokenStore[.xSecurity] = response.allHeaderFields["X-SECURITY-TOKEN"] as? String
            
            let success = response.statusCode == 200
            completion(success)
        }.resume()
    }
}

fileprivate struct LoginRawModel: Codable {
    let lightstreamerEndpoint: String?
    let currentAccountId: String?
    
    private enum CodingKeys: String, CodingKey {
        case lightstreamerEndpoint
        case currentAccountId
    }
}

fileprivate extension MVLightStreamerConfigurationStoring {
    func update(with loginRawModel: LoginRawModel?) {
        self[.accountId] = loginRawModel?.currentAccountId
        self[.endpoint] = loginRawModel?.lightstreamerEndpoint
    }
}


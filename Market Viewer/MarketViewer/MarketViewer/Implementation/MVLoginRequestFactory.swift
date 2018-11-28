//
//  LoginRequestFactory.swift
//  MarketViewer
//
//  Created by Alin Gorgan on 09/08/2018.
//  Copyright © 2018 ACME. All rights reserved.
//

import Foundation

protocol MVLoginRequestCreating {
    func makeLoginRequest(with username: String, and password: String) -> URLRequest?
}

final class MVLoginRequestFactory: MVLoginRequestCreating {
    
    let httpHeaderProvider: MVHTTPHeaderProviding
    
    init(httpHeaderProvider: MVHTTPHeaderProviding) {
       self.httpHeaderProvider = httpHeaderProvider
    }
    
    func makeLoginRequest(with username: String, and password: String) -> URLRequest? {
        guard let loginUrl = URL(string: "\(URLConstants.baseURL)/gateway/deal/session") else { return nil }
        
        let bodyData: [String: Any] = [
            "identifier": username,
            "password": password,
            "encryptedPassword": false]
        
        var request = URLRequest(url: loginUrl)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: bodyData)
        request.addValue("2", forHTTPHeaderField: "VERSION")
        
        httpHeaderProvider.httpHeaders().forEach { header in
            request.addValue(header.value, forHTTPHeaderField: header.field)
        }
        
        return request
    }
    
}

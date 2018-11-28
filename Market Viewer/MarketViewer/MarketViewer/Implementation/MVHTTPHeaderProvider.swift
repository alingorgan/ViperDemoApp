//
//  MVHTTPHeaderProvider.swift
//  MarketViewer
//
//  Created by Alin Gorgan on 09/08/2018.
//  Copyright © 2018 ACME. All rights reserved.
//

import Foundation

struct MVHTTPHeader {
    let field: String
    let value: String
}

protocol MVHTTPHeaderProviding {
    func httpHeaders() -> [MVHTTPHeader]
}

final class MVHTTPHeaderProvider: MVHTTPHeaderProviding {
    
    private let tokenStore: MVAuthTokenStoring
    
    init(tokenStore: MVAuthTokenStoring) {
        self.tokenStore = tokenStore
    }
    
    func httpHeaders() -> [MVHTTPHeader] {
        
        var headerMap = [
            "X-IG-API-KEY": "e5fe5ca0c6b0096fd14601267f0c52974a55ebf1",
            "Content-Type": "application/json",
            "Accept": "application/json; charset=UTF-8"
        ]
        
        if let tokenValue = tokenStore[.cst] {
            headerMap[MVAuthTokenType.cst.name] = tokenValue
        }
        
        if let tokenValue = tokenStore[.xSecurity] {
            headerMap[MVAuthTokenType.xSecurity.name] = tokenValue
        }
        
       return headerMap.map({ (field, value) in MVHTTPHeader(field: field, value: value) })
    }
}

fileprivate extension MVAuthTokenType {
    
    var name: String {
        get {
            switch self {
            case .cst: return "CST"
            case .xSecurity: return "X-SECURITY-TOKEN"
            }
        }
    }
}

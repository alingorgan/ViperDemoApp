//
//  MVAuthTokenStoring.swift
//  MarketViewer
//
//  Created by Alin Gorgan on 09/08/2018.
//  Copyright © 2018 ACME. All rights reserved.
//

import Foundation

enum MVAuthTokenType: Hashable {
    case cst
    case xSecurity
    
    var hashValue: Int {
        get {
            switch self {
            case .cst: return 0
            case .xSecurity: return 1
            }
        }
    }
}

protocol MVAuthTokenStoring: class {
    
    subscript(key: MVAuthTokenType) -> String? { get set }
}

final class MVAuthTokenStore: MVAuthTokenStoring {
    
    private var authTokenMap = [MVAuthTokenType: String]()
    
    subscript(key: MVAuthTokenType) -> String? {
        get {
            return authTokenMap[key]
        }
        set {
            authTokenMap[key] = newValue
        }
    }
    
}

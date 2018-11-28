//
//  MVMarketRequestFactory.swift
//  MarketViewer
//
//  Created by Alin Gorgan on 10/08/2018.
//  Copyright © 2018 ACME. All rights reserved.
//

import Foundation

protocol MVMarketRequestCreating {
    func makeMarketRequest(marketName: String) -> URLRequest?
}

final class MVMarketRequestFactory: MVMarketRequestCreating {
    
    let httpHeaderProvider: MVHTTPHeaderProviding
    
    init(httpHeaderProvider: MVHTTPHeaderProviding) {
        self.httpHeaderProvider = httpHeaderProvider
    }
    
    func makeMarketRequest(marketName: String) -> URLRequest? {
        guard
            let marketName = marketName.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
            let marketUrl = URL(string: "\(URLConstants.baseURL)/gateway/deal/watchlists/\(marketName)")
        else { return nil }
        
        var request = URLRequest(url: marketUrl)
        
        httpHeaderProvider.httpHeaders().forEach { header in
            request.addValue(header.value, forHTTPHeaderField: header.field)
        }
        
        return request
    }
}

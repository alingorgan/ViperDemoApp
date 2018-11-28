//
//  MVMarketDetailsRequestFactory.swift
//  MarketViewer
//
//  Created by Alin Gorgan on 12/08/2018.
//  Copyright © 2018 ACME. All rights reserved.
//

import Foundation

protocol MVMarketDetailsRequestCreating {
    
    func makeMarketDetailsRequest(with marketEpic: String) -> URLRequest?
}

final class MVMarketDetailsRequestFactory: MVMarketDetailsRequestCreating {
    
    let httpHeaderProvider: MVHTTPHeaderProviding
    
    init(httpHeaderProvider: MVHTTPHeaderProviding) {
        self.httpHeaderProvider = httpHeaderProvider
    }
    
    func makeMarketDetailsRequest(with marketEpic: String) -> URLRequest? {
        guard
            let encodedMarketEpic = marketEpic.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
            let marketUrl = URL(string: "\(URLConstants.baseURL)/gateway/deal/markets/\(encodedMarketEpic)")
            else { return nil }
        
        var request = URLRequest(url: marketUrl)
        
        httpHeaderProvider.httpHeaders().forEach { header in
            request.addValue(header.value, forHTTPHeaderField: header.field)
        }
        
        return request
    }
}

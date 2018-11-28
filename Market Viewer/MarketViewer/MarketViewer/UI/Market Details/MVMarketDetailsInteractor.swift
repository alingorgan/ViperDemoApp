//
//  MVMarketDetailsInteractor.swift
//  MarketViewer
//
//  Created by Alin Gorgan on 12/08/2018.
//  Copyright © 2018 ACME. All rights reserved.
//

import Foundation

protocol MVMarketDetailsInteracting {
    
    func loadMarketDetails(completion: @escaping (_ rawModel: MVMarketDetailsRawModel?) -> Void)
}

final class MVMarketDetailsInteractor: MVMarketDetailsInteracting {
    
    private let marketEpic: String
    private let marketRequestFactory: MVMarketDetailsRequestCreating
    private var marketDetailsRawModel: MVMarketDetailsRawModel?
    
    init(marketEpic: String, marketRequestFactory: MVMarketDetailsRequestCreating) {
        self.marketEpic = marketEpic
        self.marketRequestFactory = marketRequestFactory
    }
    
    func loadMarketDetails(completion: @escaping (_ rawModel: MVMarketDetailsRawModel?) -> Void) {
        guard let request = marketRequestFactory.makeMarketDetailsRequest(with: marketEpic) else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: request) { (data, urlResponse, error) in
            
            print(try! JSONSerialization.jsonObject(with: data!, options: .allowFragments))
            
            guard
                let data = data, error == nil,
                let marketDetailsResponseRawModel = try? JSONDecoder().decode(MVMarketDetailsResponseRawModel.self, from: data)
            else {
                completion(nil)
                return
            }
            
            self.marketDetailsRawModel = marketDetailsResponseRawModel.marketDetailsRawModel
            completion(self.marketDetailsRawModel)
            }.resume()
    }
}

fileprivate struct MVMarketDetailsResponseRawModel: Codable {
    let marketDetailsRawModel: MVMarketDetailsRawModel?
    
    private enum CodingKeys: String, CodingKey {
        case marketDetailsRawModel = "instrument"
    }
}

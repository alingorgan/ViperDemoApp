//
//  MVMarketWatchlistInteractor.swift
//  MarketViewer
//
//  Created by Alin Gorgan on 09/08/2018.
//  Copyright © 2018 ACME. All rights reserved.
//

import Foundation
import Lightstreamer_iOS_Client

protocol MVMarketWatchlistInteractorDelegate: class {
    
    func didUpdateRawModel(at index: Int)
}

protocol MVMarketUpdateChecking {
    
    func startCheckingForMarketUpdates()
    
    func stopCheckingForMarketUpdates()
}

protocol MVMarketWatchlistInteracting: MVMarketUpdateChecking {
    
    func isUserLoggedIn() -> Bool
    
    func loadMarkets(completion: @escaping (_ maketRawModels: [MVMarketRawModel]?) -> Void)
    
    func allMarketRawModels() -> [MVMarketRawModel]
}

final class MVMarketWatchlistInteractor: NSObject, MVMarketWatchlistInteracting {
    
    weak var delegate: MVMarketWatchlistInteractorDelegate?
    
    private let marketName = "Popular Markets"
    private let marketRequestFactory: MVMarketRequestCreating

    fileprivate let authTokenStore: MVAuthTokenStoring
    fileprivate let lightStreamerConfigurationStore: MVLightStreamerConfigurationStoring
    fileprivate let marketUpdateChecker: MVMarketLightStreaming
    fileprivate var marketRawModels = [MVMarketRawModel]()
    fileprivate let observedMarketFields: [String] = [MVMarketRawModel.Identifiers.buyPrice, MVMarketRawModel.Identifiers.sellPrice]
    
    init(marketRequestFactory: MVMarketRequestCreating,
         authTokenStore: MVAuthTokenStoring,
         lightStreamerConfigurationStore: MVLightStreamerConfigurationStoring,
         marketUpdateChecker: MVMarketLightStreaming) {
        
        self.marketRequestFactory = marketRequestFactory
        self.authTokenStore = authTokenStore
        self.lightStreamerConfigurationStore = lightStreamerConfigurationStore
        self.marketUpdateChecker = marketUpdateChecker
    }
    
    func isUserLoggedIn() -> Bool {
        return authTokenStore[.cst] != nil && authTokenStore[.xSecurity] != nil
    }
    
    func loadMarkets(completion: @escaping (_ maketRawModels: [MVMarketRawModel]?) -> Void) {
        
        guard let marketRequest = marketRequestFactory.makeMarketRequest(marketName: marketName) else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: marketRequest) { (data, urlResponse, error) in
            guard
                let data = data, error == nil,
                let marketsRawModel = try? JSONDecoder().decode(MVMarketsRawModel.self, from: data)
            else {
                completion(nil)
                return
            }
            
            self.marketRawModels = marketsRawModel.markets
            completion(self.marketRawModels)
        }.resume()
    }
    
    func allMarketRawModels() -> [MVMarketRawModel] {
        return marketRawModels
    }
}

extension MVMarketWatchlistInteractor: MVMarketUpdateChecking {
    
    func startCheckingForMarketUpdates() {
        
        guard !marketUpdateChecker.isStreaming() else { return }
        
        guard
            let endpoint = lightStreamerConfigurationStore[.endpoint],
            let accountId = lightStreamerConfigurationStore[.accountId],
            let cstToken = authTokenStore[.cst],
            let xSecurityToken = authTokenStore[.xSecurity]
        else { return }
            
        marketUpdateChecker.startStreaming(withEndpoint: endpoint,
                                               user: accountId,
                                               cst: cstToken,
                                               xst: xSecurityToken)
        
        marketRawModels.forEach { (marketRawModel) in
            guard let marketEpic = marketRawModel.epic else { return }
            marketUpdateChecker.observeMarket(withEpic: marketEpic,
                                             forFields: observedMarketFields,
                                             withDelegate: self)
        }
    }
    
    func stopCheckingForMarketUpdates() {
        marketUpdateChecker.stopStreaming()
    }
}

extension MVMarketWatchlistInteractor: LSSubscriptionDelegate {
    
    func subscription(_ subscription: LSSubscription, didUpdateItem itemUpdate: LSItemUpdate) {
        guard
            let epic = subscription.epic(),
            let marketRawModelUpdate = marketRawModels.enumerated().first(where: { $1.epic == epic })
        else { return }
        
        let updatedMarketRawModel = marketRawModelUpdate.element.marketRawModel(with: itemUpdate)
        marketRawModels[marketRawModelUpdate.offset] = updatedMarketRawModel
        delegate?.didUpdateRawModel(at: marketRawModelUpdate.offset)
    }
}

fileprivate extension MVMarketRawModel {
    
    func marketRawModel(with itemUpdate: LSItemUpdate) -> MVMarketRawModel {
        var needsUpdate = false
        var updatedBuyPrice = buyPrice
        if let buyPriceString = itemUpdate.changedFields[Identifiers.buyPrice] as? String {
            updatedBuyPrice = Double(buyPriceString)
            needsUpdate = true
        }
        
        var updatedSellPrice = sellPrice
        if let sellPriceString = itemUpdate.changedFields[Identifiers.sellPrice] as? String {
            updatedSellPrice = Double(sellPriceString)
            needsUpdate = true
        }
        
        guard needsUpdate else { return self }
        return MVMarketRawModel(instrumentName: instrumentName, epic: epic, buyPrice: updatedBuyPrice, sellPrice: updatedSellPrice)
    }
}

fileprivate struct MVMarketsRawModel: Codable {
    let markets: [MVMarketRawModel]
    
    private enum CodingKeys: String, CodingKey {
        case markets = "markets"
    }
}

fileprivate extension LSSubscription {
    
    func epic() -> String? {
        guard let identifier = items?.first as? String else { return nil }
        return identifier.components(separatedBy: "MARKET:").last
    }
}

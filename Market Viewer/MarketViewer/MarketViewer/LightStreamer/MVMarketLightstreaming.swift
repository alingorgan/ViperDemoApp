//
//  MVMarketLightstreaming.swift
//  MarketViewer
//
//  Created by Alin Gorgan on 12/08/2018.
//  Copyright © 2018 ACME. All rights reserved.
//

import Lightstreamer_iOS_Client

protocol MVMarketLightStreaming {
    
    /**
     This method will connect to Lightstreamer and initialise the system to observe markets.
     - Parameter endpoint: LIGHTSTREAMER URL. This information will be returned by the by the /session API response.
     - Parameter user: Client Account ID
     - Parameter cst: CST token
     - Parameter xst: XST token
     */
    func startStreaming(withEndpoint endpoint: String, user: String, cst: String, xst: String)
    
    
    /**
     This method will disconnect from Lightstreamer
     */
    func stopStreaming()
    
    
    /**
     This method is used to subscribe to market updates.
     - Parameter epic: a string that represents the market. See REST API documentation at https://labs.ig.com/rest-trading-api-guide
     - Parameter forFields: an array of properties to observe. You can find out about these fields in the API documentation at https://labs.ig.com/streaming-api-reference
     - Parameter withDelegate: Lightstreamer subscription delegate. Implement this delegate to get updates.
     - SeeAlso: /gateway/deal/markets/{watchlistId} response for epic
     */
    func observeMarket(withEpic epic: String, forFields fields: [String], withDelegate delegate: LSSubscriptionDelegate)
    
    
    /**
     This method is used to provide knowledge if the stream is enabled.
     Returns true if currently streaming, false otherwise
     */
    func isStreaming() -> Bool
}

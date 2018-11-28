//
//  MVMarketRawModel.swift
//  MarketViewer
//
//  Created by Alin Gorgan on 12/08/2018.
//  Copyright © 2018 ACME. All rights reserved.
//

import Foundation

struct MVMarketRawModel: Codable {
    let instrumentName: String?
    let epic: String?
    let buyPrice: Double?
    let sellPrice: Double?
    
    private enum CodingKeys: String, CodingKey {
        case instrumentName = "instrumentName"
        case epic = "epic"
        case buyPrice = "offer"
        case sellPrice = "bid"
    }
    
    struct Identifiers {
        static let buyPrice = "offer"
        static let sellPrice = "bid"
    }
}

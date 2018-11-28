//
//  MarketDetailsRawModel.swift
//  MarketViewer
//
//  Created by Alin Gorgan on 12/08/2018.
//  Copyright © 2018 ACME. All rights reserved.
//

import Foundation

struct MVMarketDetailsRawModel: Codable {
    
    struct MarginDeposit: Codable {
        let min: Double?
        let max: Double?
        let margin: Double?
        
        private enum CodingKeys: String, CodingKey {
            case min
            case max
            case margin
        }
    }
    
    let name: String?
    let expiry: String?
    let marginDepositBands: [MarginDeposit]
    let specialInfo: [String]
    
    private enum CodingKeys: String, CodingKey {
        case name
        case expiry
        case marginDepositBands
        case specialInfo
    }
}

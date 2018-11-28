//
//  MVMarketDetailsViewModel.swift
//  MarketViewer
//
//  Created by Alin Gorgan on 12/08/2018.
//  Copyright © 2018 ACME. All rights reserved.
//

import Foundation

struct MVMarketDetailsViewModel {
    
    struct Section<T> {
        let name: String
        let items: [T]
    }
    
    struct MarginDeposit {
        let title: String
        let range: String
    }
    
    let title: String?
    let marginDepositBands: Section<MarginDeposit>
    let specialInfo: Section<String>
}

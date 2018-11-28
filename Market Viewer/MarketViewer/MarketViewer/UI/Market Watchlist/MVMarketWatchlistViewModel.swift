//
//  MVMarketWatchlistViewModel.swift
//  MarketViewer
//
//  Created by Alin Gorgan on 12/08/2018.
//  Copyright © 2018 ACME. All rights reserved.
//

import Foundation

struct MVMarketViewModel {
    let marketName: String
    let buyPrice: String
    let sellPrice: String
}

struct MVMarketWatchlistViewModel {
    let items: [MVMarketViewModel]
}

//
//  MVLightStreamerConfigurationStore.swift
//  MarketViewer
//
//  Created by Alin Gorgan on 10/08/2018.
//  Copyright © 2018 ACME. All rights reserved.
//

import Foundation

enum LightStreamerConfigurationKey: Hashable {
    case endpoint
    case accountId
    
    var hasValue: Int {
        get {
            switch self {
            case .endpoint: return 0
            case .accountId: return 1
            }
        }
    }
}

protocol MVLightStreamerConfigurationStoring: class {
    
    subscript(key: LightStreamerConfigurationKey) -> String? { get set }
}

final class MVLightStreamerConfigurationStore: MVLightStreamerConfigurationStoring {
    
    private var configuration = [LightStreamerConfigurationKey: String]()
    
    subscript(key: LightStreamerConfigurationKey) -> String? {
        get {
            return configuration[key]
        }
        set {
            configuration[key] = newValue
        }
    }
}

//
//  MVMarketDetailsViewPresenter.swift
//  MarketViewer
//
//  Created by Alin Gorgan on 12/08/2018.
//  Copyright © 2018 ACME. All rights reserved.
//

import Foundation

protocol MVMarketDetailsViewPresenting {
    
    func viewIsReady()
}

final class MVMarketDetailsViewPresenter: MVMarketDetailsViewPresenting {
    
    private let router: MVRouting
    private unowned var view: MVMarketDetailsView
    private let interactor: MVMarketDetailsInteracting
    
    init(view: MVMarketDetailsView,
         interactor: MVMarketDetailsInteracting,
         router: MVRouting) {
        
        self.view = view
        self.interactor = interactor
        self.router = router
    }
    
    func viewIsReady() {
        interactor.loadMarketDetails { [weak self] (marketDetailsRawModel) in
            guard let `self` = self else { return }
            
            guard let marketDetailsRawModel = marketDetailsRawModel else {
                let title = "Oops"
                let message = "Unable to retrieve market information. Please try again later."
                self.router.close(view: self.view)
                self.router.navigateToAlertScreen(with: title, and: message)
                return
            }
            
            let marginDeposits = marketDetailsRawModel.marginDepositBands.map({ (marginDeposit) -> MVMarketDetailsViewModel.MarginDeposit in
                return MVMarketDetailsViewModel.MarginDeposit(marginDepositRawModel: marginDeposit)
            })
            let marginDepositsSection = MVMarketDetailsViewModel.Section<MVMarketDetailsViewModel.MarginDeposit>(
                name: "Margin Deposits",
                items: marginDeposits)
            
            let specialInfoSection = MVMarketDetailsViewModel.Section<String>(
                name: "Special Info",
                items: marketDetailsRawModel.specialInfo)
            
            DispatchQueue.main.async {
                self.view.viewModel = MVMarketDetailsViewModel(title: marketDetailsRawModel.title(),
                                                               marginDepositBands: marginDepositsSection,
                                                               specialInfo: specialInfoSection)
            }
        }
    }
}

fileprivate extension MVMarketDetailsViewModel.MarginDeposit {
    init(marginDepositRawModel: MVMarketDetailsRawModel.MarginDeposit) {
        
        let marginDescription = marginDepositRawModel.margin.displayableString(fallback: "undefined")
        let minDescription = marginDepositRawModel.min.displayableString(fallback: "undefined")
        let maxDescription = marginDepositRawModel.max.displayableString(fallback: "undefined")
        
        let title = "Margin \(marginDescription)"
        let subtitle = "Ranging from \(minDescription) to \(maxDescription)"
        self.init(title: title, range: subtitle)
    }
}

fileprivate extension Optional where Wrapped == Double  {
    
    func displayableString(fallback: String) -> String {
        guard let unwrapped = self else { return fallback }
        return String(describing: unwrapped)
    }
}

fileprivate extension MVMarketDetailsRawModel {
    
    func title() -> String {
        var title = ""
        if let name = name {
            title = name
        }
        
        if let expiry = expiry {
            title.append(" (\(expiry))")
        }
        
        return title
    }
    
}

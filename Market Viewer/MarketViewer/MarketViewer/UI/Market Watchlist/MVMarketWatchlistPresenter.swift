//
//  MVMarketWatchlistPresenter.swift
//  MarketViewer
//
//  Created by Alin Gorgan on 09/08/2018.
//  Copyright © 2018 ACME. All rights reserved.
//

import Foundation

protocol MVWatchlistPresenting {
    
    func view(isVisible: Bool)
    
    func didSelectItem(at index: Int)
    
    func scrollingMarketList(isScrolling: Bool)
}

final class MVMarketWatchlistPresenter: MVWatchlistPresenting {
    
    private let router: MVRouting
    
    fileprivate unowned var view: MVMarketWatchlistView
    fileprivate let interactor: MVMarketWatchlistInteracting
    fileprivate var marketViewModels = [MVMarketViewModel]()
    
    init(view: MVMarketWatchlistView, interactor: MVMarketWatchlistInteracting, router: MVRouting) {
        self.view = view
        self.interactor = interactor
        self.router = router
    }
    
    func view(isVisible: Bool) {
        
        guard isVisible else {
            interactor.stopCheckingForMarketUpdates()
            return
        }
        
        guard interactor.isUserLoggedIn() else {
            router.navigateToLogInScreen()
            return
        }
        
        interactor.loadMarkets { [weak self] (marketRawModels) in
            guard let `self` = self else { return }
            
            guard let marketRawModels = marketRawModels else {
                let title = "Oops"
                let message = "Unable to retrieve market information. Please try again later."
                self.router.navigateToAlertScreen(with: title, and: message)
                return
            }
            
            self.marketViewModels = marketRawModels.map { MVMarketViewModel(marketRawModel: $0) }.flatMap { $0 }
            
            DispatchQueue.main.async {
                self.view.viewModel = MVMarketWatchlistViewModel(items: self.marketViewModels)
                self.view.reloadMarketList()
            }
            
            self.interactor.startCheckingForMarketUpdates()
        }
    }
    
    func didSelectItem(at index: Int) {
        let selectedRawModel = interactor.allMarketRawModels()[index]
        guard let marketEpic = selectedRawModel.epic else { return }
        router.navigateToMarketDetailsScreen(with: marketEpic)
    }
    
    func scrollingMarketList(isScrolling: Bool) {
        isScrolling ? interactor.stopCheckingForMarketUpdates() : interactor.startCheckingForMarketUpdates()
    }
}

extension MVMarketWatchlistPresenter: MVMarketWatchlistInteractorDelegate {
    
    func didUpdateRawModel(at index: Int) {
        let rawModels = interactor.allMarketRawModels()
        let updatedRawModel = rawModels[index]
        
        guard let viewModel = MVMarketViewModel(marketRawModel: updatedRawModel) else { return }
        marketViewModels[index] = viewModel
        view.viewModel = MVMarketWatchlistViewModel(items: marketViewModels)
        
        DispatchQueue.main.async { [weak view] in
            view?.reloadMarketItem(at: index)
        }
    }
}

fileprivate extension MVMarketViewModel {
    
    init?(marketRawModel: MVMarketRawModel) {
        guard
            let marketName = marketRawModel.instrumentName,
            let buyPrice = marketRawModel.buyPrice,
            let sellPrice = marketRawModel.sellPrice
        else {
                // Skipping items which don't have enough information to maintain good UX.
                return nil
        }
        
        self.init(marketName: marketName,
                  buyPrice: String(describing: buyPrice),
                  sellPrice: String(describing: sellPrice))
    }
}

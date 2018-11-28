//
//  MVMarketWatchlistViewController.swift
//  MarketViewer
//
//  Copyright © 2017 ACME. All rights reserved.
//

import UIKit
import Lightstreamer_iOS_Client

protocol MVMarketWatchlistView: MVView {
    
    var viewModel: MVMarketWatchlistViewModel? { get set }
    
    func reloadMarketList()
    
    func reloadMarketItem(at index: Int)
}

final class MVMarketWatchlistViewController: UIViewController, MVMarketWatchlistView {
    
    @IBOutlet weak var tableView: UITableView!
    
    var presenter: MVWatchlistPresenting!
    
    var viewModel: MVMarketWatchlistViewModel? = nil
    var updatedViewModelIndexes = Set<Int>()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.view(isVisible: true)
        
        navigationItem.title = title
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        presenter.view(isVisible: false)
    }
    
    func reloadMarketList() {
        tableView.reloadData()
    }
    
    func reloadMarketItem(at index: Int) {
        guard
            let visibleRowIndexPaths = tableView.indexPathsForVisibleRows,
            visibleRowIndexPaths.contains(IndexPath(row: index, section: 0))
        else { return }
        
        updatedViewModelIndexes.insert(index)
        
        let indexPathToReload = IndexPath(row: index, section: 0)
        tableView.reloadRows(at: [indexPathToReload],
                             with: .none)
    }
}

extension MVMarketWatchlistViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.items.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MVMarketCell.cellIdentifier) as? MVMarketCell else {
            fatalError("No cell found with identifier \(MVMarketCell.cellIdentifier)")
        }
        
        let highlightChanges = updatedViewModelIndexes.contains(indexPath.row)
        updatedViewModelIndexes.remove(indexPath.row)
        
        cell.configure(with: viewModel!.items[indexPath.row], highlightingChanges: highlightChanges)
        
        return cell
    }
}

extension MVMarketWatchlistViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.didSelectItem(at: indexPath.row)
    }
}


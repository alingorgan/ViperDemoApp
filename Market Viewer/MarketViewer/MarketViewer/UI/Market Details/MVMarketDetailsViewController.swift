//
//  MVMarketDetailsViewController.swift
//  MarketViewer
//
//  Created by Alin Gorgan on 12/08/2018.
//  Copyright © 2018 ACME. All rights reserved.
//

import UIKit

protocol MVMarketDetailsView: MVView {
    
    var viewModel: MVMarketDetailsViewModel? { get set }
    
}

final class MVMarketDetailsViewController: UIViewController, MVMarketDetailsView {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var marketNameLabel: UILabel!
    
    var presenter: MVMarketDetailsViewPresenting!
    var viewModel: MVMarketDetailsViewModel? {
        didSet {
            marketNameLabel.text = viewModel?.title
            tableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        presenter.viewIsReady()
    }
}

extension MVMarketDetailsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return viewModel?.marginDepositBands.name ?? nil
        case 1: return viewModel?.specialInfo.name ?? nil
        default: return nil
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return viewModel?.marginDepositBands.items.count ?? 0
        case 1: return viewModel?.specialInfo.items.count ?? 0
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: UITableViewCell
        switch indexPath.section {
        case 0:
            let cellIdentifier = MVMarketDetailDepositMarginCell.cellIdentifier
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)!
            let merginDeposit = viewModel!.marginDepositBands.items[indexPath.row]
            (cell as? MVMarketDetailDepositMarginCell)?.configure(marginDeposit: merginDeposit)
        case 1:
            let cellIdentifier = MVMarketDetailSpecialInfoCell.cellIdentifier
            cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)!
            let specialInfo = viewModel!.specialInfo.items[indexPath.row]
            (cell as? MVMarketDetailSpecialInfoCell)?.configure(specialInfo: specialInfo)
        default:
            fatalError("Unexpected index path")
        }
        
        return cell
    }
}

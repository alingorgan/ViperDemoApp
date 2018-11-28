//
//  MVMarketDetailDepositMarginCell.swift
//  MarketViewer
//
//  Created by Alin Gorgan on 12/08/2018.
//  Copyright © 2018 ACME. All rights reserved.
//

import UIKit

final class MVMarketDetailDepositMarginCell: UITableViewCell {
    
    static let cellIdentifier = "MVMarketDetailDepositMarginCell"
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    func configure(marginDeposit: MVMarketDetailsViewModel.MarginDeposit) {
        titleLabel.text = marginDeposit.title
        subtitleLabel.text = marginDeposit.range
    }
}

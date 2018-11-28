//
//  MVMarketCell.swift
//  MarketViewer
//
//  Created by Alin Gorgan on 12/08/2018.
//  Copyright © 2018 ACME. All rights reserved.
//

import UIKit

final class MVMarketCell: UITableViewCell {
    
    static let cellIdentifier = "MarketCell"
    
    @IBOutlet weak var marketCellLabel: UILabel!
    @IBOutlet weak var buyLabel: UILabel!
    @IBOutlet weak var buyAmountLabel: UILabel!
    @IBOutlet weak var sellLabel: UILabel!
    @IBOutlet weak var sellAmountLabel: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        marketCellLabel.textColor = .black
        buyAmountLabel.textColor = .black
        sellAmountLabel.textColor = .black
        
    }
    
    func configure(with viewModel: MVMarketViewModel, highlightingChanges: Bool) {
        marketCellLabel.text = viewModel.marketName
        buyAmountLabel.setText(viewModel.buyPrice, animated: highlightingChanges)
        sellAmountLabel.setText(viewModel.sellPrice, animated: highlightingChanges)
    }
}

fileprivate extension UILabel {
    
    func setText(_ newValue: String?, animated: Bool) {
        guard newValue != text && animated else {
            text = newValue
            return
        }
        
        self.text = newValue
        self.textColor = .red
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) { [weak self] in
            self?.textColor = .black
        }
        
    }
    
}

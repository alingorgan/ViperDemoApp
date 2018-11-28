//
//  MVMarketDetailSpecialInfoCell.swift
//  MarketViewer
//
//  Created by Alin Gorgan on 12/08/2018.
//  Copyright © 2018 ACME. All rights reserved.
//

import UIKit

final class MVMarketDetailSpecialInfoCell: UITableViewCell {
    
    static let cellIdentifier = "MVMarketDetailSpecialInfoCell"
    
    @IBOutlet weak var titleLabel: UILabel!
    
    func configure(specialInfo: String?) {
        titleLabel.text = specialInfo
    }
}

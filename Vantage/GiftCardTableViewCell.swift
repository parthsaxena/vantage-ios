//
//  GiftCardTableViewCell.swift
//  Vantage
//
//  Created by Parth Saxena on 10/29/16.
//  Copyright © 2016 Socify. All rights reserved.
//

import UIKit

class GiftCardTableViewCell: UITableViewCell {

    @IBOutlet weak var keyLabel: UILabel!
    @IBOutlet weak var availableLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

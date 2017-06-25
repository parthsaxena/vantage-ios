//
//  CellSubjectTableViewCell.swift
//  Vantage
//
//  Created by Sahil Anand on 6/25/17.
//  Copyright © 2017 Socify. All rights reserved.
//

import UIKit

class CellSubjectTableViewCell: UITableViewCell {

    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var inquiriesCountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

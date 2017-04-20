//
//  InquiryTableViewCell.swift
//  Vantage
//
//  Created by Parth Saxena on 7/11/16.
//  Copyright © 2016 Socify. All rights reserved.
//

import UIKit

class InquiryTableViewCell: UITableViewCell {

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var answersLabel: UILabel?
    @IBOutlet weak var coinsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell() {
        self.usernameLabel.alpha = 0
        self.dateLabel.alpha = 0
        self.titleLabel.alpha = 0
        if (self.coinsLabel != nil) {
            self.coinsLabel.alpha = 0
        }
        if (self.answersLabel != nil) {
            self.answersLabel?.alpha = 0
        }
        
        UIView.animate(withDuration: 0.4, animations: { 
            self.usernameLabel.alpha = 1
            self.dateLabel.alpha = 1
            self.titleLabel.alpha = 1
            if (self.coinsLabel != nil) {
                self.coinsLabel.alpha = 1
            }
            if (self.answersLabel != nil) {
                self.answersLabel?.alpha = 1
            }
        }) 
    }

}

//
//  AnswerTableViewCell.swift
//  Vantage
//
//  Created by Parth Saxena on 7/27/16.
//  Copyright © 2016 Socify. All rights reserved.
//

import UIKit

class AnswerTableViewCell: UITableViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var answerImageView: ImageScrollView!
    @IBOutlet weak var answerTextView: UITextView!    
    @IBOutlet weak var rejectButton: UIButton!
    @IBOutlet weak var acceptButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell() {
        self.dateLabel.alpha = 0
        self.answerImageView.alpha = 0
        self.answerTextView.alpha = 0
        self.rejectButton.alpha = 0
        self.acceptButton.alpha = 0
        UIView.animate(withDuration: 0.4, animations: { 
            self.dateLabel.alpha = 1
            self.answerImageView.alpha = 1
            self.answerTextView.alpha = 1
            self.rejectButton.alpha = 1
            self.acceptButton.alpha = 1
        }) 
    }

}

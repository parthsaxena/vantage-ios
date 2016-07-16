//
//  ViewInquiryTableViewCell.swift
//  Vantage
//
//  Created by Parth Saxena on 7/11/16.
//  Copyright © 2016 Socify. All rights reserved.
//

import UIKit
import Firebase

class ViewInquiryTableViewCell: UITableViewCell {

    @IBOutlet weak var inquiryIDLabel: UILabel!
    @IBOutlet weak var inquiryImage: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configureCell(image: String) {
        let imageRef = FIRStorage.storage().referenceForURL("gs://vantage-e9003.appspot.com").child("images/\(image).jpg")
        imageRef.dataWithMaxSize(5 * 1024 * 1024) { (data, error) -> Void in
            if error == nil {
                let image = UIImage(data: data!)
                self.inquiryImage.image = image                
                
                self.inquiryIDLabel.alpha = 0
                self.dateLabel.alpha = 0
                self.titleLabel.alpha = 0
                self.inquiryImage.alpha = 0
                self.contentTextView.alpha = 0
                
                UIView.animateWithDuration(0.4) {
                    self.inquiryIDLabel.alpha = 1
                    self.dateLabel.alpha = 1
                    self.titleLabel.alpha = 1
                    self.inquiryImage.alpha = 1
                    self.contentTextView.alpha = 1
                }
            } else {
                // error
                NSLog("Error while downloading an image.")
            }
        }
    }
    
}

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

    @IBOutlet weak var chatButtonImageView: UIImageView!
    @IBOutlet weak var chatButton: UIButton!
    @IBOutlet weak var inquiryIDLabel: UILabel!
    @IBOutlet weak var inquiryImage: ImageScrollView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var titleLabel: UILabel!    
    @IBOutlet weak var answerButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configureCell(_ image: String) {
        let imageRef = FIRStorage.storage().reference(forURL: "gs://vantage-e9003.appspot.com").child("images/\(image).jpg")
        imageRef.data(withMaxSize: 5 * 1024 * 1024) { (data, error) -> Void in
            if error == nil {
                let image = UIImage(data: data!)
                self.inquiryImage.displayImage(image!)
                
                self.inquiryIDLabel.alpha = 0
                self.dateLabel.alpha = 0
                self.titleLabel.alpha = 0
                self.inquiryImage.alpha = 0
                self.contentTextView.alpha = 0
                self.answerButton.alpha = 0
                self.chatButton.alpha = 0
                self.chatButtonImageView.alpha = 0
                
                UIView.animate(withDuration: 0.4, animations: {
                    self.inquiryIDLabel.alpha = 1
                    self.dateLabel.alpha = 1
                    self.titleLabel.alpha = 1
                    self.inquiryImage.alpha = 1
                    self.contentTextView.alpha = 1
                    self.answerButton.alpha = 1
                    self.chatButton.alpha = 1
                    self.chatButtonImageView.alpha = 1
                })                 
            } else {
                // error
                NSLog("Error while downloading an image.")
            }
        }
    }
    
}

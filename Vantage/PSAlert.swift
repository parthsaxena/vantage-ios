//
//  PSAlert.swift
//  Vantage
//
//  Created by Parth Saxena on 6/30/16.
//  Copyright © 2016 Socify. All rights reserved.
//

import Foundation
import UIKit

class PSAlert {
    static let sharedInstance = PSAlert()
    
    func instantiateAlert(_ type: String, alertText: String) -> UIAlertController {
        if type == "Success" {
            // success alert
            let alertController = UIAlertController(title: "Success", message: alertText, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            return alertController
        } else if(type == "Error") {
            // error alert
            let alertController = UIAlertController(title: "Error", message: alertText, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            return alertController
        }
        return UIAlertController()
    }
    
}

//
//  FourthStageViewController.swift
//  Vantage
//
//  Created by Parth Saxena on 9/24/16.
//  Copyright © 2016 Socify. All rights reserved.
//

import UIKit

class FourthStageViewController: UIViewController {

    @IBOutlet weak var vantageLogo: UIImageView!
    @IBOutlet weak var welcomeToVantage: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var nextButton: UIButton!
    
    var oldYCoord: CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        oldYCoord = nextButton.center.y
        
        vantageLogo.alpha = 0
        
        welcomeToVantage.alpha = 0
        welcomeToVantage.center.x = 10
        
        descriptionTextView.alpha = 0
        descriptionTextView.center.x = 10
        
        nextButton.alpha = 0
        nextButton.center.x = self.view.frame.width / 2
        nextButton.center.y = self.view.frame.height - 10
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        startAnimation()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func startAnimation() {
        UIView.animateWithDuration(1.0, animations: {
            self.vantageLogo.alpha = 1
            }, completion: { (success: Bool) in
                UIView.animateWithDuration(1.0, animations: {
                    self.welcomeToVantage.alpha = 1
                    self.welcomeToVantage.center.x = self.view.frame.width / 2
                    self.descriptionTextView.alpha = 1
                    self.descriptionTextView.center.x = self.view.frame.width / 2
                    }, completion: { (success: Bool) in
                        UIView.animateWithDuration(1.0, animations: {
                            self.nextButton.alpha = 1
                            self.nextButton.center.y = self.oldYCoord
                            }, completion: nil)
                })
        })
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */

}

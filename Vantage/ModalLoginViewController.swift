//
//  ModalSignUpViewController.swift
//  Vantage
//
//  Created by Parth Saxena on 7/25/16.
//  Copyright © 2016 Socify. All rights reserved.
//

import UIKit
import Firebase

class ModalLoginViewController: UIViewController {
    
    @IBOutlet weak var emailField: HoshiTextField!
    @IBOutlet weak var passwordField: HoshiTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clearColor()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func close(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func signInTapped(sender: AnyObject) {
        let email = emailField.text!
        let password = passwordField.text!
        
        FIRAuth.auth()?.signInWithEmail(email, password: password, completion: { (user, error) in
            if error == nil {
                // success
                NSLog("Logged in.")
                /*let alert = PSAlert.sharedInstance.instantiateAlert("Success", alertText: "Logged in!")
                 self.presentViewController(alert, animated: true, completion: nil)*/
                let vc = self.storyboard?.instantiateViewControllerWithIdentifier("mainVC")
                self.presentViewController(vc!, animated: false, completion: nil)
            } else {
                // error
                NSLog("Error logging in.")
                let alert = PSAlert.sharedInstance.instantiateAlert("Error", alertText: "There was an error logging you in.")
                self.presentViewController(alert, animated: true, completion: nil)
            }
        })
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

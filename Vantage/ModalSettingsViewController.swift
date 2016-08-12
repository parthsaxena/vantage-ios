//
//  ModalSignUpViewController.swift
//  Vantage
//
//  Created by Parth Saxena on 7/25/16.
//  Copyright © 2016 Socify. All rights reserved.
//

import UIKit
import Firebase

class ModalSettingsViewController: UIViewController {
    
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
    
    @IBAction func addPaymentTapped(sender: AnyObject) {
        let alert = UIAlertController(title: "Notice", message: "Payments will be introduced in the next version of Vantage. Sorry for any inconvenience.", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func contactSupportTapped(sender: AnyObject) {
        let alert = UIAlertController(title: "Contact Support", message: "Need help? Feel free to email support@socifyinc.com or call (925)-998-2624 with whatever question you may have.", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func resetPasswordTapped(sender: AnyObject) {
        let email = FIRAuth.auth()?.currentUser?.email!
        
        let alert = UIAlertController(title: "Reset Password", message: "You will receive an email with instructions to reset your password. Are you sure you would like to continue?", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Continue", style: .Default, handler: { (action) in
            FIRAuth.auth()?.sendPasswordResetWithEmail(email!, completion: { (error) in
                if error == nil {
                    let alert = UIAlertController(title: "Success", message: "Instructions on how to reset your password have been sent to your email.", preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: { (action) in
                        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("homeVC")
                        self.presentViewController(vc!, animated: false, completion: nil)
                    }))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            })
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func logOutTapped(sender: AnyObject) {
        do {
            try FIRAuth.auth()?.signOut()
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("homeVC")
            self.presentViewController(vc!, animated: false, completion: nil)
        } catch {
            let alert = PSAlert.sharedInstance.instantiateAlert("Error", alertText: "There was an error logging you out.")
            self.presentViewController(alert, animated: true, completion: nil)
        }
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

//
//  FirstActionViewController.swift
//  Vantage
//
//  Created by Parth Saxena on 7/25/16.
//  Copyright © 2016 Socify. All rights reserved.
//

import UIKit
import Firebase

class FirstActionViewController: UIViewController {

    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    @IBOutlet var loginView: UIView!
    @IBOutlet var signupView: UIView!
    
    // login elements
    @IBOutlet weak var loginEmailField: HoshiTextField!
    @IBOutlet weak var loginPasswordField: HoshiTextField!
    @IBOutlet weak var signInButton: UIButton!
    
    // sign-up elements
    @IBOutlet weak var signupEmailField: HoshiTextField!
    @IBOutlet weak var signupPasswordField: HoshiTextField!
    @IBOutlet weak var signUpButton: UIButton!

    var effect: UIVisualEffect!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        effect = visualEffectView.effect
        visualEffectView.effect = nil
        self.view.sendSubviewToBack(visualEffectView)
        
        loginView.layer.cornerRadius = 5
        signupView.layer.cornerRadius = 5
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func exitLoginTapped(sender: AnyObject) {
        animateLoginOut()
    }
    
    func animateLoginIn() {
        self.view.addSubview(loginView)
        loginView.center = self.view.center
        
        loginView.transform = CGAffineTransformMakeScale(1.3, 1.3)
        loginView.alpha = 0
        self.view.bringSubviewToFront(visualEffectView)
        self.view.bringSubviewToFront(loginView)
        UIView.animateWithDuration(0.4) { 
            self.visualEffectView.effect = self.effect
            self.loginView.alpha = 1
            self.loginView.transform = CGAffineTransformIdentity
        }
    }
    
    func animateLoginOut() {
        UIView.animateWithDuration(0.3, animations: { 
            self.loginView.transform = CGAffineTransformMakeScale(1.3, 1.3)
            self.loginView.alpha = 0
            
            self.visualEffectView.effect = nil
            
        }) { (success: Bool) in
                self.loginView.removeFromSuperview()
            self.view.sendSubviewToBack(self.visualEffectView)
        }
    }
    
    func animateSignupIn() {
        self.view.addSubview(signupView)
        signupView.center = self.view.center
        
        signupView.transform = CGAffineTransformMakeScale(1.3, 1.3)
        signupView.alpha = 0
        self.view.bringSubviewToFront(visualEffectView)
        self.view.bringSubviewToFront(signupView)
        UIView.animateWithDuration(0.4) {
            self.visualEffectView.effect = self.effect
            self.signupView.alpha = 1
            self.signupView.transform = CGAffineTransformIdentity
        }
    }
    
    func animateSignupOut() {
        UIView.animateWithDuration(0.3, animations: {
            self.signupView.transform = CGAffineTransformMakeScale(1.3, 1.3)
            self.signupView.alpha = 0
            
            self.visualEffectView.effect = nil
            
        }) { (success: Bool) in
            self.signupView.removeFromSuperview()
            self.view.sendSubviewToBack(self.visualEffectView)
        }
    }
    
    @IBAction func signupTapped(sender: AnyObject) {
        animateSignupIn()
    }
    
    @IBAction func exitSignupTapped(sender: AnyObject) {
        animateSignupOut()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        if (NSUserDefaults.standardUserDefaults().boolForKey("HasLaunchedOnce")) {
            // app has been launched before
            
            NSLog("The app has been run before.")
            
        } else {
            // first launch
            
            NSLog("This is the first launch.")
            
            NSUserDefaults.standardUserDefaults().setBool(true, forKey:"HasLaunchedOnce")
            NSUserDefaults.standardUserDefaults().synchronize()
            
            let alert = UIAlertController(title: "Notifications", message: "Many features will not be available without enabling notifications. Would you like to enable notifications?", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { (action) in
                OneSignal.registerForPushNotifications()
                //OneSignal.enableInAppAlertNotification(true)
            }))
            alert.addAction(UIAlertAction(title: "No", style: .Cancel, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }

    @IBAction func loginTapped(sender: AnyObject) {
        animateLoginIn()
    }
    
    @IBAction func viewLoginTapped(sender: AnyObject) {
        let email = loginEmailField.text!
        let password = loginPasswordField.text!
        
        self.signInButton.setTitle("Loading...", forState: .Normal)
        
        FIRAuth.auth()?.signInWithEmail(email, password: password, completion: { (user, error) in
            if error == nil {
                // success
                NSLog("Logged in.")
                let vc = self.storyboard?.instantiateViewControllerWithIdentifier("mainVC")
                self.presentViewController(vc!, animated: false, completion: nil)
            } else {
                // error
                NSLog("Error logging in.")
                if error?.localizedDescription == "An internal error has occurred, print and inspect the error details for more information." {
                    let alert = PSAlert.sharedInstance.instantiateAlert("Error", alertText: "There was an error logging you in.")
                    self.presentViewController(alert, animated: true, completion: nil)
                } else {
                    let alert = PSAlert.sharedInstance.instantiateAlert("Error", alertText: (error?.localizedDescription)!)
                    self.presentViewController(alert, animated: true, completion: nil)
                }
                self.signInButton.setTitle("Sign In >", forState: .Normal)
                let alert = PSAlert.sharedInstance.instantiateAlert("Error", alertText: (error?.localizedDescription)!)
                self.presentViewController(alert, animated: true, completion: nil)
            }
        })
    }
    
    @IBAction func viewSignupTapped(sender: AnyObject) {
        let email = signupEmailField.text!
        let password = signupPasswordField.text!
        
        self.view.endEditing(true)
        signUpButton.setTitle("Loading...", forState: .Normal)
        
        FIRAuth.auth()?.createUserWithEmail(email, password: password, completion: { (user, error) in
            if error == nil {
                // success
                /*let alert = PSAlert.sharedInstance.instantiateAlert("Success", alertText: "Successfully created account!")
                 self.presentViewController(alert, animated: true, completion: nil)*/
                let uid = FIRAuth.auth()?.currentUser?.uid
                let newUserRef = FIRDatabase.database().reference().child("users").child(uid!)
                let newUser = [
                    "email": email,
                    "username": email,
                    "chats": "",
                    "notification_id": ""
                ]
                newUserRef.setValue(newUser)
                let vc = self.storyboard?.instantiateViewControllerWithIdentifier("tutorialVC")
                //self.dismissViewControllerAnimated(true, completion: nil)
                self.presentViewController(vc!, animated: false, completion: nil)
            } else {
                // error
                self.signUpButton.setTitle("Get Started >", forState: .Normal)
                if error?.localizedDescription == "An internal error has occurred, print and inspect the error details for more information." {
                    let alert = PSAlert.sharedInstance.instantiateAlert("Error", alertText: "There was an error creating your account.")
                    self.presentViewController(alert, animated: true, completion: nil)
                } else {
                    let alert = PSAlert.sharedInstance.instantiateAlert("Error", alertText: (error?.localizedDescription)!)
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
        })

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signUpWithEmailTapped(sender: AnyObject) {
        //showModal()
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

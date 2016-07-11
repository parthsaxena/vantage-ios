//
//  ViewController.swift
//  Vantage
//
//  Created by Parth Saxena on 6/30/16.
//  Copyright © 2016 Socify. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController {

    @IBOutlet var usernameField: HoshiTextField!
    @IBOutlet var passwordField: HoshiTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.  
        /*do {
            try FIRAuth.auth()?.signOut()
        } catch {
            NSLog("Error while signing out user.")
        }*/
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.errorLoadingPosts(_:)), name:"errorLoadingPosts", object: nil)
    }
    
    func errorLoadingPosts(notification: NSNotification) {
        let alert = PSAlert.sharedInstance.instantiateAlert("Error", alertText: "Something went wrong... Please try again later.")
        self.presentViewController(alert, animated: false, completion: nil)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        if FIRAuth.auth()?.currentUser == nil {
            // do nothing
        } else {
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("mainVC")
            self.presentViewController(vc!, animated: false, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func logInTapped(sender: AnyObject) {
        // log in tapped
        let username = usernameField.text!
        let password = passwordField.text!
        
        logIn(username, password: password)
    }

    func logIn(username: String, password: String) {
        FIRAuth.auth()?.signInWithEmail(username, password: password, completion: { (user, error) in
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
    
}


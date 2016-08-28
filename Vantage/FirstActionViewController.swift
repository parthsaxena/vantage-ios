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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
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
                OneSignal.defaultClient().registerForPushNotifications()
                OneSignal.defaultClient().enableInAppAlertNotification(true)
            }))
            alert.addAction(UIAlertAction(title: "No", style: .Cancel, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signUpWithEmailTapped(sender: AnyObject) {
        //showModal()
    }
    
    func showModal() {
        print("presenting sign-up modal")
        let modalViewController = ModalSignUpViewController()
        modalViewController.modalPresentationStyle = .OverCurrentContext
        presentViewController(modalViewController, animated: true, completion: nil)
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

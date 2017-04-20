//
//  ViewController.swift
//  Vantage
//
//  Created by Parth Saxena on 6/30/16.
//  Copyright © 2016 Socify. All rights reserved.
//

import UIKit
import Firebase
import TextFieldEffects

class ViewController: UIViewController, UITextFieldDelegate {

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
        
        self.usernameField.delegate = self
        self.passwordField.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.errorLoadingPosts(_:)), name:NSNotification.Name(rawValue: "errorLoadingPosts"), object: nil)
    }
    
    func keyboardWillHide(_ notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            self.view.frame.origin.y -= keyboardSize.height
        }
    }
    
    func keyboardWillShow(_ notification: Notification) {
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func errorLoadingPosts(_ notification: Notification) {
        let alert = PSAlert.sharedInstance.instantiateAlert("Error", alertText: "Something went wrong... Please try again later.")
        self.present(alert, animated: false, completion: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if FIRAuth.auth()?.currentUser == nil {
            // do nothing
        } else {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "mainVC")
            self.present(vc!, animated: false, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func logInTapped(_ sender: AnyObject) {
        // log in tapped
        let username = usernameField.text!
        let password = passwordField.text!
        
        logIn(username, password: password)
    }

    func logIn(_ username: String, password: String) {
        FIRAuth.auth()?.signIn(withEmail: username, password: password, completion: { (user, error) in
            if error == nil {
                // success
                NSLog("Logged in.")
                /*let alert = PSAlert.sharedInstance.instantiateAlert("Success", alertText: "Logged in!")
                self.presentViewController(alert, animated: true, completion: nil)*/
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "mainVC")
                self.present(vc!, animated: false, completion: nil)
            } else {
                // error
                NSLog("Error logging in.")
                let alert = PSAlert.sharedInstance.instantiateAlert("Error", alertText: (error?.localizedDescription)!)
                self.present(alert, animated: true, completion: nil)
            }
        })
    }        
    
}


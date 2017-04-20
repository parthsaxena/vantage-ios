//
//  ModalSignUpViewController.swift
//  Vantage
//
//  Created by Parth Saxena on 7/25/16.
//  Copyright © 2016 Socify. All rights reserved.
//

import UIKit
import Firebase
import TextFieldEffects

class ModalLoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailField: HoshiTextField!
    @IBOutlet weak var passwordField: HoshiTextField!
    
    @IBOutlet weak var signInButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(ModalLoginViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ModalLoginViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        emailField.delegate = self
        passwordField.delegate = self
        view.backgroundColor = UIColor.clear
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func close(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func signInTapped(_ sender: AnyObject) {
        let email = emailField.text!
        let password = passwordField.text!
        
        self.view.endEditing(true)
        self.signInButton.setTitle("Loading...", for: UIControlState())
        
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
            if error == nil {
                // success
                NSLog("Logged in.")
                /*let alert = PSAlert.sharedInstance.instantiateAlert("Success", alertText: "Logged in!")
                 self.presentViewController(alert, animated: true, completion: nil)*/               
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "mainVC")
                self.present(vc!, animated: false, completion: nil)
            } else {
                // error
                self.signInButton.setTitle("Sign In >", for: UIControlState())
                NSLog("Error logging in.")
                if error?.localizedDescription == "An internal error has occurred, print and inspect the error details for more information." {
                    let alert = PSAlert.sharedInstance.instantiateAlert("Error", alertText: "There was an error logging you in.")
                    self.present(alert, animated: true, completion: nil)
                } else {
                    let alert = PSAlert.sharedInstance.instantiateAlert("Error", alertText: (error?.localizedDescription)!)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        })
    }
    
    func signIn() {
        let email = emailField.text!
        let password = passwordField.text!
        
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
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
                self.signInButton.setTitle("Sign In >", for: UIControlState())
                let alert = PSAlert.sharedInstance.instantiateAlert("Error", alertText: (error?.localizedDescription)!)
                self.present(alert, animated: true, completion: nil)
            }
        })
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.emailField {
            self.passwordField.becomeFirstResponder()
        } else {
            self.view.endEditing(true)
            self.signInButton.setTitle("Loading...", for: UIControlState())
            signIn()
        }
        
        return true
    }
    
    func keyboardWillShow(_ notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0 {
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }
    
    func keyboardWillHide(_ notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0 {
                self.view.frame.origin.y += keyboardSize.height
            }
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

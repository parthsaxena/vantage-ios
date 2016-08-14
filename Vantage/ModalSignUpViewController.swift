//
//  ModalSignUpViewController.swift
//  Vantage
//
//  Created by Parth Saxena on 7/25/16.
//  Copyright © 2016 Socify. All rights reserved.
//

import UIKit
import Firebase

class ModalSignUpViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailField: HoshiTextField!
    @IBOutlet weak var passwordField: HoshiTextField!
    @IBOutlet weak var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailField.delegate = self
        passwordField.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func close(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func signUpTapped(sender: AnyObject) {
        let email = emailField.text!
        let password = passwordField.text!
        
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
                    "chats": ""
                ]
                newUserRef.setValue(newUser)
                let vc = self.storyboard?.instantiateViewControllerWithIdentifier("tutorialVC")
                //self.dismissViewControllerAnimated(true, completion: nil)
                self.presentViewController(vc!, animated: false, completion: nil)
            } else {
                // error
                self.signUpButton.setTitle("Get started >", forState: .Normal)
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
    
    func signUp() {
        let email = emailField.text!
        let password = passwordField.text!
        
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
                    "chats": ""
                ]
                newUserRef.setValue(newUser)
                let vc = self.storyboard?.instantiateViewControllerWithIdentifier("tutorialVC")
                //self.dismissViewControllerAnimated(true, completion: nil)
                self.presentViewController(vc!, animated: false, completion: nil)
            } else {
                // error
                self.signUpButton.setTitle("Get started >", forState: .Normal)
                let alert = PSAlert.sharedInstance.instantiateAlert("Error", alertText: (error?.localizedDescription)!)
                self.presentViewController(alert, animated: true, completion: nil)
            }
        })
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == self.emailField {
            self.passwordField.becomeFirstResponder()
        } else {
            self.view.endEditing(true)
            self.signUpButton.setTitle("Get started >", forState: .Normal)
            signUp()
        }
        return true
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

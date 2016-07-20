//
//  SignUpViewController.swift
//  
//
//  Created by Parth Saxena on 6/30/16.
//
//

import UIKit
import Firebase

class SignUpViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var usernameField: HoshiTextField!
    @IBOutlet var emailField: HoshiTextField!
    @IBOutlet var passwordField: HoshiTextField!
    @IBOutlet weak var schoolField: HoshiTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        usernameField.delegate = self
        emailField.delegate = self
        passwordField.delegate = self
        schoolField.delegate = self
        
        // Do any additional setup after loading the view.
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signUpTapped(sender: AnyObject) {
        let email = emailField.text!
        let password = passwordField.text!
        
        signUp(email, password: password)
    }
    
    func signUp(email: String, password: String) {
        FIRAuth.auth()?.createUserWithEmail(email, password: password, completion: { (user, error) in
            if error == nil {
                // success
                /*let alert = PSAlert.sharedInstance.instantiateAlert("Success", alertText: "Successfully created account!")
                self.presentViewController(alert, animated: true, completion: nil)*/
                let uid = FIRAuth.auth()?.currentUser?.uid
                let newUserRef = FIRDatabase.database().reference().child("users").child(uid!)
                let newUser = [
                    "email": email,
                    "school": "Harvest Park Middle School",
                    "username": email,
                    "chats": ""
                ]
                newUserRef.setValue(newUser)
                let vc = self.storyboard?.instantiateViewControllerWithIdentifier("mainVC")
                self.presentViewController(vc!, animated: false, completion: nil)
            } else {
                // error
                let alert = PSAlert.sharedInstance.instantiateAlert("Error", alertText: "There was an error while created account!")
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

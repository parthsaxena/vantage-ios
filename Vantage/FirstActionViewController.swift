//
//  FirstActionViewController.swift
//  Vantage
//
//  Created by Parth Saxena on 7/25/16.
//  Copyright © 2016 Socify. All rights reserved.
//

import UIKit
import Firebase
import Onboard
import TextFieldEffects

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
        
        //NotificationCenter.default.addObserver(self, selector: Selector("keyboardWillShow:"), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        //NotificationCenter.default.addObserver(self, selector: Selector("keyboardWillHide:"), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        effect = visualEffectView.effect
        visualEffectView.effect = nil
        self.view.sendSubview(toBack: visualEffectView)
        
        loginView.layer.cornerRadius = 5
        signupView.layer.cornerRadius = 5
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func exitLoginTapped(_ sender: AnyObject) {
        animateLoginOut()
    }
    
    func animateLoginIn() {
        self.view.addSubview(loginView)
        loginView.center = self.view.center
        
        loginView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        loginView.alpha = 0
        self.view.bringSubview(toFront: visualEffectView)
        self.view.bringSubview(toFront: loginView)
        UIView.animate(withDuration: 0.4, animations: { 
            self.visualEffectView.effect = self.effect
            self.loginView.alpha = 1
            self.loginView.transform = CGAffineTransform.identity
        }) 
    }
    
    func animateLoginOut() {
        UIView.animate(withDuration: 0.3, animations: { 
            self.loginView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.loginView.alpha = 0
            
            self.visualEffectView.effect = nil
            
        }, completion: { (success: Bool) in
                self.loginView.removeFromSuperview()
            self.view.sendSubview(toBack: self.visualEffectView)
        }) 
    }
    
    func animateSignupIn() {
        self.view.addSubview(signupView)
        signupView.center = self.view.center
        
        signupView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        signupView.alpha = 0
        self.view.bringSubview(toFront: visualEffectView)
        self.view.bringSubview(toFront: signupView)
        UIView.animate(withDuration: 0.4, animations: {
            self.visualEffectView.effect = self.effect
            self.signupView.alpha = 1
            self.signupView.transform = CGAffineTransform.identity
        }) 
    }
    
    func animateSignupOut() {
        UIView.animate(withDuration: 0.3, animations: {
            self.signupView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.signupView.alpha = 0
            
            self.visualEffectView.effect = nil
            
        }, completion: { (success: Bool) in
            self.signupView.removeFromSuperview()
            self.view.sendSubview(toBack: self.visualEffectView)
        }) 
    }
    
    @IBAction func signupTapped(_ sender: AnyObject) {
        animateSignupIn()
    }
    
    @IBAction func exitSignupTapped(_ sender: AnyObject) {
        animateSignupOut()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        if (UserDefaults.standard.bool(forKey: "HasLaunchedOnce")) {
            // app has been launched before
            
            NSLog("The app has been run before.")
            
        } else {
            // first launch
            
            NSLog("This is the first launch.")
            
            UserDefaults.standard.set(true, forKey:"HasLaunchedOnce")
            UserDefaults.standard.synchronize()
            
            let alert = UIAlertController(title: "Notifications", message: "Many features will not be available without enabling notifications. Please enable notifications if you have not already.", preferredStyle: .alert)
            /*alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                //OneSignal.registerForPushNotifications()
                OneSignal.promptForPushNotifications(userResponse: nil)
                //OneSignal.enableInAppAlertNotification(true)
            }))*/
            //alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

    @IBAction func loginTapped(_ sender: AnyObject) {
        animateLoginIn()
    }
    
    @IBAction func viewLoginTapped(_ sender: AnyObject) {
        let email = loginEmailField.text!
        let password = loginPasswordField.text!
        
        self.view.endEditing(true)
        
        self.signInButton.setTitle("Loading...", for: UIControlState())
        
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
            if error == nil {
                // success
                NSLog("Logged in.")
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "mainVC")
                self.present(vc!, animated: false, completion: nil)
            } else {
                // error
                NSLog("Error logging in.")
                if error?.localizedDescription == "An internal error has occurred, print and inspect the error details for more information." {
                    let alert = PSAlert.sharedInstance.instantiateAlert("Error", alertText: "There was an error logging you in.")
                    self.present(alert, animated: true, completion: nil)
                } else {
                    let alert = PSAlert.sharedInstance.instantiateAlert("Error", alertText: (error?.localizedDescription)!)
                    self.present(alert, animated: true, completion: nil)
                }
                self.signInButton.setTitle("Sign In >", for: UIControlState())
                let alert = PSAlert.sharedInstance.instantiateAlert("Error", alertText: (error?.localizedDescription)!)
                self.present(alert, animated: true, completion: nil)
            }
        })
    }
    
    @IBAction func viewSignupTapped(_ sender: AnyObject) {
        let email = signupEmailField.text!
        let password = signupPasswordField.text!
        
        self.view.endEditing(true)
        
        signUpButton.setTitle("Loading...", for: UIControlState())
        
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
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
                
                self.presentTutorial()
            } else {
                // error
                self.signUpButton.setTitle("Get Started >", for: UIControlState())
                if error?.localizedDescription == "An internal error has occurred, print and inspect the error details for more information." {
                    let alert = PSAlert.sharedInstance.instantiateAlert("Error", alertText: "There was an error creating your account.")
                    self.present(alert, animated: true, completion: nil)
                } else {
                    let alert = PSAlert.sharedInstance.instantiateAlert("Error", alertText: (error?.localizedDescription)!)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        })

    }
    
    func presentTutorial() {
        let firstPage = OnboardingContentViewController(title: "Welcome", body: "Vantage gets your homework done fast. Just sit back and relax.", image: UIImage(named: "homework"), buttonText: "", action: nil)
        firstPage.bodyLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 26.0)
        firstPage.titleLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 32.0)
        firstPage.underIconPadding = 40
        firstPage.view.backgroundColor = UIColor(red: 64.0/255.0, green: 64.0/255.0, blue: 141.0/255.0, alpha: 1.0)
        
        let secondPage = OnboardingContentViewController(title: "Lots of Subjects", body: "No matter what subject you're in, we got you covered.", image: UIImage(named: "notebook"), buttonText: "", action: nil)
        secondPage.bodyLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 26.0)
        secondPage.titleLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 32.0)
        secondPage.topPadding = 80
        secondPage.underIconPadding = 40
        secondPage.view.backgroundColor = UIColor(red: 127.0/255.0, green: 177.0/255.0, blue: 89.0/255.0, alpha: 1.0)
        
        let thirdPage = OnboardingContentViewController(title: "Rewards", body: "Earn cash rewards for helping other students.", image: UIImage(named: "gift-card"), buttonText: "", action: nil)
        thirdPage.bodyLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 26.0)
        thirdPage.titleLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 32.0)
        thirdPage.underIconPadding = 40
        thirdPage.view.backgroundColor = UIColor(red: 216.0/255.0, green: 100.0/255.0, blue: 96.0/255.0, alpha: 1.0)
        
        let fourthPage = OnboardingContentViewController(title: "Anonymity", body: "You will remain completely anonymous in the community. Tap \"Get Started\" below to begin!", image: UIImage(named: "anonymous"), buttonText: "Get Started") {
            print("'Get Started' button clicked.")
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "mainVC")
            UIApplication.shared.keyWindow?.rootViewController = vc
        }
        fourthPage.bodyLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 26.0)
        fourthPage.titleLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 32.0)
        fourthPage.buttonActionHandler = {_ in 
            print("'Get Started' button clicked.")
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "mainVC")
            UIApplication.shared.keyWindow?.rootViewController = vc
        }
        fourthPage.underIconPadding = 40
        fourthPage.view.backgroundColor = UIColor(red: 121.0/255.0, green: 194.0/255.0, blue: 250.0/255.0, alpha: 1.0)
        
        let onboardingVC = OnboardingViewController(backgroundImage: nil, contents: [firstPage, secondPage, thirdPage, fourthPage])
        
        //let vc = self.storyboard?.instantiateViewControllerWithIdentifier("tutorialVC")
        //self.dismissViewControllerAnimated(true, completion: nil)
        self.present(onboardingVC!, animated: false, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signUpWithEmailTapped(_ sender: AnyObject) {
        //showModal()
    }
    
    @IBAction func displayEULA(_ sender: Any) {
        UIApplication.shared.openURL(URL(string: "http://vantage.social/eula.html")!)
    }
    
    func keyboardWillShow(_ notification: Notification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue  {
            //keyboardHeight = keyboardSize.height
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= 150
            }
        }
        
    }
    
    func keyboardWillHide(_ notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0 {
                self.view.frame.origin.y += 150
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

//
//  MainViewController.swift
//  
//
//  Created by Parth Saxena on 7/10/16.
//
//

import UIKit
import Firebase
import GoogleMobileAds
import Armchair

 class MainViewController: UIViewController, GADBannerViewDelegate, VungleSDKDelegate {
    
    var effect: UIVisualEffect!
    @IBOutlet var visualEffectView: UIVisualEffectView!
    
    @IBOutlet weak var bannerView: GADBannerView!
    
    @IBOutlet var settingsView: UIView!
    @IBOutlet weak var askButton: UIButton!
    @IBOutlet weak var answerButton: UIButton!
    @IBOutlet weak var viewYourQuestionsButton: UIButton!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var coinsButton: UIButton!
    
    var coinsAmount = ""
    
    var giftCards = NSMutableArray()
    
    var interstitial: GADInterstitial!
    
    var timeWatchedAd = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()                        
        
        let request = GADRequest()
        request.testDevices = [kGADSimulatorID]
        bannerView.delegate = self
        bannerView.adUnitID = "ca-app-pub-7685378724367635/9077439904"
        bannerView.rootViewController = self
        bannerView.load(request)                
        
        /*interstitial = GADInterstitial(adUnitID: "ca-app-pub-7685378724367635/9077439904")
        let interstitialRequest = GADRequest()
        interstitial.loadRequest(interstitialRequest)*/
        
        ConnectionManager().getGiftCards { (result) in
            if let cards = result as? [String: [AnyObject]] {
                var count = cards["keys"]!.count
                for i in 0..<count {
                    let key = cards["keys"]![i]
                    let count = cards["counts"]![i]
                    
                    let array = [key, count]
                    self.giftCards.add(array)
                }
            }
        }
        
        self.navigationController?.navigationBar.alpha = 0
        self.navigationController!.navigationBar.barTintColor = UIColor.white
        self.navigationController!.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Roboto", size: 30)!, NSForegroundColorAttributeName: UIColor.black]
        
        effect = visualEffectView.effect
        visualEffectView.effect = nil
        self.view.sendSubview(toBack: visualEffectView)
        
        settingsView.layer.cornerRadius = 5
        
        OneSignal.idsAvailable({ (userId, pushToken) in
            //NSLog("UserId:%@", userId);
            if (pushToken != nil) {
                
                if let email = FIRAuth.auth()?.currentUser?.email {
                    let ref = FIRDatabase.database().reference()
                    let userRef = ref.child("users").queryOrdered(byChild: "email").queryEqual(toValue: email).observeSingleEvent(of: .value, with: { (snapshot) in
                        if let userDictionary = snapshot.value as? [String : AnyObject] {
                            let userID = userDictionary.first!.0
                            FIRDatabase.database().reference().child("users").child(userID).updateChildValues(["notification_id":userId])
                        }
                    })
                    print("User Ref: \(userRef), Email: \(email)")
                }
            }
        });
        
        // Do any additional setup after loading the view.
    }
    
    func animateSettingsIn() {
        self.view.addSubview(settingsView)
        settingsView.center = self.view.center
        
        settingsView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        settingsView.alpha = 0
        self.view.bringSubview(toFront: visualEffectView)
        self.view.bringSubview(toFront: settingsView)
        UIView.animate(withDuration: 0.4, animations: {
            self.visualEffectView.effect = self.effect
            self.settingsView.alpha = 1
            self.settingsView.transform = CGAffineTransform.identity
        }) 
    }
    
    @IBAction func watchVideoAdTapped(_ sender: AnyObject) {
        let alert = UIAlertController(title: "Please Wait...", message: nil, preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)
        checkVideoEpoch { (result) in
            if result as! Bool == true {
                // has been 24 hours
                alert.dismiss(animated: true, completion: { 
                    DispatchQueue.main.async(execute: { 
                        let alert = UIAlertController(title: "Alert", message: "You can watch one video ad every 24 hours and earn 1 coin. Would you like to watch one video ad?", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                            var sdk = VungleSDK.shared()
                            sdk?.delegate = self
                            do {
                                try sdk?.playAd(self, withOptions: nil)
                            } catch let error as NSError {
                                print("Error loading video ad: \(error)")
                                let alert = UIAlertController(title: "Error", message: "There was an error loading a video ad. Please try again later.", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                self.present(alert, animated: true, completion: nil)
                            }
                        }))
                        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    })
                })
            } else {
                // has not been 24 hours yet
                print("CALLBACK: has not been 24 hours")
                alert.dismiss(animated: true, completion: { 
                    DispatchQueue.main.async(execute: { 
                        let alert = UIAlertController(title: "Sorry...", message: "You must wait 24 hours between watching video ads!", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    })
                })
            }
        }
    }
    
    @IBAction func settingsTapped(_ sender: AnyObject) {
        animateSettingsIn()
    }
    
    @IBAction func exitSettingsTapped(_ sender: AnyObject) {
        animateSettingsOut()
    }
    
    @IBAction func contactSupportTapped(_ sender: AnyObject) {
        let alert = UIAlertController(title: "Contact Support", message: "Need help? Email support@socifyinc.com for support.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func resetPasswordTapped(_ sender: AnyObject) {
        let alertController = UIAlertController(title: "Please Wait...", message: nil, preferredStyle: .alert)
        self.present(alertController, animated: true, completion: nil)
        
        let email = FIRAuth.auth()?.currentUser?.email!
        
        let alert = UIAlertController(title: "Reset Password", message: "You will receive an email with instructions to reset your password. Are you sure you would like to continue?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Continue", style: .default, handler: { (action) in
            let newAlertController = UIAlertController(title: "Please Wait...", message: nil, preferredStyle: .alert)
            self.present(newAlertController, animated: true, completion: nil)
            
            FIRAuth.auth()?.sendPasswordReset(withEmail: email!, completion: { (error) in
                if error == nil {
                    let alert = UIAlertController(title: "Success", message: "Instructions on how to reset your password have been sent to your email.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action) in
                        do {
                            try FIRAuth.auth()?.signOut()
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "homeVC")
                            self.present(vc!, animated: false, completion: nil)
                        } catch {
                            let alert = UIAlertController(title: "Error", message: "There was an error signing you out...", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                        }
                    }))
                    newAlertController.dismiss(animated: true, completion: { 
                        self.present(alert, animated: true, completion: nil)
                    })
                }
            })
        }))
        alertController.dismiss(animated: true) { 
            self.present(alert, animated: true, completion: nil)
        }        
    }
    
    @IBAction func logOutTapped(_ sender: AnyObject) {
        let alert = UIAlertController(title: "Confirm", message: "Are you sure you would like to log out of Vantage? You will have to log in again.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            do {
                try FIRAuth.auth()?.signOut()
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "homeVC")
                self.present(vc!, animated: false, completion: nil)
            } catch {
                let alert = PSAlert.sharedInstance.instantiateAlert("Error", alertText: "There was an error logging you out.")
                self.present(alert, animated: true, completion: nil)
            }
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        alert.view.tintColor? = UIColor.red
        self.present(alert, animated: true, completion: nil)
    }
    
    func animateSettingsOut() {
        UIView.animate(withDuration: 0.3, animations: {
            self.settingsView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.settingsView.alpha = 0
            
            self.visualEffectView.effect = nil
            
        }, completion: { (success: Bool) in
            self.settingsView.removeFromSuperview()
            self.view.sendSubview(toBack: self.visualEffectView)
        }) 
    }
    
    func showRate() {
        if (UserDefaults.standard.integer(forKey: "numberOfLaunches") % 7 == 0 && UserDefaults.standard.bool(forKey: "userRated") == false) {
            // show rate app alert
            let alert = UIAlertController(title: ":)", message: "Liking Vantage? Help the developers and give the app a rating!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Not Now", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Sure", style: .default, handler: { (action) in
                UserDefaults.standard.set(true, forKey: "userRated")
                UIApplication.shared.openURL(URL(string: "itmss://itunes.apple.com/us/app/vantage-homework-help/id1140243092?mt=8")!)
            }))
            self.present(alert, animated: true, completion: nil)
        } else {
            NSLog("userRated: \(UserDefaults.standard.bool(forKey: "userRated")), timesLaunched: \(UserDefaults.standard.integer(forKey: "numberOfLaunches"))")
        }
    }
    
    func displayVersionError() {
        let alert = UIAlertController(title: "Alert", message: "You are not on the most recent version of Vantage. Please visit the app store and update Vantage.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            self.displayVersionError()
        }))
        alert.view.tintColor = UIColor.red
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        if GlobalVariables._displayRateAlert {
            Armchair.showPrompt()
            print("DISPLAY ALERT? : \(GlobalVariables._displayRateAlert)")
            GlobalVariables._displayRateAlert = false
        } else {
            print("NOT SHOWING RATE ALERT: \(GlobalVariables._displayRateAlert)")
        }
        
        if (UserDefaults.standard.bool(forKey: "HasLaunchedOnce")) {
            // app has been launched before
            
            NSLog("The app has been run before.")
            
        } else {
            // first launch
            
            NSLog("This is the first launch.")
            
            UserDefaults.standard.set(true, forKey:"HasLaunchedOnce")
            UserDefaults.standard.synchronize()
            
            let alert = UIAlertController(title: "Hint", message: "Tap on the coins button in the top-right corner to purchase gift cards!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Got it!", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
        loadCoins()
        
        NSLog("Checking for alerts...")
        FIRDatabase.database().reference().child("miscellaneous").observeSingleEvent(of: .value, with: { (snapshot) in
            if let miscDictionary = snapshot.value as? [String : AnyObject] {
                if (miscDictionary["mainAlert"] as! String != "none") {
                    // there is a custom mainAlert we must show
                    NSLog("alert found.")
                    let alertText = miscDictionary["mainAlert"] as! String
                    let alert = UIAlertController(title: "Alert", message: alertText, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    alert.view.tintColor = UIColor.red
                    self.present(alert, animated: true, completion: nil)
                }
                
                if (miscDictionary["iosVersion"] as! String != VERSION_NUMBER_STRING) {
                    // user is not on current version
                    NSLog("user is not on the current version of Vantage.")
                    self.displayVersionError()
                } else {
                    NSLog(miscDictionary["iosVersion"] as! String)
                }
                NSLog("no alerts found. \(miscDictionary["mainAlert"] as! String)")
            } else {
                NSLog("something went wrong finding alerts.")
            }
        })
        
        NotificationCenter.default.addObserver(self, selector:Selector("showRate"), name:
            NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        
        if (UserDefaults.standard.integer(forKey: "numberOfLaunches") % 7 == 0 && UserDefaults.standard.bool(forKey: "userRated") == false) {
            // show rate app alert
            let alert = UIAlertController(title: ":)", message: "Liking Vantage? Help the developers and give the app a rating!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Not Now", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Sure", style: .default, handler: { (action) in
                UserDefaults.standard.set(true, forKey: "userRated")
                UIApplication.shared.openURL(URL(string: "https://appsto.re/us/uQR9db.i")!)
            }))
            self.present(alert, animated: true, completion: nil)
        } else {
            NSLog("userRated: \(UserDefaults.standard.bool(forKey: "userRated"))")
        }
        
        if FIRAuth.auth()?.currentUser == nil {
            // user is not logged in
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "homeVC")
            self.present(vc!, animated: false, completion: nil)
        } else {
            // user is already logged in
            UIView.animate(withDuration: 0.5, delay: 0.0, options: [], animations: {
                //self.backgroundImageView.alpha = 0.7
                self.navigationController?.navigationBar.alpha = 1
            }) { (finished) in
                if finished {
                    UIView.animate(withDuration: 0.4, delay: 0.0, options: [], animations: {
                        self.askButton.alpha = 1
                    }) { (finishedOne) in
                        if finishedOne {
                            UIView.animate(withDuration: 0.3, delay: 0.0, options: [], animations: {
                                self.answerButton.alpha = 1
                                }, completion: { (finishedTwo) in
                                    if finishedTwo {
                                        UIView.animate(withDuration: 0.2, animations: {
                                            self.viewYourQuestionsButton.alpha = 1
                                        })
                                    }
                            })
                        }
                    }
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func loadCoins() {
        
        ConnectionManager().getCoins { (result) in
            self.coinsAmount = result as! String
            print("COINS: \(self.coinsAmount)")
            DispatchQueue.main.async(execute: {
                if self.coinsAmount == "1" {
                    self.coinsButton.setTitle("\(self.coinsAmount) coin", for: UIControlState())
                } else {
                    self.coinsButton.setTitle("\(self.coinsAmount) coins", for: UIControlState())
                }
            })
            //self.coinsButton.setTitleColor(UIColor(red: 212, green: 175, blue: 55, alpha: 1.0), forState: UIControlState.Normal)
        }
    }
    
    func vungleSDKwillCloseAd(withViewInfo viewInfo: [AnyHashable : Any]!, willPresentProductSheet: Bool) {
        print(viewInfo)
        if let info = viewInfo as? [String: AnyObject] {
            print("info: \(info)")
            if info["completedView"]?.boolValue == true {
                // user completed watching video ad
                // request five coins from server
                ConnectionManager().requestFourCoins(self.timeWatchedAd, completion: { (result) in
                    if let res = result as? String {
                        if res == "Success" {
                            // success (got 5 coins)
                            let alert = UIAlertController(title: "Awesome!", message: "Thanks for watching that quick ad! 1 coin has been added to your account.", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                        } else {
                            print("Error getting AD value: \(res)")
                            let alert = UIAlertController(title: "Sorry...", message: "Something went wrong while processing your request. Please try again later or contact support if this issue persists.", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                })
            } else {
                if let completedView = info["completedView"] {
                    print("TYPE OF: \(type(of: completedView))")
                }
                print("DID NOT FINISH AD: \(info["completedView"]), ")
                let alert = UIAlertController(title: "Oops!", message: "It appears that you did not finish watching the complete video ad. Try again after 24 hours!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        } else {
            print("error casting")
        }

    }
    
    func checkVideoEpoch(_ completion: @escaping (_ result: AnyObject) -> Void) {
        print("CHECKING VIDEO AD EPOCH")
        if let uid = FIRAuth.auth()?.currentUser?.uid {
            ConnectionManager().getVideoTime({ (result) in
                if let res = result as? String {
                    if res == "" {
                        // no result, send in current time stamp
                        let timestamp = Int(UInt64(floor(Date().timeIntervalSince1970 * 1000)))
                        self.timeWatchedAd = timestamp
                        ConnectionManager().sendVideoTime(timestamp, completion: { (result) in
                            if result as? String == "Success" {
                                // success
                                print("first time watching video ad, sent timestamp")
                                completion(true as AnyObject)
                            } else {
                                print("something went wrong while sending the timestamp: \(result as? String)")
                                completion(false as AnyObject)
                                let alert = UIAlertController(title: "Error", message: "Something went wrong... Please try again later.", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                self.present(alert, animated: true, completion: nil)
                            }
                        })
                    } else {
                        // user has watched video ad before
                        print("TIMESTAMP RESULT: \(result as? String)")
                        let currentTimestamp = Int(UInt64(floor(Date().timeIntervalSince1970 * 1000)))
                        if let oldTimestamp = Int((result as? String)!) {
                            let currentTimestamp = Int(UInt64(floor(Date().timeIntervalSince1970 * 1000)))
                            self.timeWatchedAd = currentTimestamp
                            let difference = currentTimestamp - oldTimestamp
                            if (difference >= 86400000) {
                                // it has been 24 hours
                                print("has been 24 hours")
                                let timestamp = Int(UInt64(floor(Date().timeIntervalSince1970 * 1000)))
                                self.timeWatchedAd = timestamp
                                ConnectionManager().sendVideoTime(timestamp, completion: { (result) in
                                    if result as? String == "Success" {
                                        // success
                                        print("watching video ad, sent timestamp")
                                        completion(true as AnyObject)
                                    } else {
                                        print("something went wrong while sending the timestamp: \(result as? String)")
                                        completion(false as AnyObject)
                                        let alert = UIAlertController(title: "Error", message: "Something went wrong... Please try again later.", preferredStyle: .alert)
                                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                        self.present(alert, animated: true, completion: nil)
                                    }
                                })
                            } else {
                                // has not been 24 hours yet
                                print("has not been 24 hours")
                                completion(false as AnyObject)
                            }
                        } else {
                            print("Couldn't safely cast timestamp to Integer")
                        }
                    }
                }
            })
        } else {
            print("CANT GET UID")
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

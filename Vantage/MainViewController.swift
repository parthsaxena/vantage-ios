//
//  MainViewController.swift
//  
//
//  Created by Parth Saxena on 7/10/16.
//
//

import UIKit
import Firebase

class MainViewController: UIViewController {
    
    @IBOutlet weak var askButton: UIButton!
    @IBOutlet weak var answerButton: UIButton!
    @IBOutlet weak var viewYourQuestionsButton: UIButton!
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.alpha = 0
        self.navigationController!.navigationBar.barTintColor = UIColor.whiteColor()
        self.navigationController!.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Roboto", size: 30)!, NSForegroundColorAttributeName: UIColor.blackColor()]
        
        OneSignal.IdsAvailable({ (userId, pushToken) in
            NSLog("UserId:%@", userId);
            if (pushToken != nil) {
                
                if let email = FIRAuth.auth()?.currentUser?.email {
                    let ref = FIRDatabase.database().reference()
                    let userRef = ref.child("users").queryOrderedByChild("email").queryEqualToValue(email).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
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
    
    func showRate() {
        if (NSUserDefaults.standardUserDefaults().integerForKey("numberOfLaunches") % 7 == 0 && NSUserDefaults.standardUserDefaults().boolForKey("userRated") == false) {
            // show rate app alert
            let alert = UIAlertController(title: ":)", message: "Liking Vantage? Help the developers and give the app a rating!", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Not Now", style: .Cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Sure", style: .Default, handler: { (action) in
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: "userRated")
                UIApplication.sharedApplication().openURL(NSURL(string: "itmss://itunes.apple.com/us/app/vantage-homework-help/id1140243092?mt=8")!)
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            NSLog("userRated: \(NSUserDefaults.standardUserDefaults().boolForKey("userRated")), timesLaunched: \(NSUserDefaults.standardUserDefaults().integerForKey("numberOfLaunches"))")
        }
    }
    
    func displayVersionError() {
        let alert = UIAlertController(title: "Alert", message: "You are not on the most recent version of Vantage. Please visit the app store and update Vantage.", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) in
            self.displayVersionError()
        }))
        alert.view.tintColor = UIColor.redColor()
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        NSLog("Checking for alerts...")
        FIRDatabase.database().reference().child("miscellaneous").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            if let miscDictionary = snapshot.value as? [String : AnyObject] {
                if (miscDictionary["mainAlert"] as! String != "none") {
                    // there is a custom mainAlert we must show
                    NSLog("alert found.")
                    let alertText = miscDictionary["mainAlert"] as! String
                    let alert = UIAlertController(title: "Alert", message: alertText, preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                    alert.view.tintColor = UIColor.redColor()
                    self.presentViewController(alert, animated: true, completion: nil)
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
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:Selector("showRate"), name:
            UIApplicationWillEnterForegroundNotification, object: nil)
        
        if (NSUserDefaults.standardUserDefaults().integerForKey("numberOfLaunches") % 7 == 0 && NSUserDefaults.standardUserDefaults().boolForKey("userRated") == false) {
            // show rate app alert
            let alert = UIAlertController(title: ":)", message: "Liking Vantage? Help the developers and give the app a rating!", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Not Now", style: .Cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Sure", style: .Default, handler: { (action) in
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: "userRated")
                UIApplication.sharedApplication().openURL(NSURL(string: "https://appsto.re/us/uQR9db.i")!)
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            NSLog("userRated: \(NSUserDefaults.standardUserDefaults().boolForKey("userRated"))")
        }
        
        if FIRAuth.auth()?.currentUser == nil {
            // user is not logged in
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("homeVC")
            self.presentViewController(vc!, animated: false, completion: nil)
        } else {
            // user is already logged in
            UIView.animateWithDuration(0.5, delay: 0.0, options: [], animations: {
                self.backgroundImageView.alpha = 0.4
                self.navigationController?.navigationBar.alpha = 1
            }) { (finished) in
                if finished {
                    UIView.animateWithDuration(0.4, delay: 0.0, options: [], animations: {
                        self.askButton.alpha = 1
                    }) { (finishedOne) in
                        if finishedOne {
                            UIView.animateWithDuration(0.3, delay: 0.0, options: [], animations: {
                                self.answerButton.alpha = 1
                                }, completion: { (finishedTwo) in
                                    if finishedTwo {
                                        UIView.animateWithDuration(0.2, animations: {
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

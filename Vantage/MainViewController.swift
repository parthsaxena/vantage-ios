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
        self.navigationController!.navigationBar.barTintColor = UIColor.blackColor()
        self.navigationController!.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Roboto", size: 30)!, NSForegroundColorAttributeName: UIColor.blackColor()]
        
        OneSignal.defaultClient().IdsAvailable({ (userId, pushToken) in
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

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
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

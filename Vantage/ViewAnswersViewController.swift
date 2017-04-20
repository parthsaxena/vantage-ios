//
//  ViewAnswersViewController.swift
//  Vantage
//
//  Created by Parth Saxena on 7/27/16.
//  Copyright © 2016 Socify. All rights reserved.
//

import UIKit
import Firebase
import Armchair

class ViewAnswersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let answersIDs = NSMutableArray()
    let answers = NSMutableArray()
    
    var currentImageDisplaying = UIImage()
    @IBOutlet weak var answersTableView: UITableView!
    
    func presentAlert() {
        let alert = UIAlertController(title: "Hint", message: "Tap on the image to zoom in.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Got it!", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func viewedInquiryYet(_ key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // run NSUserDefaults code
        if viewedInquiryYet("viewedAnswerYet") == false {
            // first time
            let userDefaults = UserDefaults.standard
            userDefaults.set(true, forKey: "viewedAnswerYet")
            print("first time viewing answer")
            presentAlert()
        } else {
            // do nothing
        }
        
        self.navigationController!.navigationBar.barTintColor = UIColor.white
        self.navigationController!.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Roboto", size: 30)!, NSForegroundColorAttributeName: UIColor.black]
        
        self.answersTableView.delegate = self
        self.answersTableView.dataSource = self
        
        //self.answersTableView.showLoadingIndicator()
        loadAnswers()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return answers.count
    }
    
    @IBAction func rejectAnswerTapped(_ sender: AnyObject) {
        let buttonPosition = sender.convert(CGPoint.zero, to: self.answersTableView)
        let indexPath = self.answersTableView.indexPathForRow(at: buttonPosition)
        
        let alertController = UIAlertController(title: "Confirm", message: "Are you sure you would like to reject this answer?", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            // loading alert
            let loadingAlertController = UIAlertController(title: "Please Wait...", message: nil, preferredStyle: .alert)
            self.present(loadingAlertController, animated: true, completion: nil)
            
            let answerID = self.answersIDs[indexPath!.row] as! String
            FIRDatabase.database().reference().child("answers").child(answerID).updateChildValues(["accepted":"false"])
            
            let inquiryID = GlobalVariables._currentInquiryIDAnswering
            let answererUsername = (self.answers[indexPath!.row] as! [String : AnyObject])["username"] as! String
            FIRDatabase.database().reference().child("users").child(answererUsername).observeSingleEvent(of: .value, with: { (snapshot) in
                if let userDictionary = snapshot.value as? [String : AnyObject] {
                    if let notification_id = userDictionary["notification_id"] as? String {
                        OneSignal.postNotification(["contents": ["en": "Your answer has been rejected."], "include_player_ids": [notification_id]],         onSuccess: { (nil) in
                            NSLog("Sent answer-rejected notification.")
                            //Armchair.userDidSignificantEvent(false)
                            GlobalVariables._displayRateAlert = true
                            loadingAlertController.dismiss(animated: true, completion: { 
                                let vc = self.storyboard?.instantiateViewController(withIdentifier: "viewOwnInquiryVC")
                                self.present(vc!, animated: false, completion: nil)
                            })
                            }, onFailure: { (error) in
                                NSLog("Error sending answer-rejected notification: \(error?.localizedDescription)")
                                loadingAlertController.dismiss(animated: true, completion: { 
                                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "viewOwnInquiryVC")
                                    self.present(vc!, animated: false, completion: nil)
                                })
                        })
                    } else {
                        // cannot send notification
                        loadingAlertController.dismiss(animated: true, completion: { 
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "viewOwnInquiryVC")
                            self.present(vc!, animated: false, completion: nil)
                        })
                    }
                } else {
                    loadingAlertController.dismiss(animated: true, completion: { 
                        let alert = PSAlert.sharedInstance.instantiateAlert("Error", alertText: "Something went wrong :/")
                        self.present(alert, animated: true, completion: nil)
                    })
                }
            })

            /*FIRDatabase.database().reference().child("posts").queryLimitedToFirst(1).queryOrderedByChild("id").queryEqualToValue(inquiryID).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                if let inquiryDictionary = snapshot.value as? [String : AnyObject] {
                    for inquiry in inquiryDictionary {
                        let actualInquiryID = inquiry.0
                        FIRDatabase.database().reference().child("posts").child(actualInquiryID).updateChildValues(["active":"true"])
                        
                        /*let answererUsername = (self.answers[indexPath!.row] as! [String : AnyObject])["username"] as! String
                        FIRDatabase.database().reference().child("users").child(answererUsername).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                            if let userDictionary = snapshot.value as? [String : AnyObject] {
                                if let notification_id = userDictionary["notification_id"] as? String {
                                    OneSignal.postNotification(["contents": ["en": "Your answer has been rejected."], "include_player_ids": [notification_id]],         onSuccess: { (nil) in
                                        NSLog("Sent answer-rejected notification.")
                                        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("viewOwnInquiryVC")
                                        self.presentViewController(vc!, animated: false, completion: nil)
                                        }, onFailure: { (error) in
                                            NSLog("Error sending answer-rejected notification: \(error.localizedDescription)")
                                            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("viewOwnInquiryVC")
                                            self.presentViewController(vc!, animated: false, completion: nil)
                                    })
                                } else {
                                    // cannot send notification
                                    let vc = self.storyboard?.instantiateViewControllerWithIdentifier("viewOwnInquiryVC")
                                    self.presentViewController(vc!, animated: false, completion: nil)
                                }
                            } else {
                                let alert = PSAlert.sharedInstance.instantiateAlert("Error", alertText: "Something went wrong :/")
                                self.presentViewController(alert, animated: true, completion: nil)
                            }
                        })*/
                    }
                } else {
                    let alert = PSAlert.sharedInstance.instantiateAlert("Error", alertText: "Something went wrong :/")
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            })*/
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "viewOwnInquiryVC")
            self.present(vc!, animated: false, completion: nil)
        }))
        self.present(alertController, animated: true, completion: nil)
    }
    @IBAction func acceptAnswerTapped(_ sender: AnyObject) {
        let buttonPosition = sender.convert(CGPoint.zero, to: self.answersTableView)
        let indexPath = self.answersTableView.indexPathForRow(at: buttonPosition)
        
        let alertController = UIAlertController(title: "Confirm", message: "Are you sure you would like to accept this answer?", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            
            // loading alert
            let loadingAlertController = UIAlertController(title: "Please Wait...", message: nil, preferredStyle: .alert)
            self.present(loadingAlertController, animated: true, completion: nil)
            
            let answerID = self.answersIDs[indexPath!.row] as! String
            FIRDatabase.database().reference().child("answers").child(answerID).updateChildValues(["accepted":"true"])
            
            // inquiryID
            let inquiryID = GlobalVariables._currentInquiryIDAnswering
            FIRDatabase.database().reference().child("posts").queryLimited(toFirst: 1).queryOrdered(byChild: "id").queryEqual(toValue: inquiryID).observeSingleEvent(of: .value, with: { (snapshot) in
                if let inquiryDictionary = snapshot.value as? [String : [String: AnyObject]] {
                    for inquiry in inquiryDictionary {
                        let actualInquiryID = inquiry.0
                        FIRDatabase.database().reference().child("posts").child(actualInquiryID).updateChildValues(["active":"false"])
                        
                        // uidOne
                        let currentUID = FIRAuth.auth()?.currentUser?.uid
                        // uidTwo
                        let answererUsername = (self.answers[indexPath!.row] as! [String :
                            AnyObject])["username"] as! String
                        // amount
                        if let coins = inquiry.1["coins"] as? Int {
                        let coinsString = String(coins)
                        print("COINSSTRING: \(coinsString)")
                        ConnectionManager().transferCoins(currentUID!, uidTwo: answererUsername, inquiryID: inquiryID, amount: coinsString, completion: { (result) in
                            if (result as! String == "Initiating transfer") {
                                // transfer was successful
                                DispatchQueue.main.async(execute: { 
                                    FIRDatabase.database().reference().child("users").child(answererUsername).observeSingleEvent(of: .value, with: { (snapshot) in
                                        if let userDictionary = snapshot.value as? [String : AnyObject] {
                                            if let notification_id = userDictionary["notification_id"] as? String {
                                                OneSignal.postNotification(["contents": ["en": "Your answer has been accepted!"], "include_player_ids": [notification_id]],         onSuccess: { (nil) in
                                                    NSLog("Sent answer-accepted notification.")
                                                    //Armchair.userDidSignificantEvent(false)
                                                    GlobalVariables._displayRateAlert = true
                                                    loadingAlertController.dismiss(animated: true, completion: { 
                                                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "viewOwnInquiryVC")
                                                        self.present(vc!, animated: false, completion: nil)
                                                    })
                                                    }, onFailure: { (error) in
                                                        NSLog("Error sending answer-accepted notification: \(error?.localizedDescription)")
                                                        loadingAlertController.dismiss(animated: true, completion: { 
                                                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "viewOwnInquiryVC")
                                                            self.present(vc!, animated: false, completion: nil)
                                                        })
                                                })
                                            } else {
                                                // cannot send notification
                                                loadingAlertController.dismiss(animated: true, completion: { 
                                                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "viewOwnInquiryVC")
                                                    self.present(vc!, animated: false, completion: nil)
                                                })
                                            }
                                        } else {
                                            loadingAlertController.dismiss(animated: true, completion: { 
                                                let alert = PSAlert.sharedInstance.instantiateAlert("Error", alertText: "Something went wrong.")
                                                self.present(alert, animated: true, completion: nil)
                                            })
                                        }
                                    })
                                })
                            } else {
                                print(result as! String)
                                loadingAlertController.dismiss(animated: true, completion: { 
                                    let alert = UIAlertController(title: "Error", message: "An error occurred while processing your request...", preferredStyle: .alert)
                                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                    self.present(alert, animated: true, completion: nil)
                                })
                            }
                        })
                        }
                    }
                } else {
                    loadingAlertController.dismiss(animated: true, completion: { 
                        let alert = PSAlert.sharedInstance.instantiateAlert("Error", alertText: "Something went wrong.")
                        self.present(alert, animated: true, completion: nil)
                    })
                }
            })
        }))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! AnswerTableViewCell
        print("Viewing answers...")
        let answer = self.answers[indexPath.row] as! [String : AnyObject]
        
        let imageName = answer["image"] as! String
        let imageRef = FIRStorage.storage().reference(forURL: "gs://vantage-e9003.appspot.com").child("images/\(imageName)")
        imageRef.data(withMaxSize: 10 * 1024 * 1024) { (data, error) -> Void in
            if error == nil {
                let image = UIImage(data: data!)
                self.currentImageDisplaying = image!
                
                cell.answerImageView.displayImage(image!)
                if (imageName != "NO_IMAGE_WHITE.jpg") {
                    NSLog("image value: \(imageName)")
                    cell.answerImageView.isUserInteractionEnabled = true
                    cell.answerImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ViewAnswersViewController.imageTapped(_:))))
                }
                cell.answerTextView.text = answer["content"] as! String
                if let timeInterval = answer["createdAt"] as? TimeInterval {
                    let date = Date(timeIntervalSince1970: timeInterval/1000)
                    let dayTimePeriodFormatter = DateFormatter()
                    dayTimePeriodFormatter.dateFormat = "M/d/yyyy h:mm a"
                    
                    let dateString = dayTimePeriodFormatter.string(from: date)
                    cell.dateLabel.text = dateString
                }
                
                cell.configureCell()
                if (answer["accepted"] as! String == "true") {
                    //disable accept/reject buttons
                    cell.acceptButton.isEnabled = false
                    cell.acceptButton.isHidden = true
                    
                    cell.rejectButton.isEnabled = false
                    cell.rejectButton.isHidden = true
                }
                //self.answersTableView.hideLoadingIndicator()
            } else {
                // error
                NSLog("Error while downloading an image. Error: \(error?.localizedDescription)")
                
            }
        }
        
        return cell
    }

    func imageTapped(_ sender: UITapGestureRecognizer) {
        NSLog("image tapped")
        let newImageScrollView = ImageScrollView()
        newImageScrollView.frame = self.view.frame
        newImageScrollView.backgroundColor = .black
        newImageScrollView.contentMode = .scaleAspectFit
        newImageScrollView.displayImage(currentImageDisplaying)
        newImageScrollView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: Selector("dismissFullscreenImage:"))
        newImageScrollView.addGestureRecognizer(tap)
        self.view.addSubview(newImageScrollView)
    }
    
    func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        sender.view?.removeFromSuperview()
    }
    
    func loadAnswers() {
         FIRDatabase.database().reference().child("answers").queryOrdered(byChild: "inquiryID").queryEqual(toValue: GlobalVariables._currentInquiryIDAnswering).observeSingleEvent(of: .value, with: { (snapshot) in
            if let inquiryDictionary = snapshot.value as? [String : AnyObject] {
                
                if inquiryDictionary.count == 0 {
                    //self.answersTableView.hideLoadingIndicator()
                }
                
                let sortedDictionary = inquiryDictionary.sorted {
                    let createdAtOne = ($0.1 as! [String : AnyObject])["createdAt"] as! Int
                    let createdAtTwo = ($1.1 as! [String : AnyObject])["createdAt"] as! Int
                    return createdAtOne > createdAtTwo
                }
                print(sortedDictionary)
                
                for answer in sortedDictionary {
                    if ((answer.1 as! [String : AnyObject])["accepted"] as! String == "true") {
                        self.answersIDs.add(answer.0)
                        self.answers.add(answer.1)
                        break
                    } else if ((answer.1 as! [String: AnyObject])["accepted"] as! String == "none") {
                        self.answersIDs.add(answer.0)
                        self.answers.add(answer.1)
                    }
                }
                if (self.answers.count == 1) {
                    self.answersTableView.separatorColor = UIColor.clear
                    self.answersTableView.reloadData()
                } else {
                    self.answersTableView.reloadData()
                }
            } else {
                //self.answersTableView.hideLoadingIndicator()
            }
        })
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let answer = self.answers[indexPath.row] as! [String : AnyObject]
        
        let imageString = answer["image"] as! String
        NSLog("cell height. imageString: \(imageString)")
        guard imageString != "NO_IMAGE_WHITE.jpg" else {
            return 245
        }
        return 476
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

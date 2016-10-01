//
//  ViewAnswersViewController.swift
//  Vantage
//
//  Created by Parth Saxena on 7/27/16.
//  Copyright © 2016 Socify. All rights reserved.
//

import UIKit
import Firebase

class ViewAnswersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let answersIDs = NSMutableArray()
    let answers = NSMutableArray()
    
    @IBOutlet weak var answersTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController!.navigationBar.barTintColor = UIColor.whiteColor()
        self.navigationController!.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Roboto", size: 30)!, NSForegroundColorAttributeName: UIColor.blackColor()]
        
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

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return answers.count
    }
    
    @IBAction func rejectAnswerTapped(sender: AnyObject) {
        let buttonPosition = sender.convertPoint(CGPointZero, toView: self.answersTableView)
        let indexPath = self.answersTableView.indexPathForRowAtPoint(buttonPosition)
        
        let alertController = UIAlertController(title: "Confirm", message: "Are you sure you would like to reject this answer?", preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "No", style: .Cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { (action) in
            let answerID = self.answersIDs[indexPath!.row] as! String
            FIRDatabase.database().reference().child("answers").child(answerID).updateChildValues(["accepted":"false"])
            
            let inquiryID = GlobalVariables._currentInquiryIDAnswering
            FIRDatabase.database().reference().child("posts").queryLimitedToFirst(1).queryOrderedByChild("id").queryEqualToValue(inquiryID).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                if let inquiryDictionary = snapshot.value as? [String : AnyObject] {
                    for inquiry in inquiryDictionary {
                        let actualInquiryID = inquiry.0
                        FIRDatabase.database().reference().child("posts").child(actualInquiryID).updateChildValues(["active":"true"])
                        
                        let answererUsername = (self.answers[indexPath!.row] as! [String : AnyObject])["username"] as! String
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
                        })
                    }
                } else {
                    let alert = PSAlert.sharedInstance.instantiateAlert("Error", alertText: "Something went wrong :/")
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            })
            
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("viewOwnInquiryVC")
            self.presentViewController(vc!, animated: false, completion: nil)
        }))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    @IBAction func acceptAnswerTapped(sender: AnyObject) {
        let buttonPosition = sender.convertPoint(CGPointZero, toView: self.answersTableView)
        let indexPath = self.answersTableView.indexPathForRowAtPoint(buttonPosition)
        
        let alertController = UIAlertController(title: "Confirm", message: "Are you sure you would like to accept this answer?", preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "No", style: .Cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { (action) in
            let answerID = self.answersIDs[indexPath!.row] as! String
            FIRDatabase.database().reference().child("answers").child(answerID).updateChildValues(["accepted":"true"])
            
            let inquiryID = GlobalVariables._currentInquiryIDAnswering!
            FIRDatabase.database().reference().child("posts").queryLimitedToFirst(1).queryOrderedByChild("id").queryEqualToValue(inquiryID).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                if let inquiryDictionary = snapshot.value as? [String : AnyObject] {
                    for inquiry in inquiryDictionary {
                        let actualInquiryID = inquiry.0
                        FIRDatabase.database().reference().child("posts").child(actualInquiryID).updateChildValues(["active":"false"])
                        
                        let answererUsername = (self.answers[indexPath!.row] as! [String : AnyObject])["username"] as! String
                        FIRDatabase.database().reference().child("users").child(answererUsername).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                            if let userDictionary = snapshot.value as? [String : AnyObject] {
                                if let notification_id = userDictionary["notification_id"] as? String {
                                    OneSignal.postNotification(["contents": ["en": "Your answer has been accepted!"], "include_player_ids": [notification_id]],         onSuccess: { (nil) in
                                        NSLog("Sent answer-accepted notification.")
                                        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("viewOwnInquiryVC")
                                        self.presentViewController(vc!, animated: false, completion: nil)
                                        }, onFailure: { (error) in
                                            NSLog("Error sending answer-accepted notification: \(error.localizedDescription)")
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
                        })
                    }
                } else {
                    let alert = PSAlert.sharedInstance.instantiateAlert("Error", alertText: "Something went wrong :/")
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            })
        }))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! AnswerTableViewCell
        print("Viewing answers...")
        let answer = self.answers[indexPath.row] as! [String : AnyObject]
        
        let imageName = answer["image"] as! String
        let imageRef = FIRStorage.storage().referenceForURL("gs://vantage-e9003.appspot.com").child("images/\(imageName)")
        imageRef.dataWithMaxSize(10 * 1024 * 1024) { (data, error) -> Void in
            if error == nil {
                let image = UIImage(data: data!)
                
                cell.answerImageView.image = image
                if (imageName != "NO_IMAGE_WHITE.jpg") {
                    NSLog("image value: \(imageName)")
                    cell.answerImageView.userInteractionEnabled = true
                    cell.answerImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ViewAnswersViewController.imageTapped(_:))))
                }
                cell.answerTextView.text = answer["content"] as! String
                if let timeInterval = answer["createdAt"] as? NSTimeInterval {
                    let date = NSDate(timeIntervalSince1970: timeInterval/1000)
                    let dayTimePeriodFormatter = NSDateFormatter()
                    dayTimePeriodFormatter.dateFormat = "M/d/yyyy h:mm a"
                    
                    let dateString = dayTimePeriodFormatter.stringFromDate(date)
                    cell.dateLabel.text = dateString
                }
                
                cell.configureCell()
                if (answer["accepted"] as! String == "true") {
                    //disable accept/reject buttons
                    cell.acceptButton.enabled = false
                    cell.acceptButton.hidden = true
                    
                    cell.rejectButton.enabled = false
                    cell.rejectButton.hidden = true
                }
                //self.answersTableView.hideLoadingIndicator()
            } else {
                // error
                NSLog("Error while downloading an image. Error: \(error?.localizedDescription)")
                
            }
        }
        
        return cell
    }

    func imageTapped(sender: UITapGestureRecognizer) {
        NSLog("image tapped")
        
        
        let imageView = sender.view as! UIImageView
        let newImageView = UIImageView()
        newImageView.frame = self.view.frame
        newImageView.backgroundColor = .blackColor()
        newImageView.contentMode = .ScaleAspectFit
        newImageView.image = imageView.image
        newImageView.userInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: Selector("dismissFullscreenImage:"))
        newImageView.addGestureRecognizer(tap)
        self.view.addSubview(newImageView)
    }
    
    func dismissFullscreenImage(sender: UITapGestureRecognizer) {
        sender.view?.removeFromSuperview()
    }
    
    func loadAnswers() {
         FIRDatabase.database().reference().child("answers").queryOrderedByChild("inquiryID").queryEqualToValue(GlobalVariables._currentInquiryIDAnswering!).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            if let inquiryDictionary = snapshot.value as? [String : AnyObject] {
                
                if inquiryDictionary.count == 0 {
                    //self.answersTableView.hideLoadingIndicator()
                }
                
                let sortedDictionary = inquiryDictionary.sort {
                    let createdAtOne = ($0.1 as! [String : AnyObject])["createdAt"] as! Int
                    let createdAtTwo = ($1.1 as! [String : AnyObject])["createdAt"] as! Int
                    return createdAtOne > createdAtTwo
                }
                print(sortedDictionary)
                
                for answer in sortedDictionary {
                    if ((answer.1 as! [String : AnyObject])["accepted"] as! String == "true") {
                        self.answersIDs.addObject(answer.0)
                        self.answers.addObject(answer.1)
                        break
                    } else if ((answer.1 as! [String: AnyObject])["accepted"] as! String == "none") {
                        self.answersIDs.addObject(answer.0)
                        self.answers.addObject(answer.1)
                    }
                }
                if (self.answers.count == 1) {
                    self.answersTableView.separatorColor = UIColor.clearColor()
                    self.answersTableView.reloadData()
                } else {
                    self.answersTableView.reloadData()
                }
            } else {
                //self.answersTableView.hideLoadingIndicator()
            }
        })
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
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

//
//  ViewOwnInquiryViewController.swift
//  Vantage
//
//  Created by Parth Saxena on 7/16/16.
//  Copyright © 2016 Socify. All rights reserved.
//

import UIKit
import Firebase

class ViewOwnInquiryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
 
    @IBOutlet weak var inquiryTableView: UITableView!
    
        var inquiry = NSMutableArray()
        
        var inquiryTitle: String!
        var inquiryContent: String!
        var inquiryID: String!
        var inquiryCreatedAt: AnyObject!
        var inquiryImage: String!
    
    var numberOfAnswers = 0
    
        override func viewDidLoad() {
            super.viewDidLoad()
            
            self.navigationController!.navigationBar.barTintColor = UIColor.whiteColor()
            self.navigationController!.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Roboto", size: 30)!, NSForegroundColorAttributeName: UIColor.blackColor()]
            
            self.title = "\(GlobalVariables._currentSubjectPostingTo) Inquiry"
            
            self.inquiryTableView.dataSource = self
            self.inquiryTableView.delegate = self
            
            //self.inquiryTableView.showLoadingIndicator()
            loadData()
            
            // Uncomment the following line to preserve selection between presentations
            // self.clearsSelectionOnViewWillAppear = false
            
            // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
            // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        }
        
        func loadData() {
            let inquiryID = GlobalVariables._currentInquiryIDAnswering
            NSLog(inquiryID)
            let inquiryRef = FIRDatabase.database().reference().child("posts").queryOrderedByChild("id").queryEqualToValue(inquiryID).queryLimitedToFirst(1).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                if let inquiryDictionary = snapshot.value as? [String : AnyObject] {
                    if let inquiry = inquiryDictionary.first!.1 as? [String : AnyObject] {
                        self.inquiry.addObject(inquiry)
                        self.inquiryTableView.reloadData()
                    }
                }
            })
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
            return inquiry.count
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
    
        func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! ViewInquiryTableViewCell
            
            let inquiry = self.inquiry[indexPath.row] as! [String : AnyObject]
            
            let answersRef = FIRDatabase.database().reference().child("answers").queryOrderedByChild("inquiryID").queryEqualToValue(inquiry["id"] as! String).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                if let dictionary = snapshot.value as? [String : AnyObject] {
                    let actualAnswers = NSMutableArray()
                    var inquiryAnswered = false
                    for answer in dictionary {
                        if ((answer.1)["accepted"] == "true") {
                            cell.answerButton.setTitle("View Accepted Answer", forState: UIControlState.Normal)
                            inquiryAnswered = true
                            self.numberOfAnswers = 1
                            break
                        } else if ((answer.1 )["accepted"] == "none") {
                            actualAnswers.addObject(answer.1)
                        } else {
                            NSLog("accepted value: \(answer.1["accepted"])")
                        }
                    }
                    if (inquiryAnswered == false) {
                        self.numberOfAnswers = actualAnswers.count
                        if actualAnswers.count != 0 {
                            if actualAnswers.count == 1 {
                                cell.answerButton.setTitle("\(actualAnswers.count) Answer", forState: UIControlState.Normal)
                            } else {
                                cell.answerButton.setTitle("\(actualAnswers.count) Answers", forState: UIControlState.Normal)
                            }
                        
                        } else {
                            //cell.answerButton!.textColor = UIColor.redColor()
                        }
                    }
                }
            })
            
            cell.titleLabel.text = inquiry["title"] as? String
            cell.titleLabel.numberOfLines = 0
            cell.contentTextView.text = inquiry["content"] as? String
            cell.inquiryIDLabel.text = "Inquiry ID: \(inquiry["id"] as! String)"                        
            
            if let timeInterval = inquiry["createdAt"] as? NSTimeInterval {
                let secondsTimeInterval = Int(timeInterval / 1000)
                let currentTimeInterval = Int(NSDate().timeIntervalSince1970)
                
                let distanceTimeInterval = (currentTimeInterval - secondsTimeInterval)
                print("distanceTimeInterval: \(distanceTimeInterval)")
                let totalMinutes = (distanceTimeInterval / 60)
                let hours = totalMinutes / 60
                let minutes = totalMinutes % 60
                
                print("hours: \(hours)")
                //let minutes =
                if hours != 0 {
                    // there are hours
                    cell.dateLabel.text = "\(hours)h, \(minutes)m ago"
                } else {
                    // there are no hours
                    if minutes == 0 {
                        cell.dateLabel.text = "a moment ago"
                    }
                    else if minutes == 1 {
                        cell.dateLabel.text = "\(minutes)m ago"
                    } else {
                        cell.dateLabel.text = "\(minutes)m ago"
                    }
                }
            }
            
            let image = inquiry["image"] as! String
            let imageRef = FIRStorage.storage().referenceForURL("gs://vantage-e9003.appspot.com").child("images/\(image)")
            imageRef.dataWithMaxSize(10 * 1024 * 1024) { (data, error) -> Void in
                if error == nil {
                    let image = UIImage(data: data!)
                    
                    FIRDatabase.database().reference().child("answers").queryOrderedByChild("inquiryID").queryEqualToValue(inquiry["id"] as! String).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                        if let answers = snapshot.value as? [String : AnyObject] {
                            //cell.answerButton.setTitle("View Answers (\(answers.count))", forState: .Normal)
                            cell.inquiryImage.image = image
                            cell.inquiryImage.userInteractionEnabled = true
                            cell.inquiryImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ViewOwnInquiryViewController.imageTapped(_:))))
                            
                            cell.inquiryIDLabel.alpha = 0
                            cell.dateLabel.alpha = 0
                            cell.titleLabel.alpha = 0
                            cell.inquiryImage.alpha = 0
                            cell.contentTextView.alpha = 0
                            cell.answerButton.alpha = 0
                            
                            UIView.animateWithDuration(0.4) {
                                cell.inquiryIDLabel.alpha = 1
                                cell.dateLabel.alpha = 1
                                cell.titleLabel.alpha = 1
                                cell.inquiryImage.alpha = 1
                                cell.contentTextView.alpha = 1
                                cell.answerButton.alpha = 1
                            }
                        } else {
                            //cell.answerButton.setTitle("View Answers (0)", forState: .Normal)
                            cell.inquiryImage.image = image
                            
                            cell.inquiryIDLabel.alpha = 0
                            cell.dateLabel.alpha = 0
                            cell.titleLabel.alpha = 0
                            cell.inquiryImage.alpha = 0
                            cell.contentTextView.alpha = 0
                            cell.answerButton.alpha = 0
                            
                            UIView.animateWithDuration(0.4) {
                                cell.inquiryIDLabel.alpha = 1
                                cell.dateLabel.alpha = 1
                                cell.titleLabel.alpha = 1
                                cell.inquiryImage.alpha = 1
                                cell.contentTextView.alpha = 1
                                cell.answerButton.alpha = 1
                            }
                        }
                    })
                } else {
                    // error
                    NSLog("Error while downloading an image. Error: \(error?.localizedDescription)")
                }
            }
            //self.inquiryTableView.hideLoadingIndicator()
            
            return cell
        }
        
        @IBAction func viewAnswersTapped(sender: AnyObject) {
            if (numberOfAnswers == 0) {
                let alert = UIAlertController(title: "Alert", message: "You have not received any answers for your inquiry yet.", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                alert.view.tintColor = UIColor.redColor()
                self.presentViewController(alert, animated: true, completion: nil)
            } else {
                let vc = self.storyboard?.instantiateViewControllerWithIdentifier("viewAnswersVC")
                self.presentViewController(vc!, animated: false, completion: nil)
            }
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

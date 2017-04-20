//
//  ViewOwnInquiryViewController.swift
//  Vantage
//
//  Created by Parth Saxena on 7/16/16.
//  Copyright © 2016 Socify. All rights reserved.
//

import UIKit
import Firebase
import NVActivityIndicatorView

class ViewOwnInquiryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
 
    var activityIndicatorView: NVActivityIndicatorView!
    @IBOutlet weak var inquiryTableView: UITableView!
    
        var inquiry = NSMutableArray()
        
        var inquiryTitle: String!
        var inquiryContent: String!
        var inquiryID: String!
        var inquiryCreatedAt: AnyObject!
        var inquiryImage: String!
    
    var currentImageDisplaying = UIImage()
    
    var numberOfAnswers = 0
    
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
            
            activityIndicatorView = NVActivityIndicatorView(frame: self.view.frame, type: .ballRotate, color: UIColor.lightGray, padding: CGFloat(100))
            activityIndicatorView.alpha = 0
            self.view.addSubview(activityIndicatorView)
            self.view.bringSubview(toFront: activityIndicatorView)
            UIView.animate(withDuration: 0.1) {
                self.activityIndicatorView.alpha = 1
            }            
            self.activityIndicatorView.startAnimating()
            
            // run NSUserDefaults code
            if viewedInquiryYet("viewedOtherInquiryYet") == false {
                // first time
                let userDefaults = UserDefaults.standard
                userDefaults.set(true, forKey: "viewedOtherInquiryYet")
                print("first time viewing inquiry")
                presentAlert()
            } else {
                // do nothing
            }
            
            self.navigationController!.navigationBar.barTintColor = UIColor.white
            self.navigationController!.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Roboto", size: 30)!, NSForegroundColorAttributeName: UIColor.black]
            
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
            let inquiryRef = FIRDatabase.database().reference().child("posts").queryOrdered(byChild: "id").queryEqual(toValue: inquiryID).queryLimited(toFirst: 1).observeSingleEvent(of: .value, with: { (snapshot) in
                if let inquiryDictionary = snapshot.value as? [String : AnyObject] {
                    if let inquiry = inquiryDictionary.first!.1 as? [String : AnyObject] {
                        self.inquiry.add(inquiry)
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
        
        func numberOfSections(in tableView: UITableView) -> Int {
            // #warning Incomplete implementation, return the number of sections
            return 1
        }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            // #warning Incomplete implementation, return the number of rows
            return inquiry.count
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
    
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ViewInquiryTableViewCell
            
            let inquiry = self.inquiry[indexPath.row] as! [String : AnyObject]
            
            let answersRef = FIRDatabase.database().reference().child("answers").queryOrdered(byChild: "inquiryID").queryEqual(toValue: inquiry["id"] as! String).observeSingleEvent(of: .value, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String : Any] {
                    let actualAnswers = NSMutableArray()
                    var inquiryAnswered = false
                    for answer in dictionary {
                        let answerDict = answer.value as? [String: Any]
                        if (answerDict?["accepted"] as? String == "true") {
                            cell.answerButton.setTitle("View Accepted Answer", for: UIControlState())
                            inquiryAnswered = true
                            self.numberOfAnswers = 1
                            break
                        } else if (answerDict?["accepted"] as? String == "none") {
                            actualAnswers.add(answer.1)
                        } else {
                            NSLog("accepted value: \(answerDict?["accepted"])")
                        }
                    }
                    if (inquiryAnswered == false) {
                        self.numberOfAnswers = actualAnswers.count
                        if actualAnswers.count != 0 {
                            if actualAnswers.count == 1 {
                                cell.answerButton.setTitle("\(actualAnswers.count) Answer", for: UIControlState())
                            } else {
                                cell.answerButton.setTitle("\(actualAnswers.count) Answers", for: UIControlState())
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
            
            if let timeInterval = inquiry["createdAt"] as? TimeInterval {
                let secondsTimeInterval = Int(timeInterval / 1000)
                let currentTimeInterval = Int(Date().timeIntervalSince1970)
                
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
            
            let imageName = inquiry["image"] as! String
            let imageRef = FIRStorage.storage().reference(forURL: "gs://vantage-e9003.appspot.com").child("images/\(imageName)")
            imageRef.data(withMaxSize: 10 * 1024 * 1024) { (data, error) -> Void in
                if error == nil {
                    let image = UIImage(data: data!)
                    self.currentImageDisplaying = image!
                    FIRDatabase.database().reference().child("answers").queryOrdered(byChild: "inquiryID").queryEqual(toValue: inquiry["id"] as! String).observeSingleEvent(of: .value, with: { (snapshot) in
                        if let answers = snapshot.value as? [String : AnyObject] {
                            //cell.answerButton.setTitle("View Answers (\(answers.count))", forState: .Normal)
                            cell.inquiryImage.displayImage(image!)
                            
                            if (imageName != "NO_IMAGE_WHITE.jpg") {
                                // image exists
                                print(image)
                                cell.inquiryImage.isUserInteractionEnabled = true
                                cell.inquiryImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ViewOwnInquiryViewController.imageTapped(_:))))
                            }
                            
                            cell.inquiryIDLabel.alpha = 0
                            cell.dateLabel.alpha = 0
                            cell.titleLabel.alpha = 0
                            cell.inquiryImage.alpha = 0
                            cell.contentTextView.alpha = 0
                            cell.answerButton.alpha = 0
                            
                            UIView.animate(withDuration: 0.4, animations: {
                                self.activityIndicatorView.alpha = 0
                                cell.inquiryIDLabel.alpha = 1
                                cell.dateLabel.alpha = 1
                                cell.titleLabel.alpha = 1
                                cell.inquiryImage.alpha = 1
                                cell.contentTextView.alpha = 1
                                cell.answerButton.alpha = 1
                            }, completion: { (success) in
                                self.activityIndicatorView.stopAnimating()
                            })
                        } else {
                            //cell.answerButton.setTitle("View Answers (0)", forState: .Normal)
                            
                            cell.inquiryImage.displayImage(image!)
                            cell.inquiryImage.isUserInteractionEnabled = true
                            cell.inquiryImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ViewOwnInquiryViewController.imageTapped(_:))))
                            cell.inquiryIDLabel.alpha = 0
                            cell.dateLabel.alpha = 0
                            cell.titleLabel.alpha = 0
                            cell.inquiryImage.alpha = 0
                            cell.contentTextView.alpha = 0
                            cell.answerButton.alpha = 0
                            
                            UIView.animate(withDuration: 0.4, animations: {
                                self.activityIndicatorView.alpha = 0
                                cell.inquiryIDLabel.alpha = 1
                                cell.dateLabel.alpha = 1
                                cell.titleLabel.alpha = 1
                                cell.inquiryImage.alpha = 1
                                cell.contentTextView.alpha = 1
                                cell.answerButton.alpha = 1
                            }, completion: { (success) in
                                self.activityIndicatorView.stopAnimating()
                            })
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
        
        @IBAction func viewAnswersTapped(_ sender: AnyObject) {
            if (numberOfAnswers == 0) {
                let alert = UIAlertController(title: "Alert", message: "You have not received any answers for your inquiry yet.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                alert.view.tintColor = UIColor.red
                self.present(alert, animated: true, completion: nil)
            } else {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "viewAnswersVC")
                self.present(vc!, animated: false, completion: nil)
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

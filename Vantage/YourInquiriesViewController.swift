
//
//  YourInquiriesViewController.swift
//  
//
//  Created by Parth Saxena on 7/16/16.
//
//

import UIKit
import Firebase

class YourInquiriesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var inquiries = NSMutableArray()
    
    @IBOutlet weak var inquiriesTableView: LoadingTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController!.navigationBar.barTintColor = UIColor.whiteColor()
        self.navigationController!.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Roboto", size: 30)!, NSForegroundColorAttributeName: UIColor.blackColor()]
        
        self.title = "Your Inquiries"
        
        self.inquiriesTableView.dataSource = self
        self.inquiriesTableView.delegate = self
        
        self.inquiriesTableView.showLoadingIndicator()
        loadData()
        
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
        return self.inquiries.count
    }

    func loadData() {
        let currentUID = FIRAuth.auth()?.currentUser?.uid
        
        FIRDatabase.database().reference().child("posts").queryOrderedByChild("username").queryEqualToValue(currentUID).observeEventType(.Value, withBlock: { (snapshot) in
            self.inquiries.removeAllObjects()
            
            if let inquiryDictionary = snapshot.value as? [String : AnyObject] {
                if inquiryDictionary.count == 0 {
                    self.inquiries.addObject("none")
                    self.inquiriesTableView.reloadData()
                    self.inquiriesTableView.hideLoadingIndicator()
                    
                    NSLog("No inquiries found.")
                } else {
                    let sortedDictionary = inquiryDictionary.sort {
                        let createdAtOne = ($0.1 as! [String : AnyObject])["createdAt"] as! Int
                        let createdAtTwo = ($1.1 as! [String : AnyObject])["createdAt"] as! Int
                        return createdAtOne > createdAtTwo
                    }
                    print(sortedDictionary)
                    
                    for inquiry in sortedDictionary {
                        self.inquiries.addObject(inquiry.1)
                    }
                    self.inquiriesTableView.hideLoadingIndicator()
                    self.inquiriesTableView.reloadData()
                }
            } else {
                self.inquiries.addObject("none")
                self.inquiriesTableView.reloadData()
                self.inquiriesTableView.hideLoadingIndicator()
                
                NSLog("No inquiries found.")
            }
        })
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! InquiryTableViewCell
        
        if let inquiry = self.inquiries[indexPath.row] as? String {
            if inquiry == "none" {
                cell.textLabel!.text = "You do not have any inquiries."
                cell.textLabel!.numberOfLines = 0
                self.inquiriesTableView.separatorStyle = .None
                cell.answersLabel?.hidden = true
                return cell
            }
        } else {
            
            let inquiry = self.inquiries[indexPath.row] as! [String : AnyObject]
            
            let answersRef = FIRDatabase.database().reference().child("answers").queryOrderedByChild("inquiryID").queryEqualToValue(inquiry["id"] as! String).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                if let dictionary = snapshot.value as? [String : AnyObject] {
                    if dictionary.count != 0 {
                        if dictionary.count == 1 {
                            cell.answersLabel!.text = "\(dictionary.count) Answer"                            
                        } else {
                            cell.answersLabel!.text = "\(dictionary.count) Answers"                            
                        }
                    } else {
                        cell.answersLabel!.textColor = UIColor.redColor()
                    }
                }
            })
            
            cell.titleLabel.text = inquiry["title"] as! String
            cell.usernameLabel.text = "Inquiry ID: \(inquiry["id"] as! String)"
            
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
                    if minutes == 1 {
                        cell.dateLabel.text = "\(minutes)m ago"
                    } else {
                        cell.dateLabel.text = "\(minutes)m ago"
                    }
                }
            }
            
            cell.configureCell()
            
            return cell
        }
        
        return UITableViewCell()
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let inquiry = self.inquiries[indexPath.row] as! [String : AnyObject]
        let inquiryID = inquiry["id"]
        let inquirySubject = inquiry["subject"]
        
        GlobalVariables._currentSubjectPostingTo = inquirySubject as! String
        GlobalVariables._currentInquiryIDAnswering = inquiryID as! String
        
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("viewOwnInquiryVC")
        self.presentViewController(vc!, animated: false, completion: nil)
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .Normal, title: "Discard") { action, index in
            let inquiry = self.inquiries[indexPath.row] as! [String : AnyObject]
            let inquiryID = inquiry["id"]
            
            FIRDatabase.database().reference().child("posts").queryOrderedByChild("id").queryEqualToValue(inquiryID).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                if let inquiryDictionary = snapshot.value as? [String : AnyObject] {
                    if inquiryDictionary.count == 0 {
                        let alert = PSAlert.sharedInstance.instantiateAlert("Error", alertText: "There was an error discarding your inquiry.")
                        NSLog("something serious just went wrong...")
                    } else {
                        for inquiry in inquiryDictionary {
                            FIRDatabase.database().reference().child("posts").child(inquiry.0).removeValue()
                        }
                    }
                } else {
                    let alert = PSAlert.sharedInstance.instantiateAlert("Error", alertText: "There was an error discarding your inquiry.")
                    NSLog("something serious just went wrong...")
                }
            })
        }
        delete.backgroundColor = UIColor.redColor()
        
        return [delete]
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // the cells you would like the actions to appear needs to be editable
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        // you need to implement this method too or you can't swipe to display the actions
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

//
//  InquiriesViewController.swift
//  Vantage
//
//  Created by Parth Saxena on 7/10/16.
//  Copyright © 2016 Socify. All rights reserved.
//

import UIKit
import Firebase

class InquiriesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var inquiries = NSMutableArray()
    
    @IBOutlet weak var inquiriesTableView: LoadingTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController!.navigationBar.barTintColor = UIColor.blackColor()
        self.navigationController!.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Roboto", size: 30)!, NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        self.title = "Inquiries In \(GlobalVariables._currentSubjectPostingTo)"
        
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

    func loadData() {
        FIRDatabase.database().reference().child("posts").queryOrderedByChild("subject").queryEqualToValue(GlobalVariables._currentSubjectPostingTo).observeEventType(.Value, withBlock: { (snapshot) in
            if let inquiryDictionary = snapshot.value as? [String : AnyObject] {
                
                if inquiryDictionary.count == 0 {
                    self.inquiries.addObject("none")
                    self.inquiriesTableView.reloadData()
                    self.inquiriesTableView.hideLoadingIndicator()
                    
                    NSLog("No inquiries found.")
                } else {
                    NSLog("Inquiries found.")
                    for object in inquiryDictionary {
                        print(object.1)
                        self.inquiries.addObject(object.1)
                    }
                    self.inquiriesTableView.reloadData()
                    self.inquiriesTableView.hideLoadingIndicator()
                }
            } else {
                self.inquiries.addObject("none")
                self.inquiriesTableView.reloadData()
                self.inquiriesTableView.hideLoadingIndicator()
                
                NSLog("No inquiries found.")
            }
        })
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.inquiries.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! InquiryTableViewCell
        
        if let inquiry = self.inquiries[indexPath.row] as? String {
            if inquiry == "none" {
                cell.textLabel!.text = "There are currently no inquiries in \(GlobalVariables._currentSubjectPostingTo)"
                self.inquiriesTableView.separatorStyle = .None
                return cell
            }
        } else {
        
        let inquiry = self.inquiries[indexPath.row] as! [String : AnyObject]
        cell.titleLabel.text = inquiry["title"] as! String
        cell.usernameLabel.text = "Inquiry ID: \(inquiry["id"] as! String)"
        
        if let timeInterval = inquiry["createdAt"] as? NSTimeInterval {
            let date = NSDate(timeIntervalSince1970: timeInterval/1000)
            let dayTimePeriodFormatter = NSDateFormatter()
            dayTimePeriodFormatter.dateFormat = "M/d/yyyy h:mm a"
            
            let dateString = dayTimePeriodFormatter.stringFromDate(date)
            cell.dateLabel.text = dateString
        }
        
        cell.configureCell()
        
        return cell
        }
        
        return UITableViewCell()
        
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let inquiry = self.inquiries[indexPath.row] as! [String : AnyObject]
        let inquiryID = inquiry["id"]
        
        GlobalVariables._currentInquiryIDAnswering = inquiryID as! String
        
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("viewInquiryVC")
        self.presentViewController(vc!, animated: false, completion: nil)
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
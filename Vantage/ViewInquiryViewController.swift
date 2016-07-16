//
//  ViewInquiryViewController.swift
//  Vantage
//
//  Created by Parth Saxena on 7/11/16.
//  Copyright © 2016 Socify. All rights reserved.
//

import UIKit
import Firebase

class ViewInquiryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var inquiryTableView: LoadingTableView!
    
    var inquiry = NSMutableArray()
    
    var inquiryTitle: String!
    var inquiryContent: String!
    var inquiryID: String!
    var inquiryCreatedAt: AnyObject!
    var inquiryImage: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController!.navigationBar.barTintColor = UIColor.blackColor()
        self.navigationController!.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Roboto", size: 30)!, NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        self.title = "Inquiry In \(GlobalVariables._currentSubjectPostingTo)"
        
        self.inquiryTableView.dataSource = self
        self.inquiryTableView.delegate = self
        
        self.inquiryTableView.showLoadingIndicator()
        loadData()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    func loadData() {
        let inquiryID = GlobalVariables._currentInquiryIDAnswering
        let inquiryRef = FIRDatabase.database().reference().child("posts").queryOrderedByChild("id").queryEqualToValue(inquiryID).queryLimitedToFirst(1).observeEventType(.Value, withBlock: { (snapshot) in
            if let inquiryDictionary = snapshot.value as? [String : AnyObject] {
                if let inquiry = inquiryDictionary.first!.1 as? [String : AnyObject] {
                    self.inquiry.addObject(inquiry)
                    self.inquiryTableView.reloadData()
                    self.inquiryTableView.hideLoadingIndicator()
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
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! ViewInquiryTableViewCell

        let inquiry = self.inquiry[indexPath.row] as! [String : AnyObject]
        
        cell.titleLabel.text = inquiry["title"] as? String
        cell.contentTextView.text = inquiry["content"] as? String
        cell.inquiryIDLabel.text = "Inquiry ID: \(inquiry["id"] as! String)"
        
        if let timeInterval = inquiry["createdAt"] as? NSTimeInterval {
            let date = NSDate(timeIntervalSince1970: timeInterval/1000)
            let dayTimePeriodFormatter = NSDateFormatter()
            dayTimePeriodFormatter.dateFormat = "M/d/yyyy h:mm a"
            
            let dateString = dayTimePeriodFormatter.stringFromDate(date)
            cell.dateLabel.text = dateString
        }
        
        let image = inquiry["image"] as! String
        let imageRef = FIRStorage.storage().referenceForURL("gs://vantage-e9003.appspot.com").child("images/\(image).jpg")
        imageRef.dataWithMaxSize(5 * 1024 * 1024) { (data, error) -> Void in
            if error == nil {
                let image = UIImage(data: data!)
                cell.inquiryImage.image = image
                
                cell.inquiryIDLabel.alpha = 0
                cell.dateLabel.alpha = 0
                cell.titleLabel.alpha = 0
                cell.inquiryImage.alpha = 0
                cell.contentTextView.alpha = 0
                
                UIView.animateWithDuration(0.4) {
                    cell.inquiryIDLabel.alpha = 1
                    cell.dateLabel.alpha = 1
                    cell.titleLabel.alpha = 1
                    cell.inquiryImage.alpha = 1
                    cell.contentTextView.alpha = 1
                }
                self.inquiryTableView.hideLoadingIndicator()
            } else {
                // error
                NSLog("Error while downloading an image.")
            }
        }
       
        return cell                
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

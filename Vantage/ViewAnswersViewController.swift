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

    let answers = NSMutableArray()
    
    @IBOutlet weak var answersTableView: LoadingTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController!.navigationBar.barTintColor = UIColor.whiteColor()
        self.navigationController!.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Roboto", size: 30)!, NSForegroundColorAttributeName: UIColor.blackColor()]
        
        self.answersTableView.delegate = self
        self.answersTableView.dataSource = self
        
        self.answersTableView.showLoadingIndicator()
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
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! AnswerTableViewCell
        print("Viewing answers...")
        let answer = self.answers[indexPath.row] as! [String : AnyObject]
        
        let image = answer["image"] as! String
        let imageRef = FIRStorage.storage().referenceForURL("gs://vantage-e9003.appspot.com").child("images/\(image).jpg")
        imageRef.dataWithMaxSize(5 * 1024 * 1024) { (data, error) -> Void in
            if error == nil {
                let image = UIImage(data: data!)
                
                cell.answerImageView.image = image
                cell.answerTextView.text = answer["content"] as! String
                if let timeInterval = answer["createdAt"] as? NSTimeInterval {
                    let date = NSDate(timeIntervalSince1970: timeInterval/1000)
                    let dayTimePeriodFormatter = NSDateFormatter()
                    dayTimePeriodFormatter.dateFormat = "M/d/yyyy h:mm a"
                    
                    let dateString = dayTimePeriodFormatter.stringFromDate(date)
                    cell.dateLabel.text = dateString
                }
                
                cell.configureCell()
                
                self.answersTableView.hideLoadingIndicator()
            } else {
                // error
                NSLog("Error while downloading an image.")
                
            }
        }
        
        return cell
    }

    func loadAnswers() {
         FIRDatabase.database().reference().child("answers").queryOrderedByChild("inquiryID").queryEqualToValue(GlobalVariables._currentInquiryIDAnswering!).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            if let inquiryDictionary = snapshot.value as? [String : AnyObject] {
                
                for answer in inquiryDictionary {
                    self.answers.insertObject(answer.1, atIndex: 0)
                }
                self.answersTableView.reloadData()
            }
        })
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

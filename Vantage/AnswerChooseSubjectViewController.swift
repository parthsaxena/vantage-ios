//
//  AnswerChooseSubjectViewController.swift
//  Vantage
//
//  Created by Parth Saxena on 7/10/16.
//  Copyright © 2016 Socify. All rights reserved.
//

import UIKit
import Firebase

class AnswerChooseSubjectViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var subjectsTableView: LoadingTableView!
    
    let sections = NSMutableArray()
    let items = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController!.navigationBar.barTintColor = UIColor.whiteColor()
        self.navigationController!.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Roboto", size: 30)!, NSForegroundColorAttributeName: UIColor.blackColor()]
        
        self.subjectsTableView.delegate = self
        self.subjectsTableView.dataSource = self
        self.subjectsTableView.showLoadingIndicator()
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
        FIRDatabase.database().reference().child("subjects").observeEventType(.Value, withBlock: { (snapshot) in
            self.items.removeAllObjects()
            self.sections.removeAllObjects()
            
            let subjectDictionary = snapshot.value as! [String : AnyObject]
            for subject in subjectDictionary {
                print(subject.0)
                let masterSubject = subject.0 as? String
                self.sections.addObject(masterSubject!)
                
                let actualSubjectDictionary = subject.1 as! [String : AnyObject]
                let subjectString = actualSubjectDictionary.first!.1 as! String
                let subjectsArray = subjectString.characters.split{$0 == ","}.map(String.init)
                
                var currentSubjectMutableArray = NSMutableArray()
                for realSubject in subjectsArray {
                    currentSubjectMutableArray.addObject(realSubject)
                    print(realSubject)
                }
                self.items.addObject(currentSubjectMutableArray)
            }
            self.subjectsTableView.reloadData()
            self.subjectsTableView.hideLoadingIndicator()
        })
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.sections.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items[section].count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sections[section] as! String
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        // Configure the cell...
        
        let cellSubject = (self.items[indexPath.section] as! NSMutableArray)[indexPath.row]
        
        cell.textLabel!.text = cellSubject as! String
        
        cell.textLabel?.alpha = 0
        
        UIView.animateWithDuration(0.4) {
            cell.textLabel?.alpha = 1
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cellSubject = (self.items[indexPath.section] as! NSMutableArray)[indexPath.row] as! String
        
        GlobalVariables._currentSubjectPostingTo = cellSubject
        
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("inquiriesVC")
        self.presentViewController(vc!, animated: false, completion: nil)
    }
    
    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

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

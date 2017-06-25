//
//  AnswerChooseSubjectViewController.swift
//  Vantage
//
//  Created by Parth Saxena on 7/10/16.
//  Copyright © 2016 Socify. All rights reserved.
//

import UIKit
import Firebase
import GoogleMobileAds
import Armchair
import NVActivityIndicatorView

class AnswerChooseSubjectViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, GADBannerViewDelegate {

    @IBOutlet weak var subjectsTableView: UITableView!
    
    @IBOutlet weak var bannerView: GADBannerView!
    let sections = NSMutableArray()
    let items = NSMutableArray()
    
    var activityIndicatorView: NVActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let request = GADRequest()
        request.testDevices = [kGADSimulatorID]
        bannerView.delegate = self
        bannerView.adUnitID = "ca-app-pub-7685378724367635/9077439904"
        bannerView.rootViewController = self
        bannerView.load(request)
        
        self.navigationController!.navigationBar.barTintColor = UIColor.white
        self.navigationController!.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Roboto", size: 30)!, NSForegroundColorAttributeName: UIColor.black]
        
        activityIndicatorView = NVActivityIndicatorView(frame: self.view.frame, type: .ballRotate, color: UIColor.lightGray, padding: CGFloat(100))
        activityIndicatorView.alpha = 0
        self.view.addSubview(activityIndicatorView)
        UIView.animate(withDuration: 0.1, animations: { 
            self.activityIndicatorView.alpha = 1
        }) { (success) in
            self.subjectsTableView.separatorStyle = .none
        }
        self.subjectsTableView.delegate = self
        self.subjectsTableView.dataSource = self
        //self.subjectsTableView.showLoadingIndicator()
        activityIndicatorView.startAnimating()
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
        FIRDatabase.database().reference().child("subjects").observe(.value, with: { (snapshot) in
            self.items.removeAllObjects()
            self.sections.removeAllObjects()
            
            let subjectDictionary = snapshot.value as! [String : AnyObject]
            for subject in subjectDictionary {
                print(subject.0)
                if let masterSubject = subject.0 as? String {
                    self.sections.add(masterSubject)
                }
                
                let actualSubjectDictionary = subject.1 as! [String : AnyObject]
                if let subjectString = actualSubjectDictionary["subjects"] as? String {
                    // let subjectString = actualSubjectDictionary.first!.1 as! String
                    let subjectsArray = subjectString.characters.split{$0 == ","}.map(String.init)
                    
                    var currentSubjectMutableArray = NSMutableArray()
                    for realSubject in subjectsArray {
                        currentSubjectMutableArray.add(realSubject)
                        print(realSubject)
                    }
                    self.items.add(currentSubjectMutableArray)
                }
            }
            self.subjectsTableView.reloadData()
            if let scrollPosition = GlobalVariables._answerChooseSubjectContentOffset {
                self.subjectsTableView.contentOffset = scrollPosition
            }
            self.activityIndicatorView.stopAnimating()
            UIView.animate(withDuration: 0.1, animations: { 
                self.activityIndicatorView.alpha = 0
            }, completion: { (success) in
                self.subjectsTableView.separatorStyle = .singleLine
            })
        })
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.items[section] as AnyObject).count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sections[section] as! String
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CellSubjectTableViewCell
        // Configure the cell...
        
        if let cellSubject = (self.items[indexPath.section] as! NSMutableArray)[indexPath.row] as? String {
        
        cell.subjectLabel.text = "     \(cellSubject)"
        
        cell.subjectLabel?.alpha = 0
        
        UIView.animate(withDuration: 0.4, animations: {
            cell.subjectLabel?.alpha = 1
        })
        
        DispatchQueue.main.async {
            FIRDatabase.database().reference().child("posts").queryOrdered(byChild: "subject").queryEqual(toValue: cellSubject).observeSingleEvent(of: .value, with: { (snapshot) in
                if let rawInquiries = snapshot.value as? [String: Any] {
                    var activeCount = 0
                    for rawInquiry in rawInquiries {
                        if let rawInquiryValue = rawInquiry.value as? [String: Any] {
                            if rawInquiryValue["active"] as? String == "true" {
                                // found one active inquiry
                                activeCount+=1
                            }
                        }
                    }
                    // we have the final active count
                    if activeCount != 1 {
                        cell.inquiriesCountLabel?.text = "(\(activeCount) inquiries)"
                    } else {
                        // one inquiry
                        cell.inquiriesCountLabel?.text = "(\(activeCount) inquiry)"
                    }
                    //cell.textLabel?.text = "\(cell.textLabel?.text) - (\(activeCount))"
                }
            })
        }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let array = self.items[indexPath.section] as? NSMutableArray {
            if let cellSubject = array[indexPath.row] as? String {
                print("SELECTED: \(cellSubject)")
                
                GlobalVariables._currentSubjectPostingTo = cellSubject
                GlobalVariables._answerChooseSubjectContentOffset = self.subjectsTableView.contentOffset
                
                print("SELECTED1: \(GlobalVariables._currentSubjectPostingTo)")
                
                //Armchair.userDidSignificantEvent(false)
                
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "inquiriesVC")
                self.present(vc!, animated: false, completion: nil)
            }
        }
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

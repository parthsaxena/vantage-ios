//
//  InquiriesViewController.swift
//  Vantage
//
//  Created by Parth Saxena on 7/10/16.
//  Copyright © 2016 Socify. All rights reserved.
//

import UIKit
import Firebase
import GoogleMobileAds
import NVActivityIndicatorView

class InquiriesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, GADBannerViewDelegate {

    var inquiries = NSMutableArray()
    
    @IBOutlet weak var inquiriesTableView: UITableView!
    @IBOutlet weak var bannerView: GADBannerView!
    
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
        
        self.title = "\(GlobalVariables._currentSubjectPostingTo)"
        
        activityIndicatorView = NVActivityIndicatorView(frame: self.view.frame, type: .ballRotate, color: UIColor.lightGray, padding: CGFloat(100))
        activityIndicatorView.alpha = 0
        self.view.addSubview(activityIndicatorView)
        UIView.animate(withDuration: 0.1) {
            self.activityIndicatorView.alpha = 1
        }
        
        self.inquiriesTableView.dataSource = self
        self.inquiriesTableView.delegate = self
        self.inquiriesTableView.alpha = 0
        self.activityIndicatorView.startAnimating()
        //self.inquiriesTableView.showLoadingIndicator()
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
        let ref = FIRDatabase.database().reference().child("posts").queryOrdered(byChild: "subject").queryEqual(toValue: GlobalVariables._currentSubjectPostingTo)
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            if let inquiryDictionary = snapshot.value as? [String : AnyObject] {
                
                if inquiryDictionary.count == 0 {
                    self.inquiries.add("none")
                    self.inquiriesTableView.reloadData()
                    UIView.animate(withDuration: 0.1, animations: {
                        self.activityIndicatorView.alpha = 0
                        self.inquiriesTableView.alpha = 1
                        }, completion: { (success) in
                            self.activityIndicatorView.stopAnimating()
                    })
                    
                    NSLog("No inquiries found.")
                } else {
                    NSLog("Inquiries found.")
                    
                    let sortedDictionary = inquiryDictionary.sorted {
                        let createdAtOne = ($0.1 as! [String : AnyObject])["createdAt"] as! Int
                        let createdAtTwo = ($1.1 as! [String : AnyObject])["createdAt"] as! Int
                        return createdAtOne > createdAtTwo
                    }
                    print(sortedDictionary)
                    
                    for object in sortedDictionary {                        
                        print(object.1)
                        if ((object.1 as! [String: AnyObject])["active"] as? String == "true" && (object.1 as! [String: AnyObject])["username"] as? String != FIRAuth.auth()?.currentUser?.uid) {
                            self.inquiries.add(object.1)
                        }
                    }
                    
                    if (self.inquiries.count == 0) {
                        self.inquiries.add("none")
                        self.inquiriesTableView.reloadData()
                        UIView.animate(withDuration: 0.1, animations: {
                            self.activityIndicatorView.alpha = 0
                            self.inquiriesTableView.alpha = 1
                            }, completion: { (success) in
                                self.activityIndicatorView.stopAnimating()
                        })
                    } else {
                        self.inquiriesTableView.reloadData()
                        UIView.animate(withDuration: 0.1, animations: {
                            self.activityIndicatorView.alpha = 0
                            self.inquiriesTableView.alpha = 1
                            }, completion: { (success) in
                                self.activityIndicatorView.stopAnimating()
                        })
                    }
                }
            } else {
                self.inquiries.add("none")
                self.inquiriesTableView.reloadData()
                UIView.animate(withDuration: 0.1, animations: {
                    self.activityIndicatorView.alpha = 0
                    self.inquiriesTableView.alpha = 1
                    }, completion: { (success) in
                        self.activityIndicatorView.stopAnimating()
                })
                
                NSLog("No inquiries found.")
            }
        })
        
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.inquiries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! InquiryTableViewCell
        
        if let inquiry = self.inquiries[indexPath.row] as? String {
            if inquiry == "none" {
                cell.textLabel!.text = "There are currently no active inquiries in \(GlobalVariables._currentSubjectPostingTo)."
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                cell.textLabel!.numberOfLines = 0
                self.inquiriesTableView.separatorStyle = .none
                return cell
            }
        } else {
        
        let inquiry = self.inquiries[indexPath.row] as! [String : AnyObject]
        cell.titleLabel.text = inquiry["title"] as! String
        if let coins = inquiry["coins"] as? Int {
            cell.coinsLabel.text = "\(coins) coins"
        }
        
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

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let inquiry = self.inquiries[indexPath.row] as? [String : AnyObject] {
            let inquiryID = inquiry["id"]
        
            GlobalVariables._currentInquiryIDAnswering = inquiryID as! String
        
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "viewInquiryVC")
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

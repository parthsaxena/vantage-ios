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
    @IBOutlet weak var subscribeButton: UIBarButtonItem!
    
    var activityIndicatorView: NVActivityIndicatorView!
    
    var isUserSubscribed = false
    
    func checkIfSubscribed() {
        OneSignal.getTags({ tags in
            print("GOT USER'S TAGS, \(tags)")
            var alreadyHasSubscription = false
            if let subscriptionValue = tags?[GlobalVariables._currentSubjectPostingTo] as? String {
                if subscriptionValue == "subscribed" {
                    alreadyHasSubscription = true
                }
            }
            if alreadyHasSubscription {
                self.isUserSubscribed = true
                DispatchQueue.main.async {
                    let font:UIFont = UIFont.systemFont(ofSize: 17.0)
                    let attributes:[String : Any] = [NSFontAttributeName: font]
                    self.subscribeButton.setTitleTextAttributes(attributes, for: UIControlState.normal)
                    self.subscribeButton.title = "Unsubscribe"
                    self.subscribeButton.tintColor = UIColor.red
                }
            } else {
                DispatchQueue.main.async {
                    let font:UIFont = UIFont.boldSystemFont(ofSize: 17.0);
                    let attributes:[String : Any] = [NSFontAttributeName: font]
                    self.subscribeButton.setTitleTextAttributes(attributes, for: UIControlState.normal)
                    self.subscribeButton.title = "Subscribe"
                }
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkIfSubscribed()
        
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
        self.inquiriesTableView.tableFooterView = UIView()
        
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
                if hours >= 24 {
                    // more than or equal to one day
                    let days = Int(hours/24)
                    let remainderHours = Int(hours % 24)
                    print("DAYS: \(days), REMAINDER HOURS: \(remainderHours)")
                    cell.dateLabel.text = "\(days)d, \(remainderHours)h ago"
                } else {
                    cell.dateLabel.text = "\(hours)h, \(minutes)m ago"
                }
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

    @IBAction func subscribeTapped(sender: Any) {
        if !isUserSubscribed {
            // subscribe user
            let loadingAlert = UIAlertController(title: "Subscribing...", message: nil, preferredStyle: .alert)
            self.present(loadingAlert, animated: true, completion: nil)
            OneSignal.sendTag(GlobalVariables._currentSubjectPostingTo, value: "subscribed", onSuccess: { (success) in
                print("Successfully saved tags.")
                loadingAlert.dismiss(animated: true, completion: nil)
                let successAlert = UIAlertController(title: "Awesome!", message: "You are now subscribed to \(GlobalVariables._currentSubjectPostingTo)!", preferredStyle: .alert)
                successAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(successAlert, animated: true, completion: nil)
                let font:UIFont = UIFont.systemFont(ofSize: 17.0)
                let attributes:[String : Any] = [NSFontAttributeName: font]
                self.subscribeButton.setTitleTextAttributes(attributes, for: UIControlState.normal)
                self.subscribeButton.title = "Unsubscribe"
                self.subscribeButton.tintColor = UIColor.red
                self.isUserSubscribed = true
            }, onFailure: { (error) in
                print("Error saving tag, \(error?.localizedDescription)")
                loadingAlert.dismiss(animated: true, completion: nil)
                let errorAlert = UIAlertController(title: "Whoops!", message: "There was an issue subscribing you to \(GlobalVariables._currentSubjectPostingTo). Please try again later!", preferredStyle: .alert)
                errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                errorAlert.view.tintColor = UIColor.red
                self.present(errorAlert, animated: true, completion: nil)
            })
        } else {
            // unsubscribe user
            let loadingAlert = UIAlertController(title: "Unsubscribing...", message: nil, preferredStyle: .alert)
            self.present(loadingAlert, animated: true, completion: nil)
            OneSignal.deleteTag(GlobalVariables._currentSubjectPostingTo, onSuccess: { (success) in
                loadingAlert.dismiss(animated: true, completion: nil)
                let alert = UIAlertController(title: "Success", message: "You have been unsubscribed from \(GlobalVariables._currentSubjectPostingTo).", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                let font:UIFont = UIFont.boldSystemFont(ofSize: 17.0);
                let attributes:[String : Any] = [NSFontAttributeName: font]
                self.subscribeButton.setTitleTextAttributes(attributes, for: UIControlState.normal)
                self.subscribeButton.title = "Subscribe"
                self.subscribeButton.tintColor = self.view.tintColor
                self.isUserSubscribed = false
            }, onFailure: { (error) in
                loadingAlert.dismiss(animated: true, completion: nil)
                let alert = UIAlertController(title: "Error", message: "There was an issue unsubscribing you from this subject.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                alert.view.tintColor = UIColor.red
                self.present(alert, animated: true, completion: nil)
            })
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

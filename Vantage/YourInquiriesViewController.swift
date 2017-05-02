
//
//  YourInquiriesViewController.swift
//  
//
//  Created by Parth Saxena on 7/16/16.
//
//

import UIKit
import Firebase
import GoogleMobileAds
import NVActivityIndicatorView

class YourInquiriesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, GADBannerViewDelegate {

    var inquiries = NSMutableArray()
    
    @IBOutlet weak var bannerView: GADBannerView!
    @IBOutlet weak var inquiriesTableView: UITableView!
    
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
        
        self.title = "Your Inquiries"
        
        activityIndicatorView = NVActivityIndicatorView(frame: self.view.frame, type: .ballRotate, color: UIColor.lightGray, padding: CGFloat(100))
        activityIndicatorView.alpha = 0
        self.view.addSubview(activityIndicatorView)
        self.inquiriesTableView.alpha = 0
        UIView.animate(withDuration: 0.1) {
            self.activityIndicatorView.alpha = 1
        }

        
        self.inquiriesTableView.dataSource = self
        self.inquiriesTableView.delegate = self
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

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.inquiries.count
    }

    func loadData() {
        let currentUID = FIRAuth.auth()?.currentUser?.uid
        
        FIRDatabase.database().reference().child("posts").queryOrdered(byChild: "username").queryEqual(toValue: currentUID).observeSingleEvent(of: .value, with: { (snapshot) in
            self.inquiries.removeAllObjects()
            
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
                    
                    print("No inquiries found.")
                } else {
                    let sortedDictionary = inquiryDictionary.sorted {
                        let createdAtOne = ($0.1 as! [String : AnyObject])["createdAt"] as! Int
                        let createdAtTwo = ($1.1 as! [String : AnyObject])["createdAt"] as! Int
                        return createdAtOne > createdAtTwo
                    }
                    //print(sortedDictionary)
                    
                    for inquiry in sortedDictionary {
                        let inquiryDictionary = inquiry.value as? [String: AnyObject]
                        let activeValue = inquiryDictionary?["active"] as? String
                        if (activeValue == "discarded") {
                            //print("DISCARDED VALUE: \(inquiry.1["active"]), INQUIRY ID: \(inquiry.1["id"])")
                        } else {
                            print("DISCARDED VALUE: \(activeValue), INQUIRY ID: \(inquiryDictionary?["id"] as? String)")
                            self.inquiries.add(inquiry.1)
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
                        
                        print("No inquiries found.")
                    } else {
                        UIView.animate(withDuration: 0.1, animations: {
                            self.activityIndicatorView.alpha = 0
                            self.inquiriesTableView.alpha = 1
                            }, completion: { (success) in
                                self.activityIndicatorView.stopAnimating()
                        })
                        self.inquiriesTableView.reloadData()
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
                
                print("No inquiries found.")
            }
        })
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! InquiryTableViewCell
        
        if let inquiry = self.inquiries[indexPath.row] as? String {
            if inquiry == "none" {
                cell.textLabel!.text = "You do not have any inquiries :("
                cell.textLabel!.numberOfLines = 0
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                self.inquiriesTableView.separatorStyle = .none
                cell.answersLabel?.isHidden = true
                return cell
            }
        } else {
            
            let inquiry = self.inquiries[indexPath.row] as! [String : AnyObject]
            
            print("inquiry ID: \(inquiry["id"] as! String)")
            let answersRef = FIRDatabase.database().reference().child("answers").queryOrdered(byChild: "inquiryID").queryEqual(toValue: inquiry["id"] as! String).observeSingleEvent(of: .value, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String : Any] {
                    print("ANSWERS COUNT: \(dictionary.count)")
                    let actualAnswers = NSMutableArray()
                    var inquiryAnswered = false
                    for answer in dictionary {
                        let answerDict = answer.value as? [String: Any]
                        if (answerDict?["accepted"] as? String == "true") {
                            cell.answersLabel!.text = "✓"
                            cell.answersLabel!.font = UIFont(name: "Helvetica", size: 27.0)
                            //cell.answersLabel!.textColor = UIColor(red: 37, green: 165, blue: 91, alpha: 1)
                            inquiryAnswered = true
                            break
                        } else if (answerDict?["accepted"] as? String == "none") {
                            actualAnswers.add(answer.1)
                        } else {
                            print("accepted value: \(answer.1)")
                        }
                    }
                    if (inquiryAnswered == false) {
                        if actualAnswers.count != 0 {
                            if actualAnswers.count == 1 {
                                cell.answersLabel!.text = "\(actualAnswers.count) Answer"
                            } else {
                                cell.answersLabel!.text = "\(actualAnswers.count) Answers"
                            }
                    
                        } else {
                            cell.answersLabel!.text = "No Answers"
                            cell.answersLabel!.textColor = UIColor.red
                        }
                    }
                } else {
                    cell.answersLabel!.text = "No Answers"
                    cell.answersLabel!.textColor = UIColor.red
                }
            })
            
            cell.titleLabel.text = inquiry["title"] as! String
            //cell.usernameLabel.text = "Inquiry ID: \(inquiry["id"] as! String)"
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
            let inquirySubject = inquiry["subject"]
        
            GlobalVariables._currentSubjectPostingTo = inquirySubject as! String
            GlobalVariables._currentInquiryIDAnswering = inquiryID as! String
        
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "viewOwnInquiryVC")
            self.present(vc!, animated: false, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .normal, title: "Discard") { action, index in
            let masterAlert = UIAlertController(title: "Please Wait...", message: nil, preferredStyle: .alert)
            self.present(masterAlert, animated: true, completion: nil)
            
            let inquiry = self.inquiries[indexPath.row] as! [String : AnyObject]
            let inquiryID = inquiry["id"]
            
            FIRDatabase.database().reference().child("posts").queryOrdered(byChild: "id").queryEqual(toValue: inquiryID).observeSingleEvent(of: .value, with: { (snapshot) in
                if let inquiryDictionary = snapshot.value as? [String : AnyObject] {
                    if inquiryDictionary.count == 0 {
                        masterAlert.dismiss(animated: true, completion: {
                            DispatchQueue.main.async(execute: { 
                                let alert = PSAlert.sharedInstance.instantiateAlert("Error", alertText: "There was an error discarding your inquiry.")
                                print("something serious just went wrong...")
                            })
                        })
                    } else {
                        //masterAlert.dismissViewControllerAnimated(true, completion: nil)
                        for inquiry in inquiryDictionary {
                            FIRDatabase.database().reference().child("answers").queryOrdered(byChild: "inquiryID").queryEqual(toValue: inquiry.1["id"]).observeSingleEvent(of: .value, with: { (snapshot) in
                                print("going through 1")
                                if let dict = snapshot.value as? [String : AnyObject] {
                                    print("going through 1 \(dict.count), \(inquiry.1["active"])")
                                    var nonRejectedAnswers = 0
                                    for answer in dict {
                                        if answer.1["accepted"] as? String == "none" {
                                            nonRejectedAnswers += 1
                                        }
                                    }
                                    if inquiry.1["active"] as? String == "true" && nonRejectedAnswers > 0 {
                                        print("INQUIRY HAS ANSWERS BUT IS TRYING TO BE DISCARDED")
                                        masterAlert.dismiss(animated: true, completion: { 
                                            DispatchQueue.main.async(execute: { 
                                                let alert = UIAlertController(title: "Error", message: "There are answers for this inquiry that you have not accepted or rejected yet. Please accept or reject an answer before discarding this inquiry.", preferredStyle: .alert)
                                                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                                alert.view.tintColor? = UIColor.red
                                                self.present(alert, animated: true, completion: nil)
                                            })
                                        })
                                    } else {
                                        print("DICT COUNT: \(dict.count), ACTIVE: \(inquiry.1["active"]), ACCEPTED: \(nonRejectedAnswers)")
                                        masterAlert.dismiss(animated: true, completion: { 
                                            DispatchQueue.main.async(execute: { 
                                                let alert = UIAlertController(title: "Confirm", message: "Are you sure you would like to discard this inquiry?", preferredStyle: .alert)
                                                alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                                                    FIRDatabase.database().reference().child("posts").child(inquiry.0).updateChildValues(["active":"discarded"])
                                                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "mainVC")
                                                    self.present(vc!, animated: false, completion: nil)
                                                }))
                                                alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
                                                self.present(alert, animated: true, completion: nil)
                                            })
                                        })
                                    }
                                } else {
                                    print(inquiry.1["id"])
                                    masterAlert.dismiss(animated: true, completion: {
                                        DispatchQueue.main.async(execute: {
                                            let alert = UIAlertController(title: "Confirm", message: "Are you sure you would like to discard this inquiry?", preferredStyle: .alert)
                                            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                                                FIRDatabase.database().reference().child("posts").child(inquiry.0).updateChildValues(["active":"discarded"])
                                                let vc = self.storyboard?.instantiateViewController(withIdentifier: "mainVC")
                                                self.present(vc!, animated: false, completion: nil)
                                            }))
                                            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
                                            self.present(alert, animated: true, completion: nil)
                                        })

                                    })                                                                 }
                            })
                        }
                    }
                } else {
                    //masterAlert.dismissViewControllerAnimated(true, completion: nil)
                    let alert = PSAlert.sharedInstance.instantiateAlert("Error", alertText: "There was an error discarding your inquiry.")
                    print("something serious just went wrong...")
                }
            })
        }
        delete.backgroundColor = UIColor.red
        
        return [delete]
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // the cells you would like the actions to appear needs to be editable
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
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

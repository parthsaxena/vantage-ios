//
//  ViewInquiryViewController.swift
//  Vantage
//
//  Created by Parth Saxena on 7/11/16.
//  Copyright © 2016 Socify. All rights reserved.
//

import UIKit
import Firebase
import NVActivityIndicatorView
import SDWebImage

class ViewInquiryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var inquiryTableView: UITableView!
    
    var inquiry = NSMutableArray()
        
    var inquiryTitle: String!
    var inquiryContent: String!
    var inquiryID: String!
    var inquiryCreatedAt: AnyObject!
    var inquiryImage: String!
    
    var currentImageDisplaying = UIImage()
    
    var activityIndicatorView: NVActivityIndicatorView!
    
    func viewedInquiryYet(_ key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
    
    func presentAlert() {
        let alert = UIAlertController(title: "Hint", message: "Tap on the image to zoom in.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Got it!", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
        
        activityIndicatorView = NVActivityIndicatorView(frame: self.view.frame, type: .ballRotate, color: UIColor.lightGray, padding: CGFloat(100))
        activityIndicatorView.alpha = 0
        self.view.addSubview(activityIndicatorView)
        UIView.animate(withDuration: 0.1) {
            self.activityIndicatorView.alpha = 1
        }

        self.inquiryTableView.dataSource = self
        self.inquiryTableView.delegate = self
        self.activityIndicatorView.startAnimating()
        //self.inquiryTableView.showLoadingIndicator()
        loadData()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    func loadData() {
        let inquiryID = GlobalVariables._currentInquiryIDAnswering
        self.inquiryID = inquiryID
        let inquiryRef = FIRDatabase.database().reference().child("posts").queryOrdered(byChild: "id").queryEqual(toValue: inquiryID).queryLimited(toFirst: 1).observe(.value, with: { (snapshot) in
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

    func imageTapped(_ sender: UITapGestureRecognizer) {
        NSLog("image tapped")
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
    
    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return inquiry.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ViewInquiryTableViewCell

        let inquiry = self.inquiry[indexPath.row] as! [String : AnyObject]                
        
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
                    cell.dateLabel.text = "\(minutes) minute ago"
                } else {
                    cell.dateLabel.text = "\(minutes) minutes ago"
                }
            }
        }
        
        let imageName = inquiry["image"] as! String
        let imageRef = FIRStorage.storage().reference(forURL: "gs://vantage-e9003.appspot.com").child("images/\(imageName)")
        
        imageRef.data(withMaxSize: 25 * 1024 * 1024) { (data, error) -> Void in
            if error == nil {
                let image = UIImage(data: data!)
                self.currentImageDisplaying = image!
                cell.inquiryImage.displayImage(image!)
                
                if (imageName != "NO_IMAGE_WHITE.jpg") {
                    NSLog("image value: \(imageName)")
                    cell.inquiryImage.isUserInteractionEnabled = true
                    cell.inquiryImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ViewInquiryViewController.imageTapped(_:))))
                }
                
                cell.inquiryIDLabel.alpha = 0
                cell.dateLabel.alpha = 0
                cell.titleLabel.alpha = 0
                cell.inquiryImage.alpha = 0
                cell.contentTextView.alpha = 0
                cell.answerButton.alpha = 0
                cell.chatButton.alpha = 0
                cell.chatButtonImageView.alpha = 0
                
                UIView.animate(withDuration: 0.4, animations: {
                    cell.inquiryIDLabel.alpha = 1
                    cell.dateLabel.alpha = 1
                    cell.titleLabel.alpha = 1
                    cell.inquiryImage.alpha = 1
                    cell.contentTextView.alpha = 1
                    cell.answerButton.alpha = 1
                    cell.chatButton.alpha = 1
                    cell.chatButtonImageView.alpha  = 1
                }) 
                DispatchQueue.main.async(execute: {
                    UIView.animate(withDuration: 0.1, animations: {
                        self.activityIndicatorView.alpha = 0
                        }, completion: { (success) in
                            self.activityIndicatorView.stopAnimating()
                    })
                })
                //self.inquiryTableView.hideLoadingIndicator()
            } else {
                // error
                NSLog("Error while downloading an image. Error: \(error?.localizedDescription)")
            }
        }
       
        return cell                
    }
    
    /*func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 {
            UIView.animateWithDuration(0.1, animations: {
                self.activityIndicatorView.alpha = 0
                }, completion: { (success) in
                    self.activityIndicatorView.stopAnimating()
            })
        }
    }*/
    
    @IBAction func answerTapped(_ sender: AnyObject) {
        let inquiry = self.inquiry[0] as! [String : AnyObject]
        let username = inquiry["username"]
        GlobalVariables._currentUserAnswering = username as! String
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "answerVC")
        self.present(vc!, animated: false, completion: nil)
    }
    
    func doesUserAlreadyHaveChat(with: String, forID: String, completion: @escaping (Bool) -> Void) {
        FIRDatabase.database().reference().child("chats").queryOrdered(byChild: "uidOne").queryEqual(toValue: FIRAuth.auth()?.currentUser?.uid).observeSingleEvent(of: .value, with: { (snapshot) in
            var hasChat = false
            if let chatsDictionary = snapshot.value as? [String: Any] {
                if chatsDictionary.count > 0 {
                    for chat in chatsDictionary {
                        if (chat.value as? [String: Any])?["uidTwo"] as? String == with && (chat.value as? [String: Any])?["inquiryID"] as? String == forID {
                            // USER ALREADY HAS CHAT WITH THIS USER
                            hasChat = true
                            completion(true)
                        } else {
                            print("NOT CHAT: \(with)")
                        }
                    }
                    if !hasChat {
                        completion(false)
                    }
                } else {
                    completion(false)
                }
            } else {
                completion(false)
            }
        })

    }
    
    @IBAction func chatTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Confirm", message: "Are you sure you would like to start a chat with this user?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            // yes tapped
            
            let inquiry = self.inquiry[0] as! [String : AnyObject]
            let username = inquiry["username"] as? String
            
            self.doesUserAlreadyHaveChat(with: username!, forID: self.inquiryID, completion: { (hasChat) in
                if hasChat {
                    let alert = UIAlertController(title: "Sorry!", message: "You already have a chat with this user!", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    alert.view.tintColor = UIColor.red
                    self.present(alert, animated: true, completion: nil)
                    
                    print("USER ALREADY HAS A CHAT WITH THIS USER.")
                    
                } else {
                    
                    print("USER HAS NOT STARTED CHAT WITH THIS USER.")
                    
                    let title = inquiry["title"]
                    let uid = FIRAuth.auth()?.currentUser?.uid
                    let timestamp = FIRServerValue.timestamp()
                    let object = [
                        "createdAt": timestamp as AnyObject,
                        "latestTimestamp": timestamp as AnyObject,
                        "uidOne": uid,
                        "uidTwo": username,
                        "inquiryTitle": title,
                        "latestMessage": "",
                        "inquiryID": self.inquiryID,
                        ] as [String : Any]
                    let chatsRef = FIRDatabase.database().reference().child("chats").childByAutoId()
                    chatsRef.setValue(object)
                    chatsRef.child("messages").childByAutoId().setValue([
                        "createdAt": timestamp as AnyObject,
                        "message": "Hey, I saw your inquiry!",
                        "uid": FIRAuth.auth()?.currentUser?.uid
                        ])
                    chatsRef.updateChildValues([
                        "latestMessage": "Hey, I saw your inquiry!",
                        "latestTimestamp": timestamp as AnyObject
                        ])
                    // created chat
                    let chatID = chatsRef.key
                    GlobalVariables._chatID = chatID
                    GlobalVariables._isStartingNewChat = true
                    if let uidNotification = username as? String {
                        FIRDatabase.database().reference().child("users").child(uidNotification).observe(.value, with: { (snapshot) in
                            if let userDictionary = snapshot.value as? [String: Any] {
                                if let notificationID = userDictionary["notification_id"] as? String {
                                    OneSignal.postNotification(["contents": ["en": "A responder has started a chat with you!"], "data": ["type":"new-chat"], "include_player_ids": [notificationID]], onSuccess: { (nil) in
                                        print("Sent new-chat notification.")
                                    }) { (error) in
                                        print("Error sending new-chat notification, \(error), \(notificationID)")
                                    }
                                }
                            }
                        })
                    }
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChatVC")
                    self.present(vc!, animated: false, completion: nil)
                }
            })
        }))
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func backTapped(sender: Any) {
        if GlobalVariables._isViewingAllInquiries {
            GlobalVariables._isViewingAllInquiries = false
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ViewAllInquiriesVC")
            self.present(vc!, animated: false, completion: nil)
        } else {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "inquiriesVC")
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

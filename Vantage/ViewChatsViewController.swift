//
//  ViewChatsViewController.swift
//  Vantage
//
//  Created by Parth Saxena on 3/30/17.
//  Copyright © 2017 Socify. All rights reserved.
//

import UIKit
import Firebase
import NVActivityIndicatorView

class ViewChatsViewController: UITableViewController {

    var conversationIDs = NSMutableArray()
    var conversations = NSMutableArray()
    
    var activityIndicatorView: NVActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBar.alpha = 0
        self.navigationController!.navigationBar.barTintColor = UIColor.white
        self.navigationController!.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Roboto", size: 30)!, NSForegroundColorAttributeName: UIColor.black]

        
        loadData()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    func loadChatsUIDOne(completion: @escaping (_ done: Bool) -> Void) {
        FIRDatabase.database().reference().child("chats").queryOrdered(byChild: "uidOne").queryEqual(toValue: FIRAuth.auth()?.currentUser?.uid).observeSingleEvent(of: .value, with: { (snapshot) in
            if let conversationsDictionary = snapshot.value as? [String: Any] {
                print("Found conversations")
                
                let sortedDictionary = conversationsDictionary.sorted {
                    let createdAtOne = ($0.1 as! [String : AnyObject])["latestTimestamp"] as! Int
                    let createdAtTwo = ($1.1 as! [String : AnyObject])["latestTimestamp"] as! Int
                    return createdAtOne > createdAtTwo
                }
                
                for conversation in sortedDictionary {
                    print(conversation)
                    self.conversationIDs.add(conversation.0)
                    self.conversations.add(conversation.1)
                }
                completion(true)
            } else {
                completion(true)
            }
        })
    }
    
    func loadChatsUIDTwo(completion: @escaping (_ done: Bool) -> Void) {
        FIRDatabase.database().reference().child("chats").queryOrdered(byChild: "uidTwo").queryEqual(toValue: FIRAuth.auth()?.currentUser?.uid).observeSingleEvent(of: .value, with: { (snapshot) in
            if let conversationsDictionary = snapshot.value as? [String: Any] {
                
                let sortedDictionary = conversationsDictionary.sorted {
                    let createdAtOne = ($0.1 as! [String : AnyObject])["latestTimestamp"] as! Int
                    let createdAtTwo = ($1.1 as! [String : AnyObject])["latestTimestamp"] as! Int
                    return createdAtOne > createdAtTwo
                }
                
                for conversation in sortedDictionary {
                    self.conversationIDs.add(conversation.0)
                    self.conversations.add(conversation.1)
                }
                completion(true)
            } else {
                completion(true)
            }
        })
    }
    
    func loadData() {
        
        activityIndicatorView = NVActivityIndicatorView(frame: self.view.frame, type: .ballRotate, color: UIColor.lightGray, padding: CGFloat(100))
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        activityIndicatorView.alpha = 0
        self.view.addSubview(activityIndicatorView)
        UIView.animate(withDuration: 0.1) {
            self.activityIndicatorView.alpha = 1
        }
        
        activityIndicatorView.startAnimating()
        
        self.loadChatsUIDOne(completion: { (done) in
            print("FINISHED LOADING CHATS UID ONE")
            self.loadChatsUIDTwo(completion: { (done) in
                if self.conversationIDs.count == 0 {
                    self.conversations.add("none")
                    DispatchQueue.main.async(execute: {
                        self.tableView.reloadData()
                        UIView.animate(withDuration: 0.1, animations: {
                            self.activityIndicatorView.alpha = 0
                            self.tableView.alpha = 1
                        }, completion: { (success) in
                            self.activityIndicatorView.stopAnimating()
                            self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
                        })
                    })
                } else {
                    DispatchQueue.main.async(execute: {
                        self.tableView.reloadData()
                        UIView.animate(withDuration: 0.1, animations: {
                            self.activityIndicatorView.alpha = 0
                            self.tableView.alpha = 1
                        }, completion: { (success) in
                            self.activityIndicatorView.stopAnimating()
                            self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
                        })
                    })
                }
            })
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.conversations.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ChatTableViewCell
        // Configure the cell...         
        if let chat = self.conversations[indexPath.row] as? String {
            if chat == "none" {
                // no chats
                cell.selectionStyle = UITableViewCellSelectionStyle.none
                cell.textLabel?.text = "You do not have any chats :("
                cell.inquiryLabel.alpha = 0
                cell.latestMessageLabel.alpha = 0
                cell.profilePictureImageView.alpha = 0
            }
        } else {                    
            let conversation = self.conversations[indexPath.row] as? [String: Any]
            if let latestMessage = conversation?["latestMessage"] as? String {
                if let inquiryTitle = conversation?["inquiryTitle"] as? String {
                    cell.inquiryLabel.text = inquiryTitle
                    cell.latestMessageLabel.text = latestMessage
                }
            }
        }
        
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let chat = self.conversations[indexPath.row] as? String {
            if chat != "none" {
                if let chatID = self.conversationIDs[indexPath.row] as? String {
                    GlobalVariables._chatID = chatID
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChatVC")
                    self.navigationController?.present(vc!, animated: false, completion: nil)
                }
            } else {
                print("CHAT: \(chat)")
            }
        } else {
            if let chatID = self.conversationIDs[indexPath.row] as? String {
                GlobalVariables._chatID = chatID
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChatVC")
                self.navigationController?.present(vc!, animated: false, completion: nil)
            }
        }
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

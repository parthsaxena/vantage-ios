//
//  GiftCardsViewController.swift
//  
//
//  Created by Parth Saxena on 10/29/16.
//
//

import UIKit
import Firebase
import GoogleMobileAds
import Armchair
import NVActivityIndicatorView

class GiftCardsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, GADBannerViewDelegate {

    @IBOutlet weak var giftCardsTableView: UITableView!
    @IBOutlet weak var coinsButton: UIButton!
    
    @IBOutlet weak var bannerView: GADBannerView!
    
    var giftCardsCounts = NSMutableArray()
    var giftCardsKeys = NSMutableArray()
    
    var coinsAmount = ""
    
    var activityIndicatorView: NVActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Armchair.userDidSignificantEvent(false)
        
        let request = GADRequest()
        request.testDevices = [kGADSimulatorID]
        bannerView.delegate = self
        bannerView.adUnitID = "ca-app-pub-7685378724367635/9077439904"
        bannerView.rootViewController = self
        bannerView.load(request)
        
        loadCoins()
        
        print("Loading Gift Cards")
        
        activityIndicatorView = NVActivityIndicatorView(frame: self.view.frame, type: .ballRotate, color: UIColor.lightGray, padding: CGFloat(100))
        activityIndicatorView.alpha = 0
        self.giftCardsTableView.alpha = 0
        self.view.addSubview(activityIndicatorView)
        self.activityIndicatorView.startAnimating()
        UIView.animate(withDuration: 0.1) {
            self.activityIndicatorView.alpha = 1
        }
        
        self.giftCardsTableView.delegate = self
        self.giftCardsTableView.dataSource = self
        self.giftCardsTableView.tableFooterView = UIView()
        
        //giftCardsTableView.showLoadingIndicator()
        ConnectionManager().getGiftCards { (result) in
            if let cards = result as? [String: [AnyObject]] {
                var count = cards["keys"]!.count
                for i in 0..<count {
                    let key = cards["keys"]![i]
                    let count = cards["counts"]![i]
                    
                    self.giftCardsKeys.add(key)
                    self.giftCardsCounts.add(count)
                }
                DispatchQueue.main.async(execute: { 
                    self.giftCardsTableView.reloadData()
                    self.giftCardsTableView.tableFooterView = UIView()
                    UIView.animate(withDuration: 0.1, animations: {
                        self.activityIndicatorView.alpha = 0
                        self.giftCardsTableView.alpha = 1
                        }, completion: { (success) in
                            self.activityIndicatorView.stopAnimating()
                    })
                })
            }
        }
        
        self.navigationController?.navigationBar.alpha = 0
        self.navigationController!.navigationBar.barTintColor = UIColor.white
        self.navigationController!.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Roboto", size: 30)!, NSForegroundColorAttributeName: UIColor.black]
        
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
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.giftCardsKeys.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("Loading tableview")
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! GiftCardTableViewCell
        // Configure the cell...
        let key = self.giftCardsKeys[indexPath.row] as! String
        let count = self.giftCardsCounts[indexPath.row] as! Int
        
        cell.keyLabel.text = "\(key) ($10)"
        if (count > 0) {
            // available
            cell.availableLabel.text = "\(String(count)) available"
        } else {
            // not available
            cell.availableLabel.textColor = UIColor.red
            cell.availableLabel.text = "out of stock"
        }
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let giftCardKey = self.giftCardsKeys[indexPath.row] as! String
        let count = self.giftCardsCounts[indexPath.row] as! Int
        
        if (count > 0) {
            // available
            let confirmAlert = UIAlertController(title: "Confirm", message: "Are you sure you would like to purchase this $10 \(giftCardKey) gift card for 1000 coins?", preferredStyle: .alert)
            confirmAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                // loading alert
                let loadingAlertController = UIAlertController(title: "Please Wait...", message: nil, preferredStyle: .alert)
                self.present(loadingAlertController, animated: true, completion: nil)
                
                if let uid = FIRAuth.auth()?.currentUser?.uid {
                    ConnectionManager().purchaseGiftCard(uid, giftCard: giftCardKey, completion: { (result) in
                        if let resultString = result as? String {
                            if resultString == "Success" {
                                // success
                                //Armchair.userDidSignificantEvent(false)
                                GlobalVariables._displayRateAlert = true
                                let alert = UIAlertController(title: "Success", message: "A code for the specified gift card has been sent to your email address!", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                                    self.present((self.storyboard?.instantiateViewController(withIdentifier: "mainVC"))!, animated: false, completion: nil)
                                }))
                                loadingAlertController.dismiss(animated: true, completion: {
                                    self.present(alert, animated: true, completion: nil)
                                })
                            } else if resultString == "Error" {
                                // failure
                                let alert = UIAlertController(title: "Error", message: "There was an error processing your request...", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                                    self.present((self.storyboard?.instantiateViewController(withIdentifier: "mainVC"))!, animated: false, completion: nil)
                                }))
                                alert.view.tintColor = UIColor.red
                                loadingAlertController.dismiss(animated: true, completion: {
                                    self.present(alert, animated: true, completion: nil)
                                })
                            } else if resultString == "Not enough coins" {
                                let alert = UIAlertController(title: "Error", message: "You do not have enough coins to purchase this item. Earn coins by answering other users' questions!", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                                    alert.dismiss(animated: true, completion: nil)
                                }))
                                alert.view.tintColor = UIColor.red
                                loadingAlertController.dismiss(animated: true, completion: {
                                    self.present(alert, animated: true, completion: nil)
                                })
                            } else {
                                // failure
                                NSLog("FATAL ERROR: resultString for Purchase of gift card: \(resultString)")
                                let alert = UIAlertController(title: "Error", message: "There was an error processing your request...", preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                                    self.present((self.storyboard?.instantiateViewController(withIdentifier: "mainVC"))!, animated: false, completion: nil)
                                }))
                                alert.view.tintColor = UIColor.red
                                loadingAlertController.dismiss(animated: true, completion: {
                                    self.present(alert, animated: true, completion: nil)
                                })
                            }
                        }
                    })
                }
            }))
            confirmAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            self.giftCardsTableView.deselectRow(at: indexPath, animated: false)
            self.present(confirmAlert, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Out of Stock", message: "The gift card selected is currently out of stock. Please check back later. ", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            alert.view.tintColor = UIColor.red
            self.giftCardsTableView.deselectRow(at: indexPath, animated: false)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func loadCoins() {
        ConnectionManager().getCoins { (result) in
            self.coinsAmount = result as! String
            print("COINS: \(self.coinsAmount)")
            DispatchQueue.main.async(execute: {
                self.coinsButton.setTitle("\(self.coinsAmount) coins", for: UIControlState())
            })
            //self.coinsButton.setTitleColor(UIColor(red: 212, green: 175, blue: 55, alpha: 1.0), forState: UIControlState.Normal)
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

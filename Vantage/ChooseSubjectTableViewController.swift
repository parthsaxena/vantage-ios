//
// ChooseSubjectViewController.swift
// Vantage
//
// Created by Parth Saxena on 7/10/2016
// Copright © 2016 Socify. All rights reserved.
//

import UIKit
import Firebase
import GoogleMobileAds
import Armchair
import NVActivityIndicatorView

class ChooseSubjectTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, GADBannerViewDelegate {
    
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
            self.subjectsTableView.separatorStyle = UITableViewCellSeparatorStyle.none
        }        
        
        self.subjectsTableView.delegate = self
        self.subjectsTableView.dataSource = self
        
        activityIndicatorView.startAnimating()
        
        loadData()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
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
            if let scrollPosition = GlobalVariables._chooseSubjectContentOffset {
                self.subjectsTableView.contentOffset = scrollPosition
            }
            self.activityIndicatorView.stopAnimating()
            UIView.animate(withDuration: 0.1, animations: {
                self.activityIndicatorView.alpha = 0
            }, completion: { (success) in
                self.subjectsTableView.separatorStyle = .singleLine
            })
            //self.subjectsTableView.hideLoadingIndicator()
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        // Configure the cell...
        
        let cellSubject = (self.items[indexPath.section] as! NSMutableArray)[indexPath.row]
        
        cell.textLabel!.text = "     \(cellSubject as! String)"
        
        cell.textLabel?.alpha = 0
        
        UIView.animate(withDuration: 0.4, animations: { 
            cell.textLabel?.alpha = 1
        }) 
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellSubject = (self.items[indexPath.section] as! NSMutableArray)[indexPath.row] as! String
        
        GlobalVariables._currentSubjectPostingTo = cellSubject
        GlobalVariables._chooseSubjectContentOffset = self.subjectsTableView.contentOffset
        
        //Armchair.userDidSignificantEvent(false)
        GlobalVariables._displayRateAlert = true
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "postVC")
        self.present(vc!, animated: false, completion: nil)
    }
    
}

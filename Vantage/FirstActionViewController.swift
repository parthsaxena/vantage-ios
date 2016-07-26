//
//  FirstActionViewController.swift
//  Vantage
//
//  Created by Parth Saxena on 7/25/16.
//  Copyright © 2016 Socify. All rights reserved.
//

import UIKit

class FirstActionViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signUpWithEmailTapped(sender: AnyObject) {
        //showModal()
    }
    
    func showModal() {
        print("presenting sign-up modal")
        let modalViewController = ModalSignUpViewController()
        modalViewController.modalPresentationStyle = .OverCurrentContext
        presentViewController(modalViewController, animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

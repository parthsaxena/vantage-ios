/*
//  AddPaymentViewController.swift
//  Vantage
//
//  Created by Parth Saxena on 7/29/16.
//  Copyright © 2016 Socify. All rights reserved.
//

import UIKit
import Stripe
//import Alamofire

class AddPaymentViewController: UIViewController, STPPaymentCardTextFieldDelegate {

    let paymentTextField = STPPaymentCardTextField()
    @IBOutlet weak var payButtonOutlet: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        super.viewDidLoad();
        paymentTextField.frame = CGRectMake(15, 199, CGRectGetWidth(self.view.frame) - 30, 44)
        paymentTextField.delegate = self
        view.addSubview(paymentTextField)
        payButtonOutlet.hidden = true;
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func payButtonAction(sender: AnyObject) {
        let card = paymentTextField.cardParams
        STPAPIClient.sharedClient().createTokenWithCard(card, completion: {(token, error) -> Void in
            if let error = error {
                print(error)
            }
            else if let token = token {
                print(token)
                self.chargeUsingToken(token)
            }
        })
    }
    
    func chargeUsingToken(token:STPToken) {
        let requestString = "http://scapter.org/stripe/appcoda/payment.php"
        let params = ["stripeToken": token.tokenId, "amount": ".99", "currency": "usd", "description": "testRun"]
        //This line of code will suffice, but we want a response
        Alamofire.request(.POST, requestString, parameters: params)
        //with response handler:
        Alamofire.request(.POST, requestString, parameters: params)
        .responseJSON { response in
            print(response.request) // original URL request
            print(response.response) // URL response
            print(response.data) // server data
            print(response.result) // result of response serialization
            
            if let JSON = response.result.value {
                print("JSON: \(JSON)")
            }
        }
    }
    
    func paymentCardTextFieldDidChange(textField: STPPaymentCardTextField) {
        if textField.valid {
            payButtonOutlet.hidden = false;
        }
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
 */

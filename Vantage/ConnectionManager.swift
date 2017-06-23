//
//  ConnectionManager.swift
//  
//
//  Created by Parth Saxena on 10/28/16.
//
//

import Foundation
import Firebase

let sharedInstance = ConnectionManager()

class ConnectionManager {
    
    func getCoins(_ completion: @escaping(_ result: AnyObject) -> Void) {
        
        var request = NSMutableURLRequest(url: URL(string: "https://vantage-backend-staging.herokuapp.com/get_coins.php")!)
        request.httpMethod = "POST"
        if let uid = FIRAuth.auth()?.currentUser?.uid {
            let postString = "uid=\(uid)"
            request.httpBody = postString.data(using: String.Encoding.utf8)
            let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
                guard error == nil && data != nil else {
                    print("error=\(error)")
                    return
                }
                
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                    print("statusCode should be 200, but it \(httpStatus.statusCode)")
                    print("response = \(response)")
                }
                
                let responseString = String(data: data!, encoding: String.Encoding.utf8)
                print("responseString = \(responseString)")
                completion(responseString! as AnyObject)
            }) 
            task.resume()
        }
        
    }
    
    func getGiftCards(_ completion: @escaping (_ result: AnyObject) -> Void) {
        
        var request = NSMutableURLRequest(url: URL(string: "https://vantage-backend-staging.herokuapp.com/get_giftcard_list.php")!)
        request.httpMethod = "POST"
        if let uid = FIRAuth.auth()?.currentUser?.uid {
            let postString = ""
            request.httpBody = postString.data(using: String.Encoding.utf8)
            let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
                guard error == nil && data != nil else {
                    print("error=\(error)")
                    return
                }
                
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                    print("statusCode should be 200, but it \(httpStatus.statusCode)")
                    print("response = \(response)")
                }
                
                /*let responseString = String(data: data!, encoding: NSUTF8StringEncoding)
                print("responseString = \(responseString)")*/
                
                // create json object with data received
                
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                    completion(json as AnyObject)
                } catch {
                    print("error serializng JSON: \(error)")
                }
            }) 
            task.resume()
        }
        
    }
    
    func transferCoins(_ uidOne: String, uidTwo: String, inquiryID: String, amount: String, completion: @escaping (_ result: AnyObject) -> Void) {
        var request = NSMutableURLRequest(url: URL(string: "https://vantage-backend-staging.herokuapp.com/transfer_coins.php")!)
        request.httpMethod = "POST"
        if let uid = FIRAuth.auth()?.currentUser?.uid {
            let postString = "uidOne=\(uidOne)&uidTwo=\(uidTwo)&amount=\(amount)&inquiryID=\(inquiryID)"
            request.httpBody = postString.data(using: String.Encoding.utf8)
            let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
                guard error == nil && data != nil else {
                    print("error=\(error)")
                    return
                }
                
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                    print("statusCode should be 200, but it \(httpStatus.statusCode)")
                    print("response = \(response)")
                }
                
                let responseString = String(data: data!, encoding: String.Encoding.utf8)
                print("responseString = \(responseString)")
                completion(responseString! as AnyObject)
            }) 
            task.resume()
        }
    }
    
    func purchaseGiftCard(_ uid: String, giftCard: String, completion: @escaping (_ result: AnyObject) -> Void) {
        var request = NSMutableURLRequest(url: URL(string: "https://vantage-backend-staging.herokuapp.com/purchase_giftcard.php")!)
        request.httpMethod = "POST"
        if let uid = FIRAuth.auth()?.currentUser?.uid {
            let postString = "uid=\(uid)&giftCardKey=\(giftCard)"
            request.httpBody = postString.data(using: String.Encoding.utf8)
            let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
                guard error == nil && data != nil else {
                    print("error=\(error)")
                    return
                }
                
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                    print("statusCode should be 200, but it \(httpStatus.statusCode)")
                    print("response = \(response)")
                }
                
                if let responseString = String(data: data!, encoding: String.Encoding.utf8) {
                     print("responseString = \(responseString)")
                    completion(responseString as AnyObject)
                }
            }) 
            task.resume()
        }
    }
    
    func sendVideoTime(_ time: Int, completion: @escaping (_ result: AnyObject) -> Void) {
        let request = NSMutableURLRequest(url: URL(string: "https://vantage-backend-staging.herokuapp.com/put_video_ad_time.php")!)
        request.httpMethod = "POST"
        if let uid = FIRAuth.auth()?.currentUser?.uid {
            let postString = "uid=\(uid)&time=\(time)"
            request.httpBody = postString.data(using: String.Encoding.utf8)
            let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
                guard error == nil && data != nil else {
                    print("error=\(error)")
                    return
                }
                
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                    print("statusCode should be 200, but it \(httpStatus.statusCode)")
                    print("response = \(response)")
                }
                
                let responseString = String(data: data!, encoding: String.Encoding.utf8)
                print("responseString = \(responseString)")
                completion(responseString! as AnyObject)
            }) 
            task.resume()
        }
    }
    
    func getVideoTime(_ completion: @escaping (_ result: AnyObject) -> Void) {
        let request = NSMutableURLRequest(url: URL(string: "https://vantage-backend-staging.herokuapp.com/get_video_ad_time.php")!)
        request.httpMethod = "POST"
        if let uid = FIRAuth.auth()?.currentUser?.uid {
            let postString = "uid=\(uid)"
            request.httpBody = postString.data(using: String.Encoding.utf8)
            let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
                guard error == nil && data != nil else {
                    print("error=\(error)")
                    return
                }
                
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                    print("statusCode should be 200, but it \(httpStatus.statusCode)")
                    print("response = \(response)")
                }
                
                let responseString = String(data: data!, encoding: String.Encoding.utf8)
                print("responseString = \(responseString)")
                completion(responseString! as AnyObject)
            }) 
            task.resume()
        }
    }
    
    func requestFourCoins(_ time: Int, completion: @escaping (_ result: AnyObject) -> Void) {
        let request = NSMutableURLRequest(url: URL(string: "https://vantage-backend-staging.herokuapp.com/request_four_coins.php")!)
        request.httpMethod = "POST"
        if let uid = FIRAuth.auth()?.currentUser?.uid {
            let postString = "uid=\(uid)&time=\(time)"
            request.httpBody = postString.data(using: String.Encoding.utf8)
            let task = URLSession.shared.dataTask(with: (request as? URLRequest)!, completionHandler: { data, response, error in
                guard error == nil && data != nil else {
                    print("error=\(error)")
                    return
                }
                
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                    print("statusCode should be 200, but it \(httpStatus.statusCode)")
                    print("response = \(response)")
                }
                
                let responseString = String(data: data!, encoding: String.Encoding.utf8)
                print("responseString = \(responseString)")
                completion(responseString! as AnyObject)
            }) 
            task.resume()
        }

    }
    
}

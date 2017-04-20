//
//  ConnectionsManager.swift
//  Vantage
//
//  Created by Parth Saxena on 10/3/16.
//  Copyright © 2016 Socify. All rights reserved.
//

import Foundation
import Firebase

class ConnectionManager: NSObject {
    
    var GET_COINS = "https://vantage.social:436/get_coins.php"
    
    func getCoins(uid: String, completion: (result: AnyObject) -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: GET_COINS)!)
        request.HTTPMethod = "POST"
        let postString = "uid=\(uid)"
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
            guard error == nil && data != nil else {
                print("error=\(error)")
                return
            }
            
            if let httpStatus = response as? NSHTTPURLResponse where httpStatus.statusCode != 200 {
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
            }
            
            // Create JSON with data recieved
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
                completion(result: json)
            } catch {
                print("Error serializing JSON: \(error)")
            }
        }
        task.resume()
    }
    
}

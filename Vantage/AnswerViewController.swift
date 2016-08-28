//
//  AnswerViewController.swift
//  Vantage
//
//  Created by Parth Saxena on 7/27/16.
//  Copyright © 2016 Socify. All rights reserved.
//

import UIKit
import Firebase

class AnswerViewController: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var letterCounterLabel: UILabel!
    @IBOutlet weak var selectImageButton: UIButton!
    
    @IBOutlet weak var postImageView: UIImageView!
    
    var hasImage = false
    var imageFileName = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        contentTextView.delegate = self
        
        self.navigationController!.navigationBar.barTintColor = UIColor.whiteColor()
        self.navigationController!.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Roboto", size: 30)!, NSForegroundColorAttributeName: UIColor.blackColor()]
        self.title = "Answer"
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sendTapped(sender: AnyObject) {
        sendAnswer()
    }
    
    func sendAnswer() {
        
        let content = contentTextView.text!
        
        if (content != "" && content != "What is your solution?") {
        
        var image = "\(self.imageFileName).jpg"
        let inquiryID = GlobalVariables._currentInquiryIDAnswering
        
        if (self.imageFileName == "" && hasImage == true) {
            let alert = PSAlert.sharedInstance.instantiateAlert("Error", alertText: "Your image has not finished uploading. Please wait a moment...")
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            
            let currentUID = FIRAuth.auth()?.currentUser?.uid
            
            let timestamp = FIRServerValue.timestamp()
            
            let randomID = randomStringWithLength(15)
            
            if hasImage == false {
                image = "NO_IMAGE_WHITE.jpg"
            }
            
            let post: Dictionary<String, AnyObject> = [
                "content": content,
                "image": image,
                "username": currentUID!,
                "inquiryID": inquiryID,
                "createdAt": timestamp,
                "id": randomID
            ]
            
            let postObject = FIRDatabase.database().reference().child("answers").childByAutoId()            
            postObject.setValue(post)
            
            let username = GlobalVariables._currentUserAnswering
            NSLog("USERNAME ANSWERING: \(username)")
            FIRDatabase.database().reference().child("users").child(username).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                if let userDictionary = snapshot.value as? [String : AnyObject] {
                    let notificationID = userDictionary["notification_id"] as! String
                    NSLog("Attempting to send notification to ID: \(notificationID)")
                    
                    OneSignal.defaultClient().postNotification(["contents": ["en": "You have received an answer for your inquiry!"], "include_player_ids": [notificationID]], onSuccess: { (nil) in
                        NSLog("Sent answer-received notification.")
                        }, onFailure: { (error) in
                            NSLog("Error sending answer-received notification: \(error.localizedDescription)")
                    })
                }
            })
            
            let alert = UIAlertController(title: "Success", message: "Your answer has been sent! You will be notified if the asker accepts your answer.", preferredStyle: .Alert)
            let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: { (action) in
                let vc = self.storyboard?.instantiateViewControllerWithIdentifier("mainVC")
                self.presentViewController(vc!, animated: false, completion: nil)
            })
            alert.addAction(defaultAction)
            self.presentViewController(alert, animated: true, completion: nil)
        }
        } else {
            let alert = PSAlert.sharedInstance.instantiateAlert("Error", alertText: "You did not fill out one or more fields. ")
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }

    func textViewDidBeginEditing(textView: UITextView) {
        if contentTextView.text == "What is your solution?" {
            contentTextView.text = nil
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "What is your solution?"
        }
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        let newText = (contentTextView.text as NSString).stringByReplacingCharactersInRange(range, withString: text)
        let numberOfChars = newText.characters.count // for Swift use count(newText)
        return numberOfChars <= 600;
    }
    
    func textViewDidChange(textView: UITextView) {
        let numberOfChars = contentTextView.text.characters.count
        self.letterCounterLabel.text = "\(numberOfChars) / 600"
    }
    
    @IBAction func selectImageTapped(sender: AnyObject) {
        let picker = UIImagePickerController()
        picker.delegate = self
        presentViewController(picker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        var newImage: UIImage
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.selectImageButton.alpha = 0
            postImageView.image = pickedImage
            hasImage = true
            uploadImage(pickedImage)
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func uploadImage(image: UIImage) {
        let randomName = randomStringWithLength(10)
        let imageData = UIImageJPEGRepresentation(image, 1.0)
        let uploadRef = FIRStorage.storage().referenceForURL("gs://vantage-e9003.appspot.com").child("images/\(randomName).jpg")
        
        let uploadTask = uploadRef.putData(imageData!, metadata: nil) { metadata, error in
            if error == nil {
                NSLog("Successfully uploaded image.")
                self.imageFileName = randomName as String
            } else {
                // error
                NSLog("Error while uploading file, message: \(error!.localizedDescription) .")
            }
        }
    }
    
    func randomStringWithLength (len : Int) -> NSString {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        
        var randomString : NSMutableString = NSMutableString(capacity: len)
        
        for (var i=0; i < len; i++){
            var length = UInt32 (letters.length)
            var rand = arc4random_uniform(length)
            randomString.appendFormat("%C", letters.characterAtIndex(Int(rand)))
        }
        
        return randomString
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

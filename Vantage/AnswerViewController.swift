//
//  AnswerViewController.swift
//  Vantage
//
//  Created by Parth Saxena on 7/27/16.
//  Copyright © 2016 Socify. All rights reserved.
//

import UIKit
import Firebase
import Armchair

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
        
        self.navigationController!.navigationBar.barTintColor = UIColor.white
        self.navigationController!.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Roboto", size: 30)!, NSForegroundColorAttributeName: UIColor.black]
        self.title = "Answer"
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sendTapped(_ sender: AnyObject) {
        sendAnswer()
    }
    
    func sendAnswer() {
        
        let content = contentTextView.text!
        
        if (content != "" && content != "What is your solution?") {
        
        var image = "\(self.imageFileName).jpg"
        let inquiryID = GlobalVariables._currentInquiryIDAnswering
        
        if (self.imageFileName == "" && hasImage == true) {
            let alert = UIAlertController(title: "Please Wait...", message: "Your image has not finished uploading. Please wait a moment...", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            
            let currentUID = FIRAuth.auth()?.currentUser?.uid
            
            let timestamp = FIRServerValue.timestamp()
            
            let randomID = randomStringWithLength(15)
            
            if hasImage == false {
                image = "NO_IMAGE_WHITE.jpg"
            }
            
            let post: Dictionary<String, AnyObject> = [
                "content": content as AnyObject,
                "image": image as AnyObject,
                "username": currentUID! as AnyObject,
                "inquiryID": inquiryID as AnyObject,
                "createdAt": timestamp as AnyObject,
                "accepted":"none" as AnyObject,
                "id": randomID
            ]
            
        /*FIRDatabase.database().reference().child("posts").queryOrderedByChild("id").queryEqualToValue(inquiryID).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                if let inquiryDictionary = snapshot.value as? [String : AnyObject] {
                    for inquiry in inquiryDictionary {
                        let actualInquiryID = inquiry.0
                        FIRDatabase.database().reference().child("posts").child(actualInquiryID).updateChildValues(["active":"false"])
                        NSLog("updated inquiry to set active to false. \(inquiryID)")
                    }
                }
            })*/
            
            let postObject = FIRDatabase.database().reference().child("answers").childByAutoId()            
            postObject.setValue(post)
            
            let username = GlobalVariables._currentUserAnswering
            NSLog("USERNAME ANSWERING: \(username)")
            FIRDatabase.database().reference().child("users").child(username).observeSingleEvent(of: .value, with: { (snapshot) in
                if let userDictionary = snapshot.value as? [String : AnyObject] {
                    if let notificationID = userDictionary["notification_id"] as? String {
                    NSLog("Attempting to send notification to ID: \(notificationID)")                                            
                        
                    OneSignal.postNotification(["contents": ["en": "You have received an answer for your inquiry!"], "data": ["type":"answer-to-inquiry"], "include_player_ids": [notificationID]], onSuccess: { (nil) in
                        NSLog("Sent answer-received notification.")
                        }, onFailure: { (error) in
                            NSLog("Error sending answer-received notification: \(error?.localizedDescription)")
                    })
                    }
                }
            })
            
            //Armchair.userDidSignificantEvent(false)
            GlobalVariables._displayRateAlert = true
            
            let alert = UIAlertController(title: "Success", message: "Your answer has been sent! You will be notified if the asker accepts your answer.", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "mainVC")
                self.present(vc!, animated: false, completion: nil)
            })
            alert.addAction(defaultAction)
            self.present(alert, animated: true, completion: nil)
        }
        } else {
            let alert = PSAlert.sharedInstance.instantiateAlert("Error", alertText: "You did not fill out one or more fields. ")
            self.present(alert, animated: true, completion: nil)
        }
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        if contentTextView.text == "What is your solution?" {
            contentTextView.text = nil
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "What is your solution?"
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (contentTextView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.characters.count // for Swift use count(newText)
        return numberOfChars <= 600;
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let numberOfChars = contentTextView.text.characters.count
        self.letterCounterLabel.text = "\(numberOfChars) / 600"
    }
    
    @IBAction func selectImageTapped(_ sender: AnyObject) {
        let alert = UIAlertController(title: "Choose Action", message: "Would you like to choose an image from your photo library or take a picture with your camera?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action) in
            // open photo library
            let picker = UIImagePickerController()
            picker.delegate = self
            self.present(picker, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action) in
            // open camera
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerControllerSourceType.camera
                imagePicker.allowsEditing = false
                self.present(imagePicker, animated: true, completion: nil)
            } else {
                let noCameraAlert = UIAlertController(title: "Error", message: "Your device does not support this function.", preferredStyle: .alert)
                noCameraAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                noCameraAlert.view.tintColor = UIColor.red
                self.present(noCameraAlert, animated: true, completion: nil)
            }
        }))
        self.present(alert, animated: true, completion: nil)

    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var newImage: UIImage
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.selectImageButton.alpha = 0
            postImageView.image = pickedImage
            hasImage = true
            uploadImage(pickedImage)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func uploadImage(_ image: UIImage) {
        let randomName = randomStringWithLength(10)
        let imageData = UIImageJPEGRepresentation(image, 1.0)
        let uploadRef = FIRStorage.storage().reference(forURL: "gs://vantage-e9003.appspot.com").child("images/\(randomName).jpg")
        
        let uploadTask = uploadRef.put(imageData!, metadata: nil) { metadata, error in
            if error == nil {
                NSLog("Successfully uploaded image.")
                self.imageFileName = randomName as String
            } else {
                // error
                NSLog("Error while uploading file, message: \(error!.localizedDescription) .")
            }
        }
    }
    
    func randomStringWithLength (_ len : Int) -> NSString {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        
        var randomString : NSMutableString = NSMutableString(capacity: len)
        
        for i in (0..<len) {
            var length = UInt32 (letters.length)
            var rand = arc4random_uniform(length)
            randomString.appendFormat("%C", letters.character(at: Int(rand)))
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

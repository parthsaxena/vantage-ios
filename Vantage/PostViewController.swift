//
//  PostViewController.swift
//  Vantage
//
//  Created by Parth Saxena on 7/1/16.
//  Copyright © 2016 Socify. All rights reserved.
//

import UIKit
import Firebase
import Armchair
import TextFieldEffects

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l <= r
  default:
    return !(rhs < lhs)
  }
}


class PostViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, UITextFieldDelegate {

    @IBOutlet var letterCounterLabel: UILabel!
    @IBOutlet var selectImageButton: UIButton!
    @IBOutlet var postImageView: UIImageView!
    @IBOutlet weak var titleTextField: JiroTextField!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var subjectField: JiroTextField!
    
    var imageFileName = ""
    
    var hasImage = false
    
    override func viewDidAppear(_ animated: Bool) {
        titleTextField.becomeFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        contentTextView.delegate = self
        titleTextField.delegate = self
        
        self.navigationController!.navigationBar.barTintColor = UIColor.white
        self.navigationController!.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Roboto", size: 30)!, NSForegroundColorAttributeName: UIColor.black]
        self.title = "\(GlobalVariables._currentSubjectPostingTo)"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            let sizeImage = UIImageJPEGRepresentation(pickedImage, 1.0)
            if let bytesSize = sizeImage?.count {
                if (bytesSize > 25 * 1024 * 1024) {
                    // image is too big
                    dismiss(animated: true, completion: nil)
                    print("Bytes of image selected: \(bytesSize)")
                    let xMbSize = bytesSize/1000000
                    let mbSize = round(100.0 * Double(xMbSize)) / 100.0
                    
                    let alert = UIAlertController(title: "Error", message: "Your image is \(mbSize) which exceeds the limit of 25 megabytes. Please pick a new image.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                } else {
                    hasImage = true
                    print("Bytes of image selected: \(bytesSize)")
                    self.selectImageButton.alpha = 0
                    postImageView.image = pickedImage
                    uploadImage(pickedImage)
                    dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    func uploadImage(_ image: UIImage) {
        let randomName = randomStringWithLength(10)
        let imageData = UIImageJPEGRepresentation(image, 1.0)
        let uploadRef = FIRStorage.storage().reference(forURL: "gs://vantage-e9003.appspot.com").child("images/\(randomName).jpg")
        
        let uploadTask = uploadRef.put(imageData!, metadata: nil) { metadata, error in
            if error == nil {
                print("Successfully uploaded image.")
                self.imageFileName = "\(randomName as String).jpg"
            } else {
                // error
                print("Error while uploading file, message: \(error!.localizedDescription) .")
            }
        }
    }
    
    func randomStringWithLength (_ len : Int) -> NSString {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        
        var randomString : NSMutableString = NSMutableString(capacity: len)
        
        for i in 0..<len {
            var length = UInt32 (letters.length)
            var rand = arc4random_uniform(length)
            randomString.appendFormat("%C", letters.character(at: Int(rand)))
        }
        
        return randomString
    }
    
    @IBAction func postTapped(_ sender: AnyObject) {
        // check if user currently has any active inquiries
        let alertController = UIAlertController(title: "Please Wait...", message: nil, preferredStyle: .alert)
        self.present(alertController, animated: true, completion: nil)
        print("Post tapped")
        checkIfInquiryValid { (result) in
            print("completion")
            alertController.dismiss(animated: true, completion: {
                if result == true {
                    // inquiry is valid
                    if (self.titleTextField.text != "" && (self.contentTextView.text != "" && self.contentTextView.text != "What is your problem or assignment?")) {
                        print("Posting...")
                        if (self.imageFileName == "" && self.hasImage == true) {
                            print("Error posting.")
                            let alert = UIAlertController(title: "Please Wait...", message: "Your image has not finished uploading. Please wait a moment...", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                        } else {
                            
                            let currentUID = FIRAuth.auth()?.currentUser?.uid
                            
                            let timestamp = FIRServerValue.timestamp()
                            
                            let randomID = self.randomStringWithLength(15)
                            
                            if (self.hasImage == false) {
                                self.imageFileName = "NO_IMAGE_WHITE.jpg"
                            }
                            
                            if let email = FIRAuth.auth()?.currentUser?.email {
                                
                                FIRDatabase.database().reference().child("users").queryOrdered(byChild: "email").queryEqual(toValue: email).queryLimited(toFirst: 1).observeSingleEvent(of: .value, with: { (snapshot) in
                                    if let inquiryDictionary = snapshot.value as? [String : AnyObject] {
                                        for object in inquiryDictionary {
                                            print(object.0)
                                            
                                            let alert = UIAlertController(title: "Message", message: "How many coins would you like to award the user who completes your inquiry with?", preferredStyle: .alert)
                                            alert.addTextField(configurationHandler: { (textField: UITextField) in
                                                textField.placeholder = "Set an amount of coins to be awarded..."
                                                textField.textAlignment = NSTextAlignment.center
                                                textField.keyboardType = UIKeyboardType.numberPad
                                            })
                                            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                                            let action = UIAlertAction(title: "Submit", style: .default, handler: { (action: UIAlertAction) in
                                                if let textFields = alert.textFields {
                                                    let theTextFields = textFields as [UITextField]
                                                    let enteredText = theTextFields[0].text
                                                    let coinValue = Int(enteredText!)
                                                    
                                                    // loading alert
                                                    let alertController = UIAlertController(title: "Please Wait...", message: nil, preferredStyle: .alert)
                                                    self.present(alertController, animated: true, completion: nil)
                                                    ConnectionManager().getCoins { (result) in
                                                        let coinsAmount = result as! String
                                                        let actualCoinsValue = Int(coinsAmount)
                                                        if (coinValue <= actualCoinsValue) {
                                                            // user has enough coins, proceed
                                                            let post: Dictionary<String, AnyObject> = [
                                                                "title": self.titleTextField.text! as AnyObject,
                                                                "content": self.contentTextView.text! as AnyObject,
                                                                "image": self.imageFileName as AnyObject,
                                                                "username": object.0 as AnyObject,
                                                                "subject": GlobalVariables._currentSubjectPostingTo as AnyObject,
                                                                "createdAt": timestamp as AnyObject,
                                                                "active":"true" as AnyObject,
                                                                "coins":coinValue! as AnyObject,
                                                                "id": randomID
                                                            ]
                                                            let postObject = FIRDatabase.database().reference().child("posts").childByAutoId()
                                                            postObject.setValue(post)
                                                            
                                                            // post has been sent, send notification
                                                            print("Post has been sent, sending notification to subject \(GlobalVariables._currentSubjectPostingTo).")
                                                            OneSignal.postNotification(["app_id":"9fffb537-914a-481a-9f17-a22e2df2c5bb", "headings": ["en": "New Inquiry..."], "contents": ["en": "A new question has been posted in \(GlobalVariables._currentSubjectPostingTo)!"], "filters": ["field":"tag", "key":GlobalVariables._currentSubjectPostingTo, "relation":"=", "value":"subscribed"], "include_player_ids":""], onSuccess: { (nil) in
                                                                print("Sent new-question notification")
                                                            }, onFailure: { (error) in
                                                                print("Error sending new-question notification: \(error?.localizedDescription)")
                                                            })
                                                            
                                                            /*
                                                            ["headings": ["en": self.inquiryTitle], "contents": ["en": "Anonymous: \"\(message)\""], "data": ["type":"chat-message", "chatID":GlobalVariables._chatID], "include_player_ids": [self.toSendNotificationID]]
                                                             */
 
                                                            DispatchQueue.main.async(execute: {
                                                                //Armchair.userDidSignificantEvent(false)
                                                                GlobalVariables._displayRateAlert = true
                                                                alertController.dismiss(animated: true, completion: {
                                                                    let successAlert = UIAlertController(title: "Success", message: "Your inquiry has been sent! Expect a reply within the next 6 hours!", preferredStyle: .alert)
                                                                    let defaultAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                                                                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "mainVC")
                                                                        self.present(vc!, animated: false, completion: nil)
                                                                    })
                                                                    successAlert.addAction(defaultAction)
                                                                    self.present(successAlert, animated: true, completion: nil)
                                                                })
                                                            })
                                                        } else {
                                                            // user does not have enough coins, throw an error
                                                            DispatchQueue.main.async(execute: { 
                                                                alertController.dismiss(animated: true, completion: {
                                                                    let errorAlert = UIAlertController(title: "Sorry...", message: "You do not have enough coins! You currently have \(actualCoinsValue!) coins!", preferredStyle: .alert)
                                                                    errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                                                    self.present(errorAlert, animated: true, completion: nil)
                                                                })
                                                            })
                                                        }
                                                    }
                                                }
                                            })
                                            alert.addAction(action)
                                            self.present(alert, animated: true, completion: nil)
                                        }
                                    } else {
                                        print("something went wrong... \(email)")
                                        let alert = UIAlertController(title: "Alert", message: "Something went wrong... Please try again later. If this issue persists, please contact support.", preferredStyle: .alert)
                                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                        alert.view.tintColor = UIColor.red
                                        self.present(alert, animated: true, completion: nil)
                                    }
                                })
                            }
                        }
                    } else {
                        print("Fields not filled...")
                        let alert = UIAlertController(title: "Alert", message: "You did not fill out one or more fields.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        alert.view.tintColor = UIColor.red
                        self.present(alert, animated: true, completion: nil)
                    }
                } else {
                    let alert = UIAlertController(title: "Error", message: "You already have an active inquiry. Please wait until you receive an answer or discard the inquiry.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    alert.view.tintColor = UIColor.red
                    self.present(alert, animated: true, completion: nil) 
                }
            })

        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if contentTextView.text == "What is your problem or assignment?" {
            contentTextView.text = nil
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "What is your problem or assignment?"
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (contentTextView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.characters.count // for Swift use count(newText)
        return numberOfChars <= 300;
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let numberOfChars = contentTextView.text.characters.count
        self.letterCounterLabel.text = "\(numberOfChars) / 300"
    }
    
    func checkIfInquiryValid(_ completion: @escaping (_ result: Bool) -> Void) {
        print("Checking if inquiry is valid")
        if let uid = FIRAuth.auth()?.currentUser?.uid {
            FIRDatabase.database().reference().child("posts").queryOrdered(byChild: "username").queryEqual(toValue: uid).observeSingleEvent(of: .value, with: { (snapshot) in
                print("going through 1")
                if let dict = snapshot.value as? [String: [String : AnyObject]] {
                    print("going through 2")
                    var activeInquiries = NSMutableArray()
                    for object in dict {
                        if let activeValue = object.1["active"] as? String {
                            if activeValue == "true" {
                                // user currently has an active inquiry
                                activeInquiries.add(object.0)
                            }
                        }
                    }
                    if activeInquiries.count > 0 {
                        // user currently has an active inquiry
                        completion(false)
                    } else {
                        // user currently has no active inquiries
                        completion(true)
                    }
                } else {
                    // user has NEVER posted an inquiry before
                    completion(true)
                }
            })
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

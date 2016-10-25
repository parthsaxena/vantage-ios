//
//  PostViewController.swift
//  Vantage
//
//  Created by Parth Saxena on 7/1/16.
//  Copyright © 2016 Socify. All rights reserved.
//

import UIKit
import Firebase

class PostViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, UITextFieldDelegate {

    @IBOutlet var letterCounterLabel: UILabel!
    @IBOutlet var selectImageButton: UIButton!
    @IBOutlet var postImageView: UIImageView!
    @IBOutlet weak var titleTextField: JiroTextField!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var subjectField: JiroTextField!
    
    var imageFileName = ""
    
    var hasImage = false
    
    override func viewDidAppear(animated: Bool) {
        titleTextField.becomeFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        contentTextView.delegate = self
        titleTextField.delegate = self
        
        self.navigationController!.navigationBar.barTintColor = UIColor.whiteColor()
        self.navigationController!.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Roboto", size: 30)!, NSForegroundColorAttributeName: UIColor.blackColor()]
        self.title = "\(GlobalVariables._currentSubjectPostingTo)"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            let sizeImage = UIImageJPEGRepresentation(pickedImage, 1.0)
            if let bytesSize = sizeImage?.length {
                if (bytesSize > 25 * 1024 * 1024) {
                    // image is too big
                    dismissViewControllerAnimated(true, completion: nil)
                    NSLog("Bytes of image selected: \(bytesSize)")
                    let xMbSize = bytesSize/1000000
                    let mbSize = round(100.0 * Double(xMbSize)) / 100.0
                    
                    let alert = UIAlertController(title: "Error", message: "Your image is \(mbSize) which exceeds the limit of 25 megabytes. Please pick a new image.", preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                } else {
                    hasImage = true
                    NSLog("Bytes of image selected: \(bytesSize)")
                    self.selectImageButton.alpha = 0
                    postImageView.image = pickedImage
                    uploadImage(pickedImage)
                    dismissViewControllerAnimated(true, completion: nil)
                }
            }
        }
    }
    
    func uploadImage(image: UIImage) {
        let randomName = randomStringWithLength(10)
        let imageData = UIImageJPEGRepresentation(image, 1.0)
        let uploadRef = FIRStorage.storage().referenceForURL("gs://vantage-e9003.appspot.com").child("images/\(randomName).jpg")
        
        let uploadTask = uploadRef.putData(imageData!, metadata: nil) { metadata, error in
            if error == nil {
                NSLog("Successfully uploaded image.")
                self.imageFileName = "\(randomName as String).jpg"
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
    
    @IBAction func postTapped(sender: AnyObject) {
        if (self.titleTextField.text != "" && (self.contentTextView.text != "" && self.contentTextView.text != "What is your problem or assignment?")) {
            NSLog("Posting...")
        if (self.imageFileName == "" && hasImage == true) {
            NSLog("Error posting.")
            let alert = UIAlertController(title: "Please Wait...", message: "Your image has not finished uploading. Please wait a moment...", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
        
            let currentUID = FIRAuth.auth()?.currentUser?.uid
        
            let timestamp = FIRServerValue.timestamp()
            
            let randomID = randomStringWithLength(15)
            
            if (hasImage == false) {
                self.imageFileName = "NO_IMAGE_WHITE.jpg"
            }
            
            if let email = FIRAuth.auth()?.currentUser?.email {
            
            FIRDatabase.database().reference().child("users").queryOrderedByChild("email").queryEqualToValue(email).queryLimitedToFirst(1).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                if let inquiryDictionary = snapshot.value as? [String : AnyObject] {
                    for object in inquiryDictionary {
                        print(object.0)
                        let post: Dictionary<String, AnyObject> = [
                            "title": self.titleTextField.text!,
                            "content": self.contentTextView.text!,
                            "image": self.imageFileName,
                            "username": object.0,
                            "subject": GlobalVariables._currentSubjectPostingTo,
                            "createdAt": timestamp,
                            "active":"true",
                            "id": randomID
                        ]
                        
                        let postObject = FIRDatabase.database().reference().child("posts").childByAutoId()
                        postObject.setValue(post)
                        
                        let alert = UIAlertController(title: "Success", message: "Your inquiry has been sent! Expect a reply within the next 6 hours!", preferredStyle: .Alert)
                        let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: { (action) in
                            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("mainVC")
                            self.presentViewController(vc!, animated: false, completion: nil)
                        })
                        alert.addAction(defaultAction)
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                } else {
                    NSLog("something went wrong... \(email)")
                    let alert = UIAlertController(title: "Alert", message: "Something went wrong... Please try again later. If this issue persists, please contact support.", preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                    alert.view.tintColor = UIColor.redColor()
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            })
            }
        }
        } else {
            NSLog("Fields not filled...")
            let alert = UIAlertController(title: "Alert", message: "You did not fill out one or more fields.", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            alert.view.tintColor = UIColor.redColor()
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if contentTextView.text == "What is your problem or assignment?" {
            contentTextView.text = nil
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "What is your problem or assignment?"
        }
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        let newText = (contentTextView.text as NSString).stringByReplacingCharactersInRange(range, withString: text)
        let numberOfChars = newText.characters.count // for Swift use count(newText)
        return numberOfChars <= 300;
    }
    
    func textViewDidChange(textView: UITextView) {
        let numberOfChars = contentTextView.text.characters.count
        self.letterCounterLabel.text = "\(numberOfChars) / 300"
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

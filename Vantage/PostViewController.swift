//
//  PostViewController.swift
//  Vantage
//
//  Created by Parth Saxena on 7/1/16.
//  Copyright © 2016 Socify. All rights reserved.
//

import UIKit
import Firebase

class PostViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate {

    @IBOutlet var letterCounterLabel: UILabel!
    @IBOutlet var selectImageButton: UIButton!
    @IBOutlet var postImageView: UIImageView!
    @IBOutlet weak var titleTextField: JiroTextField!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var subjectField: JiroTextField!
    
    var imageFileName = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        contentTextView.delegate = self
        
        self.navigationController!.navigationBar.barTintColor = UIColor.blackColor()
        self.navigationController!.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Roboto", size: 30)!, NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.title = "Post To \(GlobalVariables._currentSubjectPostingTo)"
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
            self.selectImageButton.alpha = 0
            postImageView.image = pickedImage
            
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
    
    @IBAction func postTapped(sender: AnyObject) {
        if (self.imageFileName == "") {
            let alert = PSAlert.sharedInstance.instantiateAlert("Error", alertText: "Your image has not finished uploading. Please wait a moment...")
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
        
            let currentUID = FIRAuth.auth()?.currentUser?.uid
        
            let timestamp = FIRServerValue.timestamp()
            
            let randomID = randomStringWithLength(15)
            
            let post: Dictionary<String, AnyObject> = [
                "title": self.titleTextField.text!,
                "content": self.contentTextView.text!,
                "image": self.imageFileName,
                "username": currentUID!,
                "subject": GlobalVariables._currentSubjectPostingTo,
                "createdAt": timestamp,
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
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if contentTextView.text == "Explain your assignment or problem..." {
            contentTextView.text = nil
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Explain your assignment or problem..."
        }
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        let newText = (contentTextView.text as NSString).stringByReplacingCharactersInRange(range, withString: text)
        let numberOfChars = newText.characters.count // for Swift use count(newText)
        return numberOfChars <= 140;
    }
    
    func textViewDidChange(textView: UITextView) {
        let numberOfChars = contentTextView.text.characters.count
        self.letterCounterLabel.text = "\(numberOfChars) / 140"
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

//
//  ChatViewController.swift
//  Vantage
//
//  Created by Parth Saxena on 3/30/17.
//  Copyright © 2017 Socify. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import Firebase
import OneSignal

class ChatViewController: JSQMessagesViewController, UINavigationControllerDelegate {

    let incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImage(with: UIColor.black)
    let outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    var messages = [JSQMessage]()
    
    let messageRef = FIRDatabase.database().reference().child("chats").child(GlobalVariables._chatID)
    
    var toSendNotificationID = ""
    var inquiryTitle = ""
    
    var isOtherUserTyping = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.inputToolbar.contentView.leftBarButtonItem = nil
        
        self.navigationController?.navigationBar.alpha = 0
        self.navigationController!.navigationBar.barTintColor = UIColor.white
        self.navigationController!.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Roboto", size: 30)!, NSForegroundColorAttributeName: UIColor.black]
        
        self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        self.automaticallyScrollsToMostRecentMessage = true
        self.senderId = FIRAuth.auth()?.currentUser?.uid
        self.senderDisplayName = "Parth"
        
        /* get all messages
        messageRef.child("messages").observeSingleEvent(of: .value, with: { (snapshot) in
            if let messagesDictionary = snapshot.value as? [String: Any] {
                
                let sortedDictionary = messagesDictionary.sorted {
                    let createdAtOne = ($0.1 as! [String : AnyObject])["createdAt"] as! Int
                    let createdAtTwo = ($1.1 as! [String : AnyObject])["createdAt"] as! Int
                    return createdAtOne > createdAtTwo
                }
                
                for message in sortedDictionary {
                    print("Processing message (all)")
                    if let senderID = (message.value as? [String: Any])?["uid"] as? String {
                        if let message = (message.value as? [String: Any])?["message"] as? String {
                            print("MESSAGE: \(message)")
                            if let jsqMessage = JSQMessage(senderId: senderID, displayName: "Anonymous", text: message) {
                                self.messages.append(jsqMessage)
                                self.finishReceivingMessage(animated: true)
                            }
                        } else {
                            print("Couldn't cast message.")
                        }
                    } else {
                        print("Couldn't cast sender ID.")
                    }
                }
            }
        })*/
        
        messageRef.observe(.value, with: { (snapshot) in
            if let chatDictionary = snapshot.value as? [String: Any] {
                //print("ChatDictionary: \(chatDictionary)")
                self.inquiryTitle = (chatDictionary["inquiryTitle"] as? String)!
                if chatDictionary["uidOne"] as? String == FIRAuth.auth()?.currentUser?.uid {
                    //print("user is uidOne, other user is uidTwo")
                    let uidTwo = chatDictionary["uidTwo"] as? String
                    FIRDatabase.database().reference().child("users").child(uidTwo!).observe(.value, with: { (snapshot) in
                        if let userDictionary = snapshot.value as? [String: Any] {
                            if let notificationID = userDictionary["notification_id"] as? String {
                                self.toSendNotificationID = notificationID
                            }
                        }
                    })
                } else {
                    //print("user is uidTwo, other user is uidOne")
                    FIRDatabase.database().reference().child("users").child((chatDictionary["uidOne"] as? String)!).observe(.value, with: { (snapshot) in
                        if let userDictionary = snapshot.value as? [String: Any] {
                            if let notificationID = userDictionary["notification_id"] as? String {
                                //print("notificationID: \(notificationID)")
                                self.toSendNotificationID = notificationID
                            } else {
                                print("couldn't cast notificationID, \(userDictionary)")
                            }
                        } else {
                            print("couldn't cast userDictionary, \(snapshot.value)")
                        }
                    })
                }
            }
        })
        
        // auto update for messages
        messageRef.child("messages").observe(.childAdded, with: { (snapshot) in
            if let messagesDictionary = snapshot.value as? [String: Any] {
                print("Processing message (auto-update)")
                if let senderID = messagesDictionary["uid"] as? String {
                    if let message = messagesDictionary["message"] as? String {
                        //print("MESSAGE: \(message)")
                        if let createdAt = messagesDictionary["createdAt"] as? TimeInterval {
                            let date = Date(timeIntervalSince1970: createdAt / 1000)
                            if let jsqMessage = JSQMessage(senderId: senderID, senderDisplayName: "Anonymous", date: date, text: message) {
                                //print("added date, jsq: \(jsqMessage.date), date: \(date)")
                                self.messages.append(jsqMessage)
                                self.finishReceivingMessage(animated: true)
                                if self.isOtherUserTyping {
                                    self.showTypingIndicator = true
                                    self.scrollToBottom(animated: true)
                                }
                            }
                        }
                        /*if let jsqMessage = JSQMessage(senderId: senderID, displayName: "Anonymous", text: message) {
                        }*/
                    } else {
                        print("Couldn't cast message.")
                    }
                } else {
                    print("Couldn't cast sender ID. \(messagesDictionary)")
                }
            }
        })
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        observeTyping()
        if GlobalVariables._isStartingNewChat {
            // user is starting new chat
            self.inputToolbar.contentView.textView.becomeFirstResponder()
        }
    }
    
    func sendMessage(message: String) {        
        let timestamp = FIRServerValue.timestamp()
        
        if let senderCurrent = FIRAuth.auth()?.currentUser?.uid {
            messageRef.child("messages").childByAutoId().setValue([
                "createdAt": timestamp as AnyObject,
                "message": message,
                "uid": senderCurrent
            ])
            messageRef.updateChildValues([
                "latestMessage": message,
                "latestTimestamp": timestamp as AnyObject
            ])
        }
        
        OneSignal.postNotification(["headings": ["en": self.inquiryTitle], "contents": ["en": "Anonymous: \"\(message)\""], "data": ["type":"chat-message", "chatID":GlobalVariables._chatID], "include_player_ids": [self.toSendNotificationID]], onSuccess: { (nil) in
            //print("Sent chat-message notification.")
        }) { (error) in
            print("Error sending chat-message notification, \(error), \(self.toSendNotificationID)")
        }
    
        print("Sent message.")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func textViewDidChange(_ textView: UITextView) {
        super.textViewDidChange(textView)
        isTyping = textView.text != ""
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let message = self.messages[indexPath.row]
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        if message.senderId == self.senderId {
            cell.textView.textColor = UIColor.black
        } else {
            cell.textView.textColor = UIColor.white
        }
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.messages.count
    }        
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, messageDataForItemAt indexPath: IndexPath) -> JSQMessageData {
        let data = self.messages[indexPath.row]
        return data
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, messageBubbleImageDataForItemAt indexPath: IndexPath) -> JSQMessageBubbleImageDataSource {
            let data = messages[indexPath.row]
            switch(data.senderId) {
            case self.senderId:
                return self.outgoingBubble!
            default:
                return self.incomingBubble!
            }
    }
    
    override func didPressSend(_ button: UIButton, withMessageText text: String, senderId: String, senderDisplayName: String, date: Date) {
        self.finishSendingMessage(animated: true)
        isTyping = false
        self.sendMessage(message: text)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, avatarImageDataForItemAt indexPath: IndexPath) -> JSQMessageAvatarImageDataSource? {
        return nil
    }
    
    /*override func collectionView(_ collectionView: JSQMessagesCollectionView, attributedTextForCellTopLabelAt indexPath: IndexPath) -> NSAttributedString? {
        if (indexPath.item % 3 == 0) {
            let message = self.messages[indexPath.item]
            if let date = message.date {
                return JSQMessagesTimestampFormatter.shared().attributedTimestamp(for: date)
            }
        }
        return nil
    }*/
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout, heightForMessageBubbleTopLabelAt indexPath: IndexPath) -> CGFloat {
        if indexPath.item == 0 {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        
        if indexPath.item > 0 {
            let previousMessage = self.messages[indexPath.item - 1]
            let message = self.messages[indexPath.item]
            if message.date.timeIntervalSince(previousMessage.date) / 60 > 1 {
                return kJSQMessagesCollectionViewCellLabelHeightDefault
            }
        }
        
        return 0.0
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAt indexPath: IndexPath) -> CGFloat {
        if indexPath.item == 0 {
            return 0.0
        }
        
        if indexPath.item > 0 {
            let previousMessage = self.messages[indexPath.item - 1]
            let message = self.messages[indexPath.item]
            if message.date.timeIntervalSince(previousMessage.date) / 60 > 1 {
                return kJSQMessagesCollectionViewCellLabelHeightDefault
            }
        }
        
        return 0.0
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath) -> NSAttributedString? {
        if indexPath.item == 0 {
            return JSQMessagesTimestampFormatter().attributedTimestamp(for: self.messages[indexPath.item].date)
        }
        
        if indexPath.item > 0 {
            let previousMessage = self.messages[indexPath.item - 1]
            let message = self.messages[indexPath.item]
            if message.date.timeIntervalSince(previousMessage.date) / 60 > 1 {
                return JSQMessagesTimestampFormatter().attributedTimestamp(for: self.messages[indexPath.item].date)
            }
        }
        
        return nil
    }
    
    private func observeTyping() {
        let typingIndicatorRef = messageRef.child("typingIndicator")
        userIsTypingRef = typingIndicatorRef.child(senderId)
        userIsTypingRef.onDisconnectRemoveValue()
        
        usersTypingQuery.observe(.value) { (data: FIRDataSnapshot) in
            // 2 You're the only one typing, don't show the indicator
            if data.childrenCount == 1 && self.isTyping {
                print("hiding indicator, \(data.childrenCount), \(self.isTyping)")
                self.showTypingIndicator = false
                return
            } else {
                // 3 Are there others typing?
                self.showTypingIndicator = data.childrenCount > 0
                self.isOtherUserTyping = data.childrenCount > 0
                self.scrollToBottom(animated: true)
                print("displaying indicator, \(data.childrenCount), \(self.isTyping)")
            }
        }
    }
    
    private lazy var usersTypingQuery: FIRDatabaseQuery =
        self.messageRef.child("typingIndicator").queryOrderedByValue().queryEqual(toValue: true)
    private lazy var userIsTypingRef: FIRDatabaseReference =
        self.messageRef.child("typingIndicator").child(self.senderId)
    private var localTyping = false
    var isTyping: Bool {
        get {
            return localTyping
        }
        set {
            // 3
            localTyping = newValue
            userIsTypingRef.setValue(newValue)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

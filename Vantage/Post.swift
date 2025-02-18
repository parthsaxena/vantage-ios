//
//  Post.swift
//  Vantage
//
//  Created by Parth Saxena on 6/30/16.
//  Copyright © 2016 Socify. All rights reserved.
//

import Foundation
import Firebase

class Post {
    fileprivate var _postRef: FIRDatabaseReference!
    
    fileprivate var _postKey: String!
    fileprivate var _postTitle: String!
    fileprivate var _postContent: String!
    fileprivate var _username: String!
    fileprivate var _imageFileKey: String!
    
    var postKey: String {
        return _postKey
    }
    
    var postTitle: String {
        return _postTitle
    }
    
    var postContent: String {
        return _postContent
    }
    
    var username: String {
        return _username
    }
    
    var imageFileKey: String {
        return _imageFileKey
    }
    
    // Initialize the new Joke
    
    init(key: String, dictionary: Dictionary<String, AnyObject>) {
        self._postKey = key
        
        // Within the Joke, or Key, the following properties are children
        
        if let postTitle = dictionary["title"] as? String {
            
            self._postTitle = postTitle
        }
        
        if let postContent = dictionary["content"] as? String {
            self._postContent = postContent
        }
        
        if let user = dictionary["username"] as? String {
            self._username = user
        } else {
            self._username = ""
        }
        
        if let postImageKey = dictionary["image"] as? String {
            self._imageFileKey = postImageKey
        }
        
        // The above properties are assigned to their key.
        
        self._postRef = FIRDatabase.database().reference().child("posts").child(byAppendingPath: self._postKey)
    }
}

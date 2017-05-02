//
//  GlobalVariables.swift
//  Vantage
//
//  Created by Parth Saxena on 7/1/16.
//  Copyright © 2016 Socify. All rights reserved.
//

import Foundation

class GlobalVariables {
    static var _chatID: String = "1238110283481"
    static var _allChatIDs = [String]()
    static var _school = ""
    static var _currentUserDictionary: [String : AnyObject]!
    
    static var _currentSubjectPostingTo = ""
    
    static var _currentInquiryIDAnswering = ""
    
    static var _currentUserAnswering = ""
    
    static var _coinsAmount = ""
    
    static var _displayRateAlert = false
    
    static var _isStartingNewChat = false
    
    static var _answerChooseSubjectContentOffset: CGPoint!
    static var _chooseSubjectContentOffset: CGPoint!
    
    static var _isViewingAllInquiries = false
}

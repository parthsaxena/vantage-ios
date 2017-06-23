//
//  AppDelegate.swift
//  Vantage
//
//  Created by Parth Saxena on 6/30/16.
//  Copyright © 2016 Socify. All rights reserved.
//

import UIKit
import Firebase
import FirebaseMessaging
import IQKeyboardManagerSwift
import Armchair
import BRYXBanner

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FIRApp.configure()
        //Stripe.setDefaultPublishableKey("pk_test_NnzeD5zsk1xqPSvEGGhGT5f0")
        
        if FIRAuth.auth()?.currentUser == nil {
            // user not logged in
            print("USER NOT LOGGED IN")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let homeVC : UIViewController = storyboard.instantiateViewController(withIdentifier: "homeVC") as UIViewController
            self.window = UIWindow(frame: UIScreen.main.bounds)
            self.window?.rootViewController = homeVC
            self.window?.makeKeyAndVisible()
        } else {
            // user logged in
            print("USER LOGGED IN")
        }
        
        var appID = "5832457719ebf7b7170001e8"
        var sdk = VungleSDK.shared()
        sdk?.start(withAppId: appID)
        
        Armchair.appID("1140243092")
        Armchair.appName("Vantage")
        Armchair.significantEventsUntilPrompt(8)
        
        IQKeyboardManager.sharedManager().enable = true        
                
        //OneSignal.initWithLaunchOptions(launchOptions, appId: "9fffb537-914a-481a-9f17-a22e2df2c5bb")
        OneSignal.initWithLaunchOptions(launchOptions, appId: "9fffb537-914a-481a-9f17-a22e2df2c5bb", handleNotificationAction: nil, settings: [kOSSettingsKeyInFocusDisplayOption: OSNotificationDisplayType.none.rawValue])
        
        if (UserDefaults.standard.bool(forKey: "HasLaunchedOnce")) {
            // app has been launched before
            
            let launches = UserDefaults.standard.integer(forKey: "numberOfLaunches")
            UserDefaults.standard.set(launches + 1, forKey: "numberOfLaunches")
            
        } else {
            // app is being run for first time
            UserDefaults.standard.set(false, forKey: "userRated")
            UserDefaults.standard.set(1, forKey: "numberOfLaunches")
        }
        
        //OneSignal.defaultClient().enableInAppAlertNotification(true)
        
        return true
    }
    
    /*func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        if (application.applicationState == UIApplicationState.active) {
            // show your banner
            print("APPLICATION ACTIVE WHILE RECEIVING NOTIFICATION")
        } else {
            print("RECEIVED NOTIFICATION, \(application.applicationState)")
        }
    }*/
    
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void)
    {
        
        print("Recived Notification: \(userInfo)")
        
        if (application.applicationState == UIApplicationState.active) {
            if let dict = userInfo["custom"] as? NSDictionary {
                if let type = (dict["a"] as? NSDictionary)?["type"] as? String {
                    if type == "chat-message" {
                        if let chatID = (dict["a"] as? NSDictionary)?["chatID"] as? String {
                            if chatID == GlobalVariables._chatID && getCurrentViewController() is ChatViewController {
                                // user received chat message for chat the user is currently in
                                print("User received chat message for chat the user is currently in")
                            } else {
                                print("Displaying BRYX notification, \((userInfo["custom"] as? NSDictionary)?["type"] as? String)")
                                print("NOT IN CHAT: \(GlobalVariables._chatID), \(getCurrentViewController())")
                                let banner = Banner(title: "Chat Message", subtitle: "You have received a chat message.", image: UIImage(named: "message"), backgroundColor: UIColor(red:48.00/255.0, green:174.0/255.0, blue:51.5/255.0, alpha:1.000))
                                banner.dismissesOnTap = true
                                banner.show(duration: 3.0)
                            }
                        }
                    } else if type == "new-chat" {
                        let banner = Banner(title: "New Chat", subtitle: "A responder has started a chat with you.", image: UIImage(named: "inbox"), backgroundColor: UIColor(red:48.00/255.0, green:174.0/255.0, blue:51.5/255.0, alpha:1.000))
                        banner.dismissesOnTap = true
                        banner.show(duration: 3.0)
                    } else if type == "answer-to-inquiry" {
                        let banner = Banner(title: "New Answer", subtitle: "You have received an answer to your inquiry!", image: UIImage(named: "answer-to-inquiry"), backgroundColor: UIColor(red:48.00/255.0, green:174.0/255.0, blue:51.5/255.0, alpha:1.000))
                        banner.dismissesOnTap = true
                        banner.show(duration: 3.0)
                    }
                }
            }
        }
        
        completionHandler(.newData)
        
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        if (UserDefaults.standard.bool(forKey: "HasLaunchedOnce")) {
            // app launched for first time
            
            UserDefaults.standard.set(1, forKey: "numberOfLaunches")
            
        } else {
            // app has been launched before
            let launches = UserDefaults.standard.integer(forKey: "numberOfLaunches")
            UserDefaults.standard.set(launches + 1, forKey: "numberOfLaunches")
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        print("We made it here! \(shortcutItem)")
        if shortcutItem.type == "com.socify.Vantage.ask" {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "chooseSubjectVC")
            let rootVC = UIApplication.shared.keyWindow?.rootViewController
            rootVC?.present(vc, animated: false, completion: { 
                completionHandler(true)
            })
        } else if shortcutItem.type == "com.socify.Vantage.answer" {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "answerChooseSubjectVC")
            let rootVC = UIApplication.shared.keyWindow?.rootViewController
            rootVC?.present(vc, animated: false, completion: {
                completionHandler(true)
            })
        }
    }
    
}

func getCurrentViewController() -> UIViewController? {
    
    // If the root view is a navigation controller, we can just return the visible ViewController
    if let navigationController = getNavigationController() {
        
        return navigationController.visibleViewController
    }
    
    // Otherwise, we must get the root UIViewController and iterate through presented views
    if let rootController = UIApplication.shared.keyWindow?.rootViewController {
        
        var currentController: UIViewController! = rootController
        
        // Each ViewController keeps track of the view it has presented, so we
        // can move from the head to the tail, which will always be the current view
        while( currentController.presentedViewController != nil ) {
            
            currentController = currentController.presentedViewController
        }
        return currentController
    }
    return nil
}

// Returns the navigation controller if it exists
func getNavigationController() -> UINavigationController? {
    
    if let navigationController = UIApplication.shared.keyWindow?.rootViewController  {
        
        return navigationController as? UINavigationController
    }
    return nil
}

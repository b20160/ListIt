//
//  AppDelegate.swift
//  ListIt
//
//  Created by Jonathan Green on 12/8/15.
//  Copyright © 2015 Jonathan Green. All rights reserved.
//

import UIKit
import Parse
import Bolts
import Venmo_iOS_SDK
import IQKeyboardManagerSwift
import SwiftEventBus

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        Parse.enableLocalDatastore()
        
        
        //push notification
        
        let alert = UIRemoteNotificationType.Alert
        let sound = UIRemoteNotificationType.Sound
        let badge = UIRemoteNotificationType.Badge
        application.registerForRemoteNotificationTypes([alert,sound,badge])
        application.registerForRemoteNotifications()
        
        // Initialize Parse.
        Parse.setApplicationId("TNSeu9vfrUdDkyMEk5px6WKVUWNDsxmHJTTe5ukU",
            clientKey: "6BZMO0tkYGKrDTtZTECneW8qHkWhUIHLBrDOOtyq")
        
        // [Optional] Track statistics around application opens.
        PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
        
        //Venmo config
        
        let appId = "3282"
        
        let secert = "NPpEVNKsJuxUD4KyA4h6GWFfuZgGUF7W"
        
        let appName = "List-it"
        
        Venmo.startWithAppId(appId, secret: secert, name: appName)
        
        //enables IQKeyboardManager
        IQKeyboardManager.sharedManager().enable = true
        
        return true
    }
    
    
    //push notificaitons
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let installation = PFInstallation.currentInstallation()
        installation.setDeviceTokenFromData(deviceToken)
        installation.channels = ["global"]
        installation.saveInBackground()
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        PFPush.handlePush(userInfo)
        
        SwiftEventBus.post("NewMessage")
    }
     //push notificaitons end

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
        
        if Venmo.sharedInstance().handleOpenURL(url) {
            
            return true
        }
        
        return false
    }


}


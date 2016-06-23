//
//  AppDelegate.swift
//  Timeline
//
//  Created by Caleb Hicks on 5/27/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import UIKit
import CloudKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        let notificationSettings = UIUserNotificationSettings(forTypes: [.Alert, .Sound, .Badge], categories: nil)
        
        UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
        
        UIApplication.sharedApplication().registerForRemoteNotifications()
        
        return true
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        
        guard let notificationInfo = userInfo as? [String:NSObject] else { print("No record ID available from CKQueryNotification"); return }
        
        let queryNotification = CKQueryNotification(fromRemoteNotificationDictionary: notificationInfo)
        
        guard let recordID = queryNotification.recordID else { print("No record ID available from CKQueryNotification"); return }
        
        let cloudKitManager = CloudKitManager()
        
        cloudKitManager.fetchRecordWithID(recordID) { (record, error) in
            guard let record = record else { print("Unable to fetch CKRecord from Record ID"); return }
            
            switch record.recordType {
                
            case Post.typeKey:
                let _ = Post(record: record)
            case Comment.typeKey:
                let _ = Comment(record: record)
            default:
                return
            }
            PostController.sharedController.saveContext()
        }
        completionHandler(UIBackgroundFetchResult.NewData)
    }
}


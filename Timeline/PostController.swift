//
//  PostController.swift
//  Timeline
//
//  Created by Sean Gilhuly on 6/13/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import Foundation
import UIKit
import CloudKit
import CoreData

class PostController {
    
    static let sharedController = PostController()
    
    let cloudKitManager = CloudKitManager()
    
    var posts: [Post] {
        
        let fetchRequest = NSFetchRequest(entityName:"Post")
        let sortDescriptor = NSSortDescriptor(key: "timestamp", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let results = (try? Stack.sharedStack.managedObjectContext.executeFetchRequest(fetchRequest)) as? [Post] ?? []
        
        return results
    }
    
    init() {
        
        subscribeToNewPosts { (success, error) in
            if success {
                print("Successfully subscribed to new posts.")
            }
        }
        
        performFullSync()
        
        
    }
    
    // MARK - CRUD Functions
    
    func saveContext() {
        let moc = Stack.sharedStack.managedObjectContext
        do {
            try moc.save()
        } catch {
            print("Unable to save context: \(error)")
            print("There was an error saving the context")
        }
    }
    
    func createPost(image: UIImage, caption: String) {
        guard let data = UIImageJPEGRepresentation(image, 0.9) else { return }
        let post = Post(photoData: data)
        addCommentToPost(caption, post: post)
        saveContext()
        
        if let cloudKitRecord = post.cloudKitRecord {
            cloudKitManager.saveRecord(cloudKitRecord) { (record, error) in
                if let error = error {
                    NSLog("Error saving cloudkit record for new post \(post): \(error)")
                }
                guard let record = record else { return }
                
                post.update(record)
            }
        }
    }
    
    func addCommentToPost(text: String, post: Post) {
        let comment = Comment(post: post, text: text)
        saveContext()
        
        if let cloudKitRecord = comment.cloudKitRecord {
            cloudKitManager.saveRecord(cloudKitRecord, completion: { (record, error) in
                if let error = error {
                    NSLog("Error saving cloudkit recrod for new comment \(comment): \(error)")
                    return
                }
                guard let record = record else { return }
                
                comment.update(record)
            })
        }
    }
    
    // MARK: Helper functions
    
    func postWithName(name: String) -> Post? {
        if name.isEmpty {
            return nil
        }
        let fetchRequest = NSFetchRequest(entityName: "Post")
        let predicate = NSPredicate(format: "recordName == %@", argumentArray: [name])
        fetchRequest.predicate = predicate
        
        let result = (try? Stack.sharedStack.managedObjectContext.executeFetchRequest(fetchRequest) as? [Post]) ?? nil
        
        return result?.first
    }
    
    func syncedRecords(type: String) -> [CloudKitManagedObject] {
        let fetchRequest = NSFetchRequest(entityName: type)
        fetchRequest.predicate = NSPredicate(format: "recordIDData != nil")
        
        let moc = Stack.sharedStack.managedObjectContext
        let results = (try? moc.executeFetchRequest(fetchRequest)) as? [CloudKitManagedObject] ?? []
        return results
    }
    
    func unsyncedRecords(type: String) -> [CloudKitManagedObject] {
        let fetchRequest = NSFetchRequest(entityName: type)
        fetchRequest.predicate = NSPredicate(format: "recordIDData == nil")
        
        let moc = Stack.sharedStack.managedObjectContext
        let results = (try? moc.executeFetchRequest(fetchRequest)) as? [CloudKitManagedObject] ?? []
        return results
    }
    
    func fetchNewRecords(type: String, completion: (() -> Void)?) {
        let referencesToExclude = syncedRecords(type).flatMap { $0.cloudKitReference }
        let predicate: NSPredicate
        if !referencesToExclude.isEmpty {
            predicate = NSPredicate(format: "NOT(recordID IN %@)", referencesToExclude)
        } else {
            predicate = NSPredicate(value: true)
        }
        
        cloudKitManager.fetchRecordsWithType(type, predicate: predicate, recordFetchedBlock: { (record) in
            switch type {
            case "Post":
                let _ = Post(record: record)
            case "Comment":
                let _ = Comment(record: record)
            default:
                return
            }
            
            self.saveContext()
        }) { (records, error) in
            if let error = error {
                NSLog("Error fetching new records from CloudKit: \(error)")
            }
            
            completion?()
        }
    }
    
    func pushChangesToCloudKit(completion: ((success: Bool, error: NSError?) -> Void)? = nil) {
        let unsavedManagedObjects = unsyncedRecords(Post.typeKey) + unsyncedRecords(Comment.typeKey)
        let unsavedRecords = unsavedManagedObjects.flatMap { $0.cloudKitRecord }
        
        cloudKitManager.saveRecords(unsavedRecords, perRecordCompletion: { (record, error) in
            guard let record = record else { return }
            
            if let matchingManagedObject = unsavedManagedObjects.filter({$0.recordName == record.recordID.recordName}).first {
                matchingManagedObject.update(record)
            }
            
        }) { (records, error) in
            let success = records != nil
            completion?(success: success, error: error)
        }
    }
    
    private var isSyncing = false
    func performFullSync(completion: (() -> Void)? = nil) {
        if isSyncing {
            completion?()
            return
        }
        
        isSyncing = true
        
        pushChangesToCloudKit { (success) in
            self.fetchNewRecords(Post.typeKey) {
                self.fetchNewRecords(Comment.typeKey) {
                    completion?()
                    self.isSyncing = false
                }
            }
        }
    }
    
    // MARK: - Subscriptions
    
    func subscribeToNewPosts(completion: ((success: Bool, error: NSError?) -> Void)?) {
        
        let predicate = NSPredicate(value: true)
        
        cloudKitManager.subscribe(Post.typeKey, predicate: predicate, subscriptionID: "allPosts", contentAvailable: true, options: .FiresOnRecordCreation) { (subscription, error) in
            if let completion = completion {
                let success = (subscription != nil)
                completion(success: success, error: error)
            }
        }
    }
    
    func addSubscriptionToPostComments(post: Post, alertBody: String?, completion: ((success: Bool, error: NSError?) -> Void)?) {
        
        guard let recordID = post.cloudKitRecordID else { fatalError("Unable to create CloudKit reference for subscription") }
        
        let predicate = NSPredicate(format: "post == %@", argumentArray: [recordID])
        
        cloudKitManager.subscribe(Comment.typeKey, predicate: predicate, subscriptionID: post.recordName, contentAvailable: true, alertBody: alertBody, desiredKeys: [Comment.typeKey, Comment.postKey], options: .FiresOnRecordCreation) { (subscription, error) in
            if let completion = completion {
                let success = subscription != nil
                completion(success: success, error: error)
            }
        }
    }
    
    func removeSubscriptionToPostComments(post: Post, completion: ((success: Bool, error: NSError?) -> Void)?) {
        
        let subscriptionID = post.recordName
        
        cloudKitManager.unsubscribe(subscriptionID) { (subscriptionID, error) in
            if let completion = completion {
                let success = (subscriptionID != nil)
                completion(success: success, error: error)
            }
        }
    }
    
    func checkSubscriptionToPostComments(post: Post, completion: ((subscribed: Bool) -> Void)?) {
        
        cloudKitManager.fetchSubscription(post.recordName) { (subscription, error) in
            if let completion = completion {
                let succes = (subscription != nil)
                completion(subscribed: succes)
            }
        }
    }
    
    func togglePostCommentsSubscription(post: Post, completion: ((success: Bool, isSubscribed: Bool, error: NSError?) -> Void)?) {
        
        cloudKitManager.fetchSubscriptions { (subscriptions, error) in
            if subscriptions?.filter({ $0.subscriptionID == post.recordName}).first != nil {
                self.removeSubscriptionToPostComments(post, completion: { (success, error) in
                    if let completion = completion {
                        completion(success: success, isSubscribed: false, error: error)
                    }
                })
            } else {
                self.addSubscriptionToPostComments(post, alertBody: "Someone commented on a post you followed!", completion: { (success, error) in
                    if let completion = completion {
                        completion(success: success, isSubscribed: true, error: error)
                    }
                })
            }
        }
    }
    
    
    
    
}















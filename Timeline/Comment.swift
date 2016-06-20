//
//  Comment.swift
//  Timeline
//
//  Created by Sean Gilhuly on 6/13/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import Foundation
import CoreData
import CloudKit

class Comment: SyncableObject, SearchableRecord, CloudKitManagedObject {
    
    static let typeKey = "Comment"

    convenience init(post: Post, text: String, timestamp: NSDate = NSDate(), context: NSManagedObjectContext = Stack.sharedStack.managedObjectContext) {
        
        guard let entity = NSEntityDescription.entityForName("Comment", inManagedObjectContext: context) else {
            fatalError() }
        
        self.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.post = post
        self.text = text
        self.timestamp = timestamp
        self.recordName = nameForManagedObject()
    }
    
    //MARK: - SearchableRecord Protocol Methods
    
    func matchesSearchTerm(searchTerm: String) -> Bool {
        return text?.containsString(searchTerm) ?? false
    }
    
    // MARK: - CloudKitManagedObjects Methods
    
    var recordType: String = "Comment"
    
    var cloudKitRecord: CKRecord? {
        let recordID = CKRecordID(recordName: recordName)
        let record = CKRecord(recordType: recordType, recordID: recordID)
        
        record["text"] = text
        record["timestamp"] = timestamp
        
        guard let post = post,
            postRecord = post.cloudKitRecord else {
                fatalError("Comment does not have a Post relationship.  \(#function)")
        }
        // A relationship in CloudKit is CKReference
        record["post"] = CKReference(record: postRecord, action: .DeleteSelf)
        return record
    }
    
    convenience required init?(record: CKRecord, context: NSManagedObjectContext = Stack.sharedStack.managedObjectContext) {
        
        guard let timestamp = record.creationDate,
            text = record["text"] as? String,
            postReference = record["post"] as? CKReference else {
                return nil
        }
        //If you had a Key, it would not be "Comment", but Comment.typeKey
        guard let entity = NSEntityDescription.entityForName("Comment", inManagedObjectContext: context) else {
            fatalError("Error: CoreData failed to create entity from entity description. \(#function)")
        }
        self.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.timestamp = timestamp
        self.text = text
        self.recordIDData = NSKeyedArchiver.archivedDataWithRootObject(record.recordID)
        self.recordName = record.recordID.recordName
        
        if let post = PostController.sharedController.postWithName(postReference.recordID.recordName) {
            self.post = post
        }
    }
}
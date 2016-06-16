//
//  Post.swift
//  Timeline
//
//  Created by Sean Gilhuly on 6/14/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//


import Foundation
import CoreData
import UIKit
import CloudKit

class Post: SyncableObject, SearchableRecord, CloudKitManagedObject {
    
    static let typeKey = "Post"
    static let photoDataKey = "photoData"
    static let timestampKey = "timestamp"
    
    convenience init(photoData: NSData, timestamp: NSDate = NSDate(), context: NSManagedObjectContext = Stack.sharedStack.managedObjectContext) {
        
        guard let entity = NSEntityDescription.entityForName("Post", inManagedObjectContext: context) else {
            fatalError() }
        
        self.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.photoData = photoData
        self.timestamp = timestamp
        self.recordName = NSUUID().UUIDString
    }
    
    // MARK: - Computed Properties
    
    var photo: UIImage? {
        guard let photoData = self.photoData else { return nil }
        return UIImage(data: photoData)
    }
    
    var recordType: String {
        return Post.typeKey
    }
    
    lazy var temporaryPhotoURL: NSURL = {
        
        // Must write to temporary directory to be able to pass image file path url to CKAsset
        
        let temporaryDirectory = NSTemporaryDirectory()
        let temporaryDirectoryURL = NSURL(fileURLWithPath: temporaryDirectory)
        let fileURL = temporaryDirectoryURL.URLByAppendingPathComponent(self.recordName).URLByAppendingPathExtension("jpg")
        
        self.photoData?.writeToURL(fileURL, atomically: true)
        
        return fileURL
    }()
    
    var cloudKitRecord: CKRecord? {
        let recordID = CKRecordID(recordName: recordName)
        let record = CKRecord(recordType: recordType, recordID: recordID)
        
        record[Post.timestampKey] = timestamp
        record[Post.photoDataKey] = CKAsset(fileURL: temporaryPhotoURL)
        
        return record
    }
    
    
    //MARK: - SearchableRecord Protocol
    
    func matchesSearchTerm(searchTerm: String) -> Bool {
        
        return (self.comments?.array as? [Comment])?.filter({ $0.matchesSearchTerm(searchTerm) }).count > 0
    }
}
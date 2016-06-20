//
//  CloudKitManagedObject.swift
//  Timeline
//
//  Created by Sean Gilhuly on 6/16/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import Foundation
import CoreData

import CloudKit

@objc protocol CloudKitManagedObject {
    
    var timestamp: NSDate { get set }
    var recordIDData: NSData? { get set }
    var recordName: String { get set }
    
    var recordType: String { get }
    
    var cloudKitRecord: CKRecord? { get }  // CoreData version of dictionaryCopy
    
    init?(record: CKRecord, context: NSManagedObjectContext)
}

extension CloudKitManagedObject {
    
    var isSynced: Bool {
        return recordIDData != nil
    }
    
    // Transform NSData to a CKRecordID (serialization)
    var cloudKitRecordID: CKRecordID? {
        guard let recordIDData = recordIDData,
        let recordID = NSKeyedUnarchiver.unarchiveObjectWithData(recordIDData) as? CKRecordID else {
            return nil
        }
        return recordID
    }
    
    var cloudKitReference: CKReference? {
        guard let recordID = cloudKitRecordID else { return nil }
        
        return CKReference(recordID: recordID, action: .None)
    }
    
    
    func update(record: CKRecord) {
        self.recordIDData = NSKeyedArchiver.archivedDataWithRootObject(record.recordID)
        
        do {
            try Stack.sharedStack.managedObjectContext.save()
        } catch {
            print("Unable to save Managed Object Context in \(#function) \(error)")
        }
    }
    
    func nameForManagedObject() -> String {
        return NSUUID().UUIDString
    }
}


// As it relates to JSON API
//
//  CKRecord = [Key:Value]
//  [CKRecordID: CKRecord]
//
// {
// "CKRecordID": CKRecord {
//      CKRecordID: CKRecord{}
//      }
// }







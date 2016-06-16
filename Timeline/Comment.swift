//
//  Comment.swift
//  Timeline
//
//  Created by Sean Gilhuly on 6/13/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import Foundation
import CoreData


class Comment: SyncableObject, SearchableRecord {
    
    convenience init(post: Post, text: String, timestamp: NSDate = NSDate(), context: NSManagedObjectContext = Stack.sharedStack.managedObjectContext) {
        
        guard let entity = NSEntityDescription.entityForName("Comment", inManagedObjectContext: context) else {
            fatalError() }
        
        self.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.post = post
        self.text = text
        self.timestamp = timestamp
        self.recordName = NSUUID().UUIDString
    }
    
    //MARK: - SearchableRecord Protocol
    
    func matchesSearchTerm(searchTerm: String) -> Bool {
        return text?.containsString(searchTerm) ?? false
    }
}
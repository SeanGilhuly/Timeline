//
//  Post.swift
//  Timeline
//
//  Created by Sean Gilhuly on 6/13/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import Foundation
import CoreData

class Post: SyncableObject {
    
    convenience init(photoData: NSData, timestamp: NSDate = NSDate(), context: NSManagedObjectContext = Stack.sharedStack.managedObjectContext) {
        
        guard let entity = NSEntityDescription.entityForName("Post", inManagedObjectContext: context) else {
            fatalError() }
        
        self.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.photoData = photoData
        self.timestamp = timestamp
    }
}

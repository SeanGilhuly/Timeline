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

class Post: SyncableObject, SearchableRecord {
    
    convenience init(photoData: NSData, timestamp: NSDate = NSDate(), context: NSManagedObjectContext = Stack.sharedStack.managedObjectContext) {
        
        guard let entity = NSEntityDescription.entityForName("Post", inManagedObjectContext: context) else {
            fatalError() }
        
        self.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.photoData = photoData
        self.timestamp = timestamp
    }
    
    var photo: UIImage? {
        guard let photoData = self.photoData else { return nil }
        return UIImage(data: photoData)
    }
    
    //MARK: - SearchableRecord Protocol
    
    func matchesSearchTerm(searchTerm: String) -> Bool {
        
        return (self.comments?.array as? [Comment])?.filter({ $0.matchesSearchTerm(searchTerm) }).count > 0    }
}
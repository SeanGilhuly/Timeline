//
//  PostController.swift
//  Timeline
//
//  Created by Sean Gilhuly on 6/13/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import Foundation
import UIKit

class PostController {
    
    static let sharedController = PostController()
    
    // MARK - CRUD Functions
    
    func saveContext() {
        do {
            try Stack.sharedStack.managedObjectContext.save()
        } catch {
            print("Unable to save context: \(error)")
        }
    }
    
    func createPost(image: UIImage, caption: String) {
        _ = Post(
        saveContext()
    }
    
    func addCommentToPost(text: String, post: Post) {
        saveContext()
    }
    
    
}
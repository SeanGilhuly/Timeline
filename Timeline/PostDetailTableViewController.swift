//
//  PostDetailTableViewController.swift
//  Timeline
//
//  Created by Sean Gilhuly on 6/13/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import UIKit
import CoreData

class PostDetailTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    // MARK: - Properties
    
    var post: Post?
    
    var fetchedResultsController = NSFetchedResultsController()
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var followPostButton: UIBarButtonItem!
    @IBOutlet weak var imageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 40
        
        setUpFetchedResultsController()
        
        if let post = post {
            updateWithPost(post)
        }
    }
   

    
    // MARK: - IBActions
    
    @IBAction func commentButtonTapped(sender: AnyObject) {
        
        let alertController = UIAlertController(title: "Add Comment", message: nil, preferredStyle: .Alert)
        
        alertController.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "What is your comment?"
        }
        
        let addCommentAction = UIAlertAction(title: "Add Comment", style: .Default) { (action) in
            
            guard let commentText = alertController.textFields?.first?.text,
                let post = self.post else { return }
            
            PostController.sharedController.addCommentToPost(commentText, post: post)
        }
        
        alertController.addAction(addCommentAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    
    @IBAction func shareButtonTapped(sender: AnyObject) {
        let alertController = UIAlertController(title: "Add Comment", message: nil, preferredStyle: .Alert)
        
        alertController.addTextFieldWithConfigurationHandler { (textField) in
            
            textField.placeholder = "Nice shot!"
        }
        
        let addCommentAction = UIAlertAction(title: "Add Comment", style: .Default) { (action) in
            
            guard let commentText = alertController.textFields?.first?.text,
                let post = self.post else { return }
            
            PostController.sharedController.addCommentToPost(commentText, post: post)
        }
        
        alertController.addAction(addCommentAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
        

    @IBAction func followPostTapped(sender: AnyObject) {
        guard let post = post else { return }
        
        self.updateWithPost(post)
    }
    
    
    //MARK: - Functions
    
    func updateWithPost(post: Post) {
        
        imageView.image = post.photo
    }
    
    func setUpFetchedResultsController() {
        guard let post = post else { fatalError("Unable to use Post to set up fetched results controller.") }
        let request = NSFetchRequest(entityName: "Comment")
        let predicate = NSPredicate(format: "post == %@", argumentArray: [post])
        let dateSortDescription = NSSortDescriptor(key: "timestamp", ascending: true)
        request.returnsObjectsAsFaults = false
        request.predicate = predicate
        request.sortDescriptors = [dateSortDescription]
        self.fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: Stack.sharedStack.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Unable to perform fetch request: \(error.localizedDescription)")
        }
        fetchedResultsController.delegate = self
    }  
}
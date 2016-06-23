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
        
        alertController.view.setNeedsLayout()
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
        PostController.sharedController.togglePostCommentsSubscription(post) { (success, isSubscribed, error) in
            self.updateWithPost(post)
        }
    }
    
    
    //MARK: - Functions
    
    func updateWithPost(post: Post) {
        
        imageView.image = post.photo
        
        PostController.sharedController.checkSubscriptionToPostComments(post) { (subscribed) in
            dispatch_async(dispatch_get_main_queue(), {
                self.followPostButton.title = subscribed ? "Unfollow Post" : "Follow Post"
            })
        }
        
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
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        guard let sections = fetchedResultsController.sections else {return 1}
        return sections.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController.sections else { return 0 }
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("commentCell", forIndexPath: indexPath)
        
        if let comment = fetchedResultsController.objectAtIndexPath(indexPath) as? Comment {
            
            cell.textLabel?.text = comment.text
            //            cell.detailTextLabel?.text = comment.cloudKitRecordID?.recordName
        }
        
        return cell
    }
    
    
    // MARK: - Delegate Methods:
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Automatic)
        case .Delete:
            tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Automatic)
        default:
            break
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Delete:
            guard let indexPath = indexPath else {
                return
            }
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        case .Insert:
            guard let newIndexPath = newIndexPath else {
                return
            }
            tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Automatic)
        case .Move:
            guard let indexPath = indexPath, newIndexPath = newIndexPath else {
                return
            }
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Automatic)
        case .Update:
            guard let indexPath = indexPath else {
                return
            }
            tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
    }
}
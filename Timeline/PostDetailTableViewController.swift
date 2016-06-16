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
    
    var fetechedResultsController = NSFetchedResultsController()
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var followPostButton: UIBarButtonItem!
    @IBOutlet weak var imageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 40
        
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
     //   TODO: this is what allows yuou to show ie. facebook, twitter, (UIActivityVC)
    }
    @IBAction func followPostTapped(sender: AnyObject) {
    }
    
    
    //MARK: - Functions
    
    func updateWithPost(post: Post) {
        
    }
    
    

    
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        guard let sessions = fetechedResultsController.sections else { return 1 }
        
        return sessions.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetechedResultsController.sections else { return 1 }
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
        
    }
}
//
//  AddPostTableViewController.swift
//  Timeline
//
//  Created by Sean Gilhuly on 6/13/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import UIKit

class AddPostTableViewController: UITableViewController {

    // MARK: - IBOutlet and Property
    
    var image: UIImage?
    
    @IBOutlet weak var captionTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    // MARK: - IBAction
    
    @IBAction func addPostTapped(sender: AnyObject) {
        
        if let image = image,
            let caption = captionTextField.text {
            
            PostController.sharedController.createPost(image, caption: caption)
            dismissViewControllerAnimated(true, completion: nil)
        } else {
            
            let alertController = UIAlertController(title: "Missing Information", message: "You did not add an image and caption.", preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: .Cancel, handler: nil))
            
            presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
       
        if segue.identifier == "embedPhotoSelect" {
            let photoSelectVC = segue.destinationViewController as? PhotoSelectViewController
            photoSelectVC?.delegate = self
        }
    }
}

//  MARK: - PhotoSelectViewControllerDelegate Delegate

extension AddPostTableViewController: PhotoSelectViewControllerDelegate {
    
    func photoSelectViewControllerSelectedImage(image: UIImage) {
        self.image = image
        
    }
}
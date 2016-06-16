//
//  AddPostTableViewController.swift
//  Timeline
//
//  Created by Sean Gilhuly on 6/13/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import UIKit

class AddPostTableViewController: UITableViewController {

    // MARK: - IBOutlet
    
    @IBOutlet weak var captionTextField: UITextField!
    
    var image: UIImage?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    // MARK: - IBAction
    
    @IBAction func addPostTapped(sender: AnyObject) {
        
        
    }
    
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
}

//  MARK: - PhotoSelectViewControllerDelegate Delegate

extension AddPostTableViewController: PhotoSelectViewControllerDelegate {
    
    func photoSelectViewControllerSelectedImage(image: UIImage) {
        self.image = image
        
    }
    
}




//
//  PostTableViewCell.swift
//  Timeline
//
//  Created by Sean Gilhuly on 6/13/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import UIKit

class PostTableViewCell: UITableViewCell {

    
    
    //MARK: - IBOutlet
    @IBOutlet weak var postImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    // MARK: - Function
    
    func updateWithPost(post: Post) {
//        guard let photoData = post.photoData else { return }
//        postImageView.image = UIImage(data: photoData)
        
        let image = UIImage(data: post.photoData ?? NSData())!
        postImageView.image = image
    }
}

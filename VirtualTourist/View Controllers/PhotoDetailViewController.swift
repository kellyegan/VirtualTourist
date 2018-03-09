//
//  PhotoDetailViewController.swift
//  VirtualTourist
//
//  Created by Kelly Egan on 3/8/18.
//  Copyright © 2018 Kelly Egan. All rights reserved.
//

import UIKit

class PhotoDetailViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var photoTitle: UILabel!
    
    var photo: Photo!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set up word wrapping on Photo title
        photoTitle.lineBreakMode = .byWordWrapping
        photoTitle.numberOfLines = 0
        
        if let image = photo.image {
            let uiImage = UIImage(data: image)
            DispatchQueue.main.async {
                self.photoTitle.text = self.photo.title ?? ""
                self.imageView.image = uiImage
            }
        }
    }
}

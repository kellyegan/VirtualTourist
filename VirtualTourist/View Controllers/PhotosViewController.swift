//
//  PhotosViewController.swift
//  VirtualTourist
//
//  Created by Kelly Egan on 2/25/18.
//  Copyright © 2018 Kelly Egan. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class PhotosViewController: UIViewController {
    
    @IBOutlet weak var topMapView: MKMapView!
    @IBOutlet weak var photosCollectionView: UICollectionView!
    
    var dataController: DataController!
    var pin: Pin!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("\(pin.latitude), \(pin.longitude)")
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
}

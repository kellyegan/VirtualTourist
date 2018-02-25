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
    var fetchedResultsController:NSFetchedResultsController<Photo>!
    var pin: Pin!
    
    fileprivate func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", pin)
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "\(pin)-notes")
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MapTools.center(map: topMapView, latitude: pin.latitude, longitude: pin.longitude, radius: 500)
        topMapView.addAnnotation(pin)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
}

extension PhotosViewController: UICollectionViewDelegate {
    
}

extension PhotosViewController: NSFetchedResultsControllerDelegate {
    
}

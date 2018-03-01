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
        let sortDescriptor = NSSortDescriptor(key: "url", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "\(pin)-photos")
        fetchedResultsController.delegate = self

        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Center map on pin and add location
        MapTools.center(map: topMapView, latitude: pin.latitude, longitude: pin.longitude, radius: 500)
        topMapView.addAnnotation(pin)
        
        photosCollectionView.collectionViewLayout = createPhotoLayout(columns: 3, columnMargin: 5, rowMargin: 7)
        
        setupFetchedResultsController()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    fileprivate func createPhotoLayout(columns: CGFloat, columnMargin: CGFloat, rowMargin: CGFloat) -> UICollectionViewFlowLayout {
        
        let photoCellSize = UIScreen.main.bounds.width / columns - columnMargin
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsetsMake(10, 0, 10, 0)
        layout.itemSize = CGSize(width: photoCellSize, height: photoCellSize)
        layout.minimumInteritemSpacing = columnMargin
        layout.minimumLineSpacing = rowMargin
        return layout
    }
}

// -------------------------------------------------------------------------
// MARK: - Collection view data source
extension PhotosViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[0].numberOfObjects ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! PhotoCell
        
        let photo = fetchedResultsController.object(at: indexPath)

        if let image = photo.image {
            //TODO: Retrieve stored image from CoreData
        } else {
            cell.imageView.image = UIImage(named: "placeholder.png")
        }
        
        return cell
    }
}

// -------------------------------------------------------------------------
// MARK: - Collection view delegate
extension PhotosViewController: UICollectionViewDelegate {

}

// -------------------------------------------------------------------------
// MARK: - Fetched Results Controller
extension PhotosViewController: NSFetchedResultsControllerDelegate {
    
}

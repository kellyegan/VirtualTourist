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
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    
    var dataController: DataController!
    var fetchedResultsController:NSFetchedResultsController<Photo>!
    var pin: Pin!
    var editCollection: Bool!
    var defaultButtonColor: UIColor!    
    var blockOperations: [BlockOperation] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Center map on pin and add location
        MapTools.center(map: topMapView, latitude: pin.latitude, longitude: pin.longitude, radius: 500)
        topMapView.addAnnotation(pin)
        
        photosCollectionView.collectionViewLayout = createPhotoLayout(columns: 3, columnMargin: 5, rowMargin: 7)
        photosCollectionView.delegate = self
        
        setupFetchedResultsController()
        
        editCollection = false
        defaultButtonColor = cancelButton.tintColor
        setEditing(editCollection)
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupFetchedResultsController()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }
    
    func deletePhoto(at indexPath: IndexPath) {
        let photoToDelete = fetchedResultsController.object(at: indexPath)
        dataController.viewContext.delete(photoToDelete)
        try? dataController.viewContext.save()
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
    
    @IBAction func editPhotosCollection(_ sender: UIBarButtonItem) {
        if( editCollection ) {
            editCollection = false
            if let indexPaths = photosCollectionView.indexPathsForSelectedItems {
                var photosToDelete = [Photo]()
                for indexPath in indexPaths {
                    photosToDelete.append(fetchedResultsController.object(at: indexPath))
                }
                for photoToDelete in photosToDelete {
                    dataController.viewContext.delete(photoToDelete)
                    try? dataController.viewContext.save()
                }
            }
        } else {
            editCollection = true
        }
        setEditing(editCollection)
    }
    
    @IBAction func cancelEditPhotoCollection(_ sender: UIBarButtonItem) {
        editCollection = false
        setEditing(editCollection)
    }
    
    @IBAction func refreshPhotoCollection(_ sender: UIBarButtonItem) {
        if let photos = fetchedResultsController.fetchedObjects {
            for photo in photos {
                dataController.viewContext.delete(photo)
            }
            try? dataController.viewContext.save()
        }
        dataController.viewContext.refreshAllObjects()
        pin.findPhotosForPin(context: dataController.viewContext)
    }
    
    fileprivate func setEditing(_ edit: Bool) {
        if let indexPaths = photosCollectionView.indexPathsForSelectedItems {
            for indexPath in indexPaths {
                if let cell = photosCollectionView.cellForItem(at: indexPath) as? PhotoCell {
                    cell.imageView.alpha = 1.0
                }
            }
        }
        if( edit ) {
            photosCollectionView.allowsMultipleSelection = true
            cancelButton.isEnabled = true
            cancelButton.tintColor = defaultButtonColor
            refreshButton.isEnabled = false
            editButton.title = "Delete selected"
        } else {
            photosCollectionView.allowsMultipleSelection = false
            cancelButton.isEnabled = false
            cancelButton.tintColor = UIColor.clear
            refreshButton.isEnabled = true
            editButton.title = "Edit"
        }
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
        
        if( editCollection ) {
            DispatchQueue.main.async {
                //If cell is selected fade it out slightly.
                cell.imageView.alpha = cell.isSelected ? 0.4 : 1.0
            }
        }

        if let image = photo.image {
            let uiImage = UIImage(data: image)
            DispatchQueue.main.async {
                cell.imageView.image = uiImage
            }
        } else {
            cell.imageView.image = UIImage(named: "placeholder.png")
            
            if let url = photo.url, let imageURL = URL(string: url) {
                let task = URLSession.shared.dataTask(with: imageURL) { (data, response, error) in
                    guard error == nil else {
                        print("ERROR: \(error!.localizedDescription)")
                        return
                    }
                    DispatchQueue.main.async {
                        photo.image = data
                    }
                }
                task.resume()
            }
        }
        
        return cell
    }
}

// -------------------------------------------------------------------------
// MARK: - Collection view delegate
extension PhotosViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if( editCollection ) {
            if let cell = photosCollectionView.cellForItem(at: indexPath) as? PhotoCell {
                cell.imageView.alpha = 0.4
            }
        } else {
            //Create new PhotosViewController
            let storyboard = UIStoryboard (name: "Main", bundle: nil)
            let photoDetailViewController = storyboard.instantiateViewController(withIdentifier: "PhotoDetailViewController") as! PhotoDetailViewController
            let photo = fetchedResultsController.object(at: indexPath) as Photo
            // Add pin to new PhotosViewController and push on to Navigation stack
            photoDetailViewController.photo = photo
            self.navigationController?.pushViewController(photoDetailViewController, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let cell = photosCollectionView.cellForItem(at: indexPath) as? PhotoCell {
            cell.imageView.alpha = 1.0
        }
    }
}

// -------------------------------------------------------------------------
// MARK: - Fetched Results Controller
extension PhotosViewController: NSFetchedResultsControllerDelegate {
    
    fileprivate func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", pin)
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "url", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    //The strategy for using the performBatchUpdates feature is based on code from this gist:
    // https://gist.github.com/Lucien/4440c1cba83318e276bb
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        blockOperations.removeAll(keepingCapacity: false)
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        guard anObject is Photo else {
            preconditionFailure("Object is not of type Photo")
        }
        
        switch type {
        case .insert:
            blockOperations.append( BlockOperation(block: {[weak self] in
                if let this = self {
                    this.photosCollectionView.insertItems(at: [newIndexPath!])
                }
            }))
        case .delete:
            blockOperations.append( BlockOperation(block: {[weak self] in
                if let this = self {
                    this.photosCollectionView.deleteItems(at: [indexPath!])
                }
            }))
        case .update:
            blockOperations.append( BlockOperation(block: {[weak self] in
                if let this = self {
                    this.photosCollectionView.reloadItems(at: [indexPath!])
                }
            }))
        case .move:
            blockOperations.append( BlockOperation(block: {[weak self] in
                if let this = self {
                    this.photosCollectionView.moveItem(at: indexPath!, to: newIndexPath!)
                }
            }))
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        photosCollectionView.performBatchUpdates({ () -> Void in
            for operation in blockOperations {
                operation.start()
            }
        }, completion: { (finished) -> Void in
            self.blockOperations.removeAll(keepingCapacity: false)
        })
    }

}

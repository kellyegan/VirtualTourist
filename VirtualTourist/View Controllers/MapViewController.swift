//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Kelly Egan on 2/16/18.
//  Copyright © 2018 Kelly Egan. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var dataController:DataController!
    var fetchedResultsController:NSFetchedResultsController<Pin>!

    fileprivate func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<Pin> = Pin.fetchRequest()
        let latitudeDescriptor = NSSortDescriptor(key: "latitude", ascending: true)
        let longitudeDescriptor = NSSortDescriptor(key: "longitude", ascending: true)
        fetchRequest.sortDescriptors = [latitudeDescriptor, longitudeDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        //Initial location Providence, RI
        MapTools.center(map: mapView, latitude: 41.8240, longitude: -71.4128, radius: 1000)
        setupFetchedResultsController()
        
        if let pins = fetchedResultsController.fetchedObjects {
            mapView.addAnnotations(pins)
        }
        
        //Setup a long press gesture > 1 second on mapView to run mapLongPress
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(MapViewController.mapLongPress(_:)))
        longPress.minimumPressDuration = 1.0
        mapView.addGestureRecognizer(longPress)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }
    
    @objc func mapLongPress(_ recognizer: UIGestureRecognizer) {
        let touchedAt = recognizer.location(in: self.mapView)
        let coordinate = mapView.convert(touchedAt, toCoordinateFrom: mapView)
        
        switch recognizer.state {
        case .began:
            //Long press has begun
            let activePin = Pin(context: dataController.viewContext)
            activePin.latitude = coordinate.latitude
            activePin.longitude = coordinate.longitude
            try? dataController.viewContext.save()
        case .ended:
            //Long press has ended
            break
        default:
            break
        }
    }
}

extension MapViewController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        guard let pin = anObject as? Pin else {
            preconditionFailure("Object is not of type Pin")
        }
        
        switch type {
        case .insert:
            mapView.addAnnotation(pin)
        case .delete:
            mapView.removeAnnotation(pin)
        case .update:
            mapView.removeAnnotation(pin)
            mapView.addAnnotation(pin)
        case .move:
            fatalError()
        }
    }
}

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let pin = view.annotation as? Pin {
            //Create new PhotosViewController
            let storyboard = UIStoryboard (name: "Main", bundle: nil)
            let photosViewController = storyboard.instantiateViewController(withIdentifier: "PhotosViewController") as! PhotosViewController
            
            // Add pin to new PhotosViewController and push on to Navigation stack
            photosViewController.pin = pin
            self.navigationController?.pushViewController(photosViewController, animated: true)            
        }
    }
}

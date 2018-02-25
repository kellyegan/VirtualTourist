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

class MapViewController: UIViewController, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    let regionRadius: CLLocationDistance = 1000
    var activePin: PinTest? = nil
    
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
        
        //Initial location Providence, RI
        let initialLocation = CLLocationCoordinate2D(latitude: 41.8240, longitude: -71.4128)
        centerMapOnLocation(location: initialLocation)
        
        setupFetchedResultsController()
        
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
    
    func centerMapOnLocation(location: CLLocationCoordinate2D) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location, regionRadius, regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    @objc func mapLongPress(_ recognizer: UIGestureRecognizer) {
        let touchedAt = recognizer.location(in: self.mapView)
        let coordinate = mapView.convert(touchedAt, toCoordinateFrom: mapView)
        
        switch recognizer.state {
        case .began:
            //Long press has begun
            activePin = PinTest(coordinate: coordinate)
            mapView.addAnnotation(activePin!)
            break
        case .ended:
            //Long press has ended
            break
        default:
            break
        }
    }
}


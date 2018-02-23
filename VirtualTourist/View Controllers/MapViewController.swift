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
    
    let regionRadius: CLLocationDistance = 1000
    var activePin: PinTest? = nil
    
    var dataController:DataController!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        //Initial location Providence, RI
        let initialLocation = CLLocationCoordinate2D(latitude: 41.8240, longitude: -71.4128)
        centerMapOnLocation(location: initialLocation)
        
        //This is more Cocoa voodoo
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(MapViewController.mapLongPress(_:)))
        longPress.minimumPressDuration = 1.0
        mapView.addGestureRecognizer(longPress)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

extension MapViewController: MKMapViewDelegate {
    func mapView( _ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? PinTest else {
            return nil
        }
        
        let identifier = "marker"
        var view: MKMarkerAnnotationView
        
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        return view
    }
}

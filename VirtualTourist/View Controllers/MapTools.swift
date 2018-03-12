//
//  MapTools.swift
//  VirtualTourist
//
//  Created by Kelly Egan on 2/25/18.
//  Copyright © 2018 Kelly Egan. All rights reserved.
//

import MapKit

struct MapTools {
    static func center( map: MKMapView, latitude: Double, longitude: Double, radius: CLLocationDistance) {
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location, radius, radius)
        DispatchQueue.main.async {
            map.setRegion(coordinateRegion, animated: true)
        }
    }
}


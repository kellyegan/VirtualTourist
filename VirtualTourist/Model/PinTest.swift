//
//  PinTest.swift
//  VirtualTourist
//
//  Created by Kelly Egan on 2/19/18.
//  Copyright © 2018 Kelly Egan. All rights reserved.
//

import Foundation
import MapKit


class PinTest: NSObject, MKAnnotation  {
    
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
        self.title = "Title"
        self.subtitle = "Subtitle"
        
        super.init()
    }

}

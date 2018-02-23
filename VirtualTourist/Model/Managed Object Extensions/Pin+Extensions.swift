//
//  Pin+Extensions.swift
//  VirtualTourist
//
//  Created by Kelly Egan on 2/21/18.
//  Copyright © 2018 Kelly Egan. All rights reserved.
//

import Foundation
import CoreData
import MapKit

extension Pin: MKAnnotation {
    public var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

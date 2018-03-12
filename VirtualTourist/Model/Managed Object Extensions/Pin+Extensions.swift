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
    
    public func findPhotosForPin( context: NSManagedObjectContext ) -> Void {
        let flickrClient = FlickrClient()
        flickrClient.findPhotosForLocation(latitude: latitude, longitude: longitude, radius: 1.0, numberOfPhotos: 21) {(results, error) -> Void in
            guard error == nil, let results = results else {
                print("Requests for photos did not work")
                return
            }
            
            for photoDetails in results {
                let photo = Photo(context: context)
                photo.title = photoDetails["title"] as? String
                photo.url = photoDetails["url_m"] as? String
                photo.pin = self
            }
        }
    }
}

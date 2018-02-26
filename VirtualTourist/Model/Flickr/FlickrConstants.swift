//
//  FlickrConstants.swift
//  VirtualTourist
//
//  Created by Kelly Egan on 2/25/18.
//  Copyright © 2018 Kelly Egan. All rights reserved.
//

import Foundation

extension FlickrClient {
    // MARK: Flickr
    struct Flickr {
        static let scheme = "https"
        static let host = "api.flickr.com"
        static let basePath = "/services/rest"
    }
    
    // MARK: Flickr Parameter Keys
    struct ParameterKeys {
        static let Method = "method"
        static let APIKey = "api_key"
        static let Extras = "extras"
        static let ResponseFormat = "format"
        static let NoJSONCallback = "nojsoncallback"
        static let Longitude = "lon"
        static let Latitude = "lat"
        static let SearchRadius = "radius"
        static let IsCommons = "is_commons"
        static let MinimumDateTaken = "min_taken_date"
    }
    
    // MARK: Flickr Parameter Values
    struct ParameterValues {
        static let ResponseFormat = "json"
        static let DisableJSONCallback = "1" /* 1 means "yes" */
        static let SearchPhotosMethod = "flickr.photos.search"
        static let MediumURL = "url_m"
    }
    
    // MARK: Flickr Response Keys
    struct ResponseKeys {
        static let Status = "stat"
        static let Photos = "photos"
        static let Photo = "photo"
        static let Title = "title"
        static let MediumURL = "url_m"
    }
    
    // MARK: Flickr Response Values
    struct ResponseValues {
        static let OKStatus = "ok"
    }
}

//
//  FlickrClient.swift
//  VirtualTourist
//
//  Created by Kelly Egan on 2/25/18.
//  Copyright © 2018 Kelly Egan. All rights reserved.
//

import Foundation

class FlickrClient: NSObject {
    
    /**
     Create a request for an image search at a specific coordinate and given radius. Searches only photos in the last year.
     
     - parameter latitude: Latitude of coordinate in degrees
     - parameter longitude: Longitude of coordinate in degrees
     - parameter radius: Radius around coordinate to search in kilometers
     
     */
    func searchPhotosByLocation( latitude: Double, longitude: Double, radius: Double ) {
        let yearInSeconds:Double = 60 * 60 * 24 * 365
        let aYearAgo = Date() - yearInSeconds
        
        let methodParameters = [
            ParameterKeys.Method: ParameterValues.SearchPhotosMethod,
            ParameterKeys.Latitude: latitude,
            ParameterKeys.Longitude: longitude,
            ParameterKeys.SearchRadius: radius,
            ParameterKeys.MinimumDateTaken: aYearAgo.timeIntervalSince1970
            ] as [String : Any]
        
        if let url = constructURL(parameters: methodParameters) {
            print(url)
        } else {
            print("Something's borked.")
        }
    }
    
    private func constructURL(parameters: [String:Any]) -> URL? {
        var components = URLComponents()
        components.scheme = Flickr.scheme
        components.host =  Flickr.host
        components.path = Flickr.basePath
        
        var queryItems = [URLQueryItem]()
        
        //Standard parameters for every request: API Key, Response Format, Disable JSON callback
        queryItems.append(URLQueryItem(name: ParameterKeys.APIKey, value: API.Key))
        queryItems.append(URLQueryItem(name: ParameterKeys.ResponseFormat, value: ParameterValues.ResponseFormat))
        queryItems.append(URLQueryItem(name: ParameterKeys.NoJSONCallback , value: ParameterValues.DisableJSONCallback))
            
        for (key, value) in parameters {
            queryItems.append(URLQueryItem(name: key, value: "\(value)"))
        }
        components.queryItems = queryItems
        
        return components.url
    }
}

//
//  FlickrClient.swift
//  VirtualTourist
//
//  Created by Kelly Egan on 2/25/18.
//  Copyright © 2018 Kelly Egan. All rights reserved.
//

import Foundation

class FlickrClient: NSObject {
    
    enum RequestError: Error, LocalizedError {
        case noStatusCode(url: String)
        case statusCodeNotOK(status: String)
        case noData(url: String)
        case couldNotParseJSON(data: String)
        case general(status: String)
        
        var errorDescription: String? {
            switch self {
            case .noStatusCode(let url): return "No status code returned for '\(url)'"
            case .statusCodeNotOK(let status): return status
            case .noData(let url): return "No data was returned for '\(url)'"
            case .couldNotParseJSON(let data): return "Could not parse the to JSON: \(data)"
            case .general(let status): return status
            }
        }
    }
    
    /**
     Create a request for an image search at a specific coordinate and given radius. Searches only photos in the last year.
     
     - parameter latitude: Latitude of coordinate in degrees
     - parameter longitude: Longitude of coordinate in degrees
     - parameter radius: Radius around coordinate to search in kilometers
     
     */
    func findPhotosForLocation( latitude: Double, longitude: Double, radius: Double, numberOfPhotos: Int, completionHandler: @escaping (_ results: [[String:AnyObject]]?, _ error: Error?) -> Void ) {
        let yearInSeconds:Double = 60 * 60 * 24 * 365
        let minimumDate = Date() - yearInSeconds * 2
        
        let methodParameters = [
            ParameterKeys.Method: ParameterValues.SearchPhotosMethod,
            ParameterKeys.Latitude: latitude,
            ParameterKeys.Longitude: longitude,
            ParameterKeys.SearchRadius: radius,
            ParameterKeys.MinimumDateTaken: minimumDate.timeIntervalSince1970,
            ParameterKeys.Extras: ParameterValues.MediumURL
            ] as [String : Any]
        
        guard let url = constructURL(parameters: methodParameters) else {
            completionHandler(nil, RequestError.general(status: "Could not construct URL"))
            return
        }
        
        let task = taskWithURL(url: url) {(data, error) -> Void in
            guard error == nil, let data = data else {
                completionHandler(nil, error!)
                return
            }
            
            guard let photosDictionary = data[ResponseKeys.Photos] as? [String:AnyObject], let photoArray = photosDictionary[ResponseKeys.Photo] as? [[String:AnyObject]] else {
                completionHandler(nil, RequestError.general(status: "Cannot find keys '\(ResponseKeys.Photos)' and '\(ResponseKeys.Photo)' in \(data)"))
                return
            }
            
            //Shuffle all photos
            let shuffledPhotos = photoArray.shuffle()
            let total = min(shuffledPhotos.count, numberOfPhotos)
            var current = 0
            var index = 0
            
            var selectedPhotos: [[String:AnyObject]] = Array()
            
            // Iterate through shuffled photos until find
            // total needed with url strings or we run out of choices
            while( current < total && index < shuffledPhotos.count ) {
                let photoDetails = shuffledPhotos[index]
                if (photoDetails[ResponseKeys.MediumURL] as? String) != nil {
                    current = current + 1
                    selectedPhotos.append(photoDetails)
                }
                
                index = index + 1
            }
            completionHandler(selectedPhotos, nil)
        }
        
        task.resume()
    }
    
    private func taskWithURL( url: URL, completionHandler: @escaping (_ results: [String:AnyObject]?, _ error: Error?) -> Void ) -> URLSessionTask {
        
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            //Flickr returned an error
            guard (error == nil) else {
                completionHandler(nil, error)
                return
            }
            //There wasn't a status code
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                completionHandler(nil, RequestError.noStatusCode(url: url.absoluteString))
                return
            }
            //Status code returned no 'OK'
            guard statusCode >= 200 && statusCode <= 299 else {
                completionHandler(nil, RequestError.statusCodeNotOK(status: "\(statusCode): \(HTTPURLResponse.localizedString(forStatusCode: statusCode))"))
                return
            }
            //No data!
            guard let data = data else {
                completionHandler(nil, RequestError.noData(url: url.absoluteString))
                return
            }
            
            //Attempt to parse results
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
            } catch {
                completionHandler(nil, RequestError.couldNotParseJSON(data: "\(data)"))
                return
            }
            
            //Finally check if JSON contains OKStatus from Flickr
            guard let stat = parsedResult[ResponseKeys.Status] as? String, stat == ResponseValues.OKStatus else {
                completionHandler(nil, RequestError.statusCodeNotOK(status: "Flickr API returned an error. See error code and message in \(parsedResult)"))
                return
            }
            
            //All good
            completionHandler(parsedResult, nil)
        }
        return task
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

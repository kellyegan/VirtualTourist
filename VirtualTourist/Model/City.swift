//
//  Cities.swift
//  VirtualTourist
//
//  Created by Kelly Egan on 3/9/18.
//  Copyright © 2018 Kelly Egan. All rights reserved.
//

import Foundation

struct City: Codable {
    let city: String
    let latitude: Double
    let longitude: Double
    let population: Double
    let province: String
    let country: String
}

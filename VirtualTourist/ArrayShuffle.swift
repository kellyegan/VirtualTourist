//
//  ArrayShuffle.swift
//  VirtualTourist
//
//  Created by Kelly Egan on 3/1/18.
//  Copyright © 2018 Kelly Egan. All rights reserved.
//

import Foundation

extension Array {
    /**
     *  Partial Fisher-Yates shuffle of an array, returns new array
     */
    func shuffle(numberOfPicks: Int) -> [Element] {
        let total = Swift.min(numberOfPicks, self.count)
        var workingCopy = self
        var m = self.count
        var results: [Element] = []
        var count = 0
        
        while( m > 0 && count < total ) {
            let index = Int(arc4random_uniform(UInt32(m)))
            m = m - 1
            let temporary = workingCopy[m]
            results.append(workingCopy[index])
            workingCopy[m] = workingCopy[index]
            workingCopy[index] = temporary
            count = count + 1
        }
        return results
    }

    /**
     *  Fisher-Yates shuffle of an array. Returns new array
     */
    func shuffle() -> [Element] {
        var results = self
        var m = self.count
        var count = 0
        
        while( m > 0 ) {
            let index = Int(arc4random_uniform(UInt32(m)))
            m = m - 1
            let temporary = results[m]
            results[m] = results[index]
            results[index] = temporary
            count = count + 1
        }
        
        return results
    }
    
    /**
     *  Fisher-Yates shuffle of an array
     */
    mutating func shuffleInPlace() {
        var m = self.count
        var count = 0
        
        while( m > 0 ) {
            let index = Int(arc4random_uniform(UInt32(m)))
            m = m - 1
            let temporary = self[m]
            self[m] = self[index]
            self[index] = temporary
            count = count + 1
        }
    }
}

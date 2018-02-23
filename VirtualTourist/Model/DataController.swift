//
//  DataController.swift
//  VirtualTourist
//
//  Created by Kelly Egan on 2/16/18.
//  Copyright © 2018 Kelly Egan. All rights reserved.
//

import Foundation
import CoreData

class DataController {
    let persistentContainer:NSPersistentContainer
    
    init(modelName:String) {
        persistentContainer = NSPersistentContainer(name: modelName)
    }
    
    // MARK: - Helper functions
    var viewContext:NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func load(completion: (()-> Void)? = nil) {
        persistentContainer.loadPersistentStores { storeDescription, error in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            completion?()
        }
    }
    
}

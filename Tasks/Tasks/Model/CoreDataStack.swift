//
//  CoreDataStack.swift
//  Tasks
//
//  Created by Cora Jacobson on 8/4/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    
    static let shared = CoreDataStack()
    
    lazy var container: NSPersistentContainer = {
       
        let container = NSPersistentContainer(name: "Tasks")
        container.loadPersistentStores { (_, error) in
            if let error = error {
                fatalError("Failed to load persistent stores: \(error)")
            }
        }
        return container
        
    }()
    
    var mainContext: NSManagedObjectContext {
        return container.viewContext
    }
    
}

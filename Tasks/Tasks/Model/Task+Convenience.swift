//
//  Task+Convenience.swift
//  Tasks
//
//  Created by Cora Jacobson on 8/4/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import CoreData

enum TaskPriority: String, CaseIterable {
    case low
    case normal
    case high
    case critical
}

extension Task {
    
    @discardableResult convenience init(identifier: UUID = UUID(),
                                        name: String,
                                        priority: TaskPriority = .normal,
                                        notes: String? = nil,
                                        complete: Bool = false,
                                        context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.identifier = identifier
        self.name = name
        self.priority = priority.rawValue
        self.notes = notes
        self.complete = complete
    }
}

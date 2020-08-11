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
    
    var taskRepresentation: TaskRepresentation? {
        guard let name = name,
            let priority = priority else { return nil }
        
        return TaskRepresentation(identifier: identifier?.uuidString ?? "", name: name, notes: notes, priority: priority, complete: complete)
    }
    
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
    
    @discardableResult convenience init?(taskRepresentation: TaskRepresentation, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        guard let priority = TaskPriority(rawValue: taskRepresentation.priority),
            let identifier = UUID(uuidString: taskRepresentation.identifier) else { return nil }
        self.init(identifier: identifier,
                  name: taskRepresentation.name,
                  priority: priority,
                  notes: taskRepresentation.notes,
                  complete: taskRepresentation.complete,
                  context: context)
    }
    
}

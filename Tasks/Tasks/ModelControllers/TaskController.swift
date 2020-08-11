//
//  TaskController.swift
//  Tasks
//
//  Created by Cora Jacobson on 8/10/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import CoreData

enum NetworkError: Error {
    case noIdentifier
    case otherError
    case noData
    case noDecode
    case noEncode
    case noRep
}

let baseURL = URL(string: "https://tasks-3f211.firebaseio.com/")!

class TaskController {
    
    init() {
        fetchTasksFromServer()
    }
    
    typealias CompletionHandler = (Result<Bool, NetworkError>) -> Void
    
    func fetchTasksFromServer(completion: @escaping CompletionHandler = { _ in }) {
        let requestURL = baseURL.appendingPathExtension("json")
        let task = URLSession.shared.dataTask(with: requestURL) { (data, _, error) in
            if let error = error {
                print("Error fetching tasks: \(error)")
                completion(.failure(.otherError))
                return
            }
            guard let data = data else {
                print("No data returned by data task.")
                completion(.failure(.noData))
                return
            }
            do {
                let taskRepresentations = Array(try JSONDecoder().decode([String: TaskRepresentation].self, from: data).values)
                try self.updateTasks(with: taskRepresentations)
                completion(.success(true))
            } catch {
                print("Error decoding task representations: \(error)")
                completion(.failure(.noDecode))
                return
            }
        }
        task.resume()
    }
    
    func deleteTaskFromServer(_ task: Task, completion: @escaping CompletionHandler = { _ in }) {
        guard let uuid = task.identifier else {
            completion(.failure(.noIdentifier))
            return
        }
        let requestURL = baseURL.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "DELETE"
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            print(response!)
            completion(.success(true))
        }
        task.resume()
    }
    
    private func updateTasks(with representations: [TaskRepresentation]) throws {
        let identifiersToFetch = representations.compactMap({UUID(uuidString: $0.identifier)})
        let representationsByID = Dictionary(uniqueKeysWithValues: zip(identifiersToFetch, representations))
        var tasksToCreate = representationsByID
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier IN %@", identifiersToFetch)
        let context = CoreDataStack.shared.mainContext
        do {
            let existingTasks = try context.fetch(fetchRequest)
            for task in existingTasks {
                guard let id = task.identifier,
                    let representation = representationsByID[id] else {
                        continue }
                task.name = representation.name
                task.notes = representation.notes
                task.priority = representation.priority
                task.complete = representation.complete
                
                tasksToCreate.removeValue(forKey: id)
            }
            for representation in tasksToCreate.values {
                Task(taskRepresentation: representation, context: context)
            }
        } catch {
            print("Error fetching tasks for UUIDs: \(error)")
        }
        try CoreDataStack.shared.mainContext.save()
    }
    
    func sendTaskToServer(task: Task, completion: @escaping CompletionHandler = { _ in }) {
        guard let uuid = task.identifier else {
            completion(.failure(.noIdentifier))
            return
        }
        let requestURL = baseURL.appendingPathComponent(uuid.uuidString).appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "PUT"
        
        do {
            guard let representation = task.taskRepresentation else {
                completion(.failure(.noRep))
                return
            }
            request.httpBody = try JSONEncoder().encode(representation)
        } catch {
            print("Error encoding task: \(error)")
            completion(.failure(.noEncode))
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { (_, _,  error) in
            if let error = error {
                print ("Error PUTting task to server: \(error)")
                completion(.failure(.otherError))
                return
            }
            completion(.success(true))
        }
        task.resume()
    }
    
}

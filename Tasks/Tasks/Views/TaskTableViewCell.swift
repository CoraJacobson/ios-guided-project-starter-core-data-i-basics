//
//  TaskTableViewCell.swift
//  Tasks
//
//  Created by Ben Gohlke on 4/20/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import UIKit
import CoreData

class TaskTableViewCell: UITableViewCell {

    // MARK: - Properties
    
    static let reuseIdentifier = "TaskCell"
    
    var task: Task? {
        didSet {
            updateViews()
        }
    }
    
    // MARK: - IBOutlets
    @IBOutlet weak var taskNameLabel: UILabel!
    @IBOutlet weak var completedButton: UIButton!
    
    // MARK: - Actions
    @IBAction func toggleComplete(_ sender: UIButton) {
        guard let task = task else { return }
        task.complete.toggle()
        completedButton.setImage((task.complete) ? UIImage(systemName: "checkmark.square.fill") : UIImage(systemName: "square"), for: .normal)
        
        do {
            try CoreDataStack.shared.mainContext.save()
        } catch {
            NSLog("Error saving managed object context: \(error)")
        }
    }
    
    private func updateViews() {
        guard let task = task else { return }
        taskNameLabel.text = task.name
        completedButton.setImage((task.complete) ? UIImage(systemName: "checkmark.square.fill") : UIImage(systemName: "square"), for: .normal)
    }
}

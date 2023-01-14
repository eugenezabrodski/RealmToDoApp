//
//  TasksTVCFlow.swift
//  RealmToDoApp
//
//  Created by Евгений Забродский on 14.01.23.
//

import UIKit

enum TasksTVCFlow {
    case addingNewTask
    case editingTask(task: Task)
}

struct TxtAlertData {
    
    let title = "Task value"
    var message: String
    var doneButton: String
    
    let titleTextField = "New task"
    let noteTextField = "Note"
    
    var taskName: String?
    var taskNote: String?
    
    init(tasksTVCFlow: TasksTVCFlow) {
        switch tasksTVCFlow {
        case .addingNewTask:
            message = "Please insert new task"
            doneButton = "Save"
        case .editingTask(let task):
            message = "Please edit your task"
            doneButton = "Update"
            taskName = task.name
            taskNote = task.note
        }
    }
}

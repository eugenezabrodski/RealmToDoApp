//
//  StorageManager.swift
//  RealmToDoApp
//
//  Created by Евгений Забродский on 11.01.23.
//

import Foundation
import RealmSwift

let realm = try! Realm()

class StorageManager {
    
    static func deleteAll() {
        do {
            try realm.write {
                realm.deleteAll()
            }
        } catch {
            print("Delete error: \(error)")
        }
    }
    
    static func getAllTasksLists() -> Results<TasksList> {
        realm.objects(TasksList.self)
    }
    
    static func saveTasksList(tasksList: TasksList) {
        do {
            try realm.write {
                realm.add(tasksList)
            }
            } catch {
                print("Error save")
            }
    }
    
    static func editList(_ tasksList: TasksList, newListName: String) {
        do {
            try realm.write {
                tasksList.name = newListName
                }
            } catch {
                print("Error edit")
            }
    }
    
    static func deleteList(_ tasksList: TasksList) {
        do {
            try realm.write {
                let tasks = tasksList.tasks
                realm.delete(tasks)
                realm.delete(tasksList) }
        } catch {
            print("Error delete")
        }
}
    
    static func makeAllDone(_ tasksList: TasksList) {
        do {
            try realm.write {
                tasksList.tasks.setValue(true, forKey: "isComplited")
            }
        } catch {
            print("Error makeAllDone")
        }
    }

    //MARK: - Tasks
    
    static func saveTask(_ tasksList: TasksList, task: Task) {
        try! realm.write {
            tasksList.tasks.append(task)
        }
    }
    
    static func editTask(_ task: Task, newNameTask: String, newNote: String) {
        try! realm.write {
            task.name = newNameTask
            task.note = newNote
        }
    }
    
    static func deleteTask(_ task: Task) {
        try! realm.write {
            realm.delete(task)
        }
    }
    
    static func makeDone(_ task: Task) {
        try! realm.write {
            task.isComplited.toggle()
        }
    }
    
    static func saveWhenMove(_ task: Task) {
        try! realm.write {
            task.isComplited.toggle()
        }
    }
    
}

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
    
    static func editList(_ tasksList: TasksList, newListName: String, complition: @escaping () -> Void) {
        do {
            try realm.write {
                tasksList.name = newListName
                complition() }
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
    
    
    
}

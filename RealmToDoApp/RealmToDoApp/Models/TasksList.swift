//
//  TasksList.swift
//  RealmToDoApp
//
//  Created by Евгений Забродский on 11.01.23.
//

import Foundation
import RealmSwift

class TasksList: Object {
    @Persisted var name = ""
    @Persisted var date = Date()
    @Persisted var tasks = List<Task>()
}

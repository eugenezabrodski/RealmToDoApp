//
//  ListModel.swift
//  RealmToDoApp
//
//  Created by Евгений Забродский on 11.01.23.
//

import Foundation
import RealmSwift

class Task: Object {
    @Persisted var name = ""
    @Persisted var note = ""
    @Persisted var date = Date()
    @Persisted var isComplited = false
}

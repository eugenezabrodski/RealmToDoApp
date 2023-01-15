//
//  TasksListsTVC.swift
//  RealmToDoApp
//
//  Created by Евгений Забродский on 11.01.23.
//

import UIKit
import RealmSwift

class TasksListsTVC: UITableViewController {

    var notificationToken: NotificationToken?
    var tasksLists: Results<TasksList>!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tasksLists = StorageManager.getAllTasksLists().sorted(byKeyPath: "name")
        addTasksListsObserver()
        let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addBarButton))
        self.navigationItem.setRightBarButtonItems([add, editButtonItem], animated: true)
    }
    
    @IBAction func segmentedControlChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            tasksLists = tasksLists.sorted(byKeyPath: "name")
        } else {
            tasksLists = tasksLists.sorted(byKeyPath: "date")
        }
    }
    

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasksLists.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let taskList = tasksLists[indexPath.row]
        cell.configure(with: taskList)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let currentList = tasksLists[indexPath.row]
        
        let deleteContextItem = UIContextualAction(style: .destructive, title: "Delete") { _, _, _ in
            StorageManager.deleteList(currentList)
        }
        
        let editeContextItem = UIContextualAction(style: .destructive, title: "Edit") { _, _, _ in
            self.alertForAddAndUpdatesListTasks(currentList)
        }
        
        let doneContextItem = UIContextualAction(style: .destructive, title: "Done") { _, _, _ in
            StorageManager.makeAllDone(currentList)
        }
        
        editeContextItem.backgroundColor = .orange
        doneContextItem.backgroundColor = .systemIndigo
        
        let swipeActions = UISwipeActionsConfiguration(actions: [deleteContextItem, editeContextItem, doneContextItem])
        return swipeActions
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? TasksTVC,
           let index = tableView.indexPathForSelectedRow {
            let tasksList = tasksLists[index.row]
            destinationVC.currentTasksList = tasksList
        }
    }

    
    @objc func addBarButton() {
        alertForAddAndUpdatesListTasks()
    }
    
    private func alertForAddAndUpdatesListTasks(_ tasksList: TasksList? = nil) {
        let title = tasksList == nil ? "New List" : "Edit List"
        let message = "Please insert list name"
        let doneButton = tasksList == nil ? "Save" : "Update"
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        var alertTextField: UITextField!
        
        let saveAction = UIAlertAction(title: doneButton, style: .default) { _ in
            guard let newListName = alertTextField.text, !newListName.isEmpty else { return }
            
            if let tasksList = tasksList {
                StorageManager.editList(tasksList, newListName: newListName)
            } else {
                let tasksList = TasksList()
                tasksList.name = newListName
                StorageManager.saveTasksList(tasksList: tasksList)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        alert.addTextField { textField in
            alertTextField = textField
            if let listName = tasksList {
                alertTextField.text = listName.name
            }
            alertTextField.placeholder = "List Name"
        }
        present(alert, animated: true)
    }

    private func addTasksListsObserver() {
        notificationToken = tasksLists.observe { [weak self] change in
            guard let self = self else { return }
            switch change {
            case .initial:
                print("initial element")
            case .update(_, let deletions, let insertions, let modifications):
                print("deletions: \(deletions)")
                print("insertions: \(insertions)")
                print("modifications: \(modifications)")
                if !modifications.isEmpty {
                    let indexPathArray = self.createIndexPathArray(intArr: modifications)
                    self.tableView.reloadRows(at: indexPathArray, with: .automatic)
                }
                if !deletions.isEmpty {
                    let indexPathArray = self.createIndexPathArray(intArr: deletions)
                    self.tableView.deleteRows(at: indexPathArray, with: .automatic)
                }
                if !insertions.isEmpty {
                    let indexPathArray = self.createIndexPathArray(intArr: insertions)
                    self.tableView.insertRows(at: indexPathArray, with: .automatic)
                }
            case .error(let error):
                print("error: \(error)")
            }
        }
    }
    
    private func createIndexPathArray(intArr: [Int]) -> [IndexPath] {
        var indexPathArray = [IndexPath]()
        for row in intArr {
            indexPathArray.append(IndexPath(row: row, section: 0))
        }
        return indexPathArray
    }
}

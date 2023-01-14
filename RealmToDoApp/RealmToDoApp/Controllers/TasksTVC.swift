//
//  TasksTVC.swift
//  RealmToDoApp
//
//  Created by Евгений Забродский on 14.01.23.
//

import UIKit
import RealmSwift

class TasksTVC: UITableViewController {
    
    var currentTasksList: TasksList?
    
    private var notCompletedTasks: Results<Task>!
    private var completedTasks: Results<Task>!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = currentTasksList?.name
        filteringTasks()
        let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addBarButtonSystemItemSelector))
        self.navigationItem.setRightBarButtonItems([add, editButtonItem], animated: true)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? notCompletedTasks.count : completedTasks.count
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Not completed tasks" : "Completed tasks"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let task = indexPath.section == 0 ? notCompletedTasks[indexPath.row] : completedTasks[indexPath.row]
        cell.textLabel?.text = task.name
        cell.detailTextLabel?.text = task.note
        return cell
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let task = indexPath.section == 0 ? notCompletedTasks[indexPath.row] : completedTasks[indexPath.row]
        
        let deleteContextItem = UIContextualAction(style: .destructive, title: "Delete") { _, _, _ in
            StorageManager.deleteTask(task)
        }
        let editContextItem = UIContextualAction(style: .destructive, title: "Edit") { _, _, _ in
            self.alertForAddAndUpdatesList(tasksTVCFlow: .editingTask(task: task))
        }
        let doneText = task.isComplited ? "Not done" : "Done"
        let doneContextItem = UIContextualAction(style: .destructive, title: doneText) { _, _, _ in
            StorageManager.makeDone(task)
            self.filteringTasks()
        }
        
        editContextItem.backgroundColor = .orange
        doneContextItem.backgroundColor = .systemIndigo
        
        let swipeActions = UISwipeActionsConfiguration(actions: [deleteContextItem, editContextItem, doneContextItem])
        return swipeActions
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */


    
    private func filteringTasks() {
        notCompletedTasks = currentTasksList?.tasks.filter("isComplited = false")
        completedTasks = currentTasksList?.tasks.filter("isComplited = true")
        tableView.reloadData()
    }
}

//MARK: - Adding and Updating List

extension TasksTVC {
    @objc private func addBarButtonSystemItemSelector() {
        alertForAddAndUpdatesList(tasksTVCFlow: .addingNewTask)
    }
    
    private func alertForAddAndUpdatesList(tasksTVCFlow: TasksTVCFlow) {
        
        let txtAlertData = TxtAlertData(tasksTVCFlow: tasksTVCFlow)

        let alert = UIAlertController(title: txtAlertData.title, message: txtAlertData.message, preferredStyle: .alert)
        
        var taskTextField: UITextField!
        var noteTextField: UITextField!
        
        alert.addTextField { textField in
            taskTextField = textField
            taskTextField.placeholder = txtAlertData.titleTextField
            taskTextField.text = txtAlertData.taskName
        }
        
        alert.addTextField { textField in
            noteTextField = textField
            noteTextField.placeholder = txtAlertData.noteTextField
            noteTextField.text = txtAlertData.taskNote
        }
        
        let saveAction = UIAlertAction(title: txtAlertData.doneButton, style: .default) { [weak self] _ in
            guard let newNameTask = taskTextField.text, !newNameTask.isEmpty, let newNote = noteTextField.text, !newNote.isEmpty, let self = self else { return }
            
            switch tasksTVCFlow {
            case .addingNewTask:
                let task = Task()
                task.name = newNameTask
                task.note = newNote
                guard let currentTasksList = self.currentTasksList else { return }
                StorageManager.saveTask(currentTasksList, task: task)
                
            case .editingTask(let task):
                StorageManager.editTask(task, newNameTask: newNameTask, newNote: newNote)
            }
            self.filteringTasks()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
}

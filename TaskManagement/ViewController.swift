//
//  ViewController.swift
//  TaskManagement
//
//  Created by Everett Brothers on 10/8/23.
//

import UIKit
import CoreData

class ViewController: UITableViewController {

    var tasks: [Task] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Tasks"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTask))
        getTasks()
    }
    
    func getTasks() {
        let taskFetch: NSFetchRequest<Task> = Task.fetchRequest()
        let sortByName = NSSortDescriptor(key: #keyPath(Task.name), ascending: false)
        taskFetch.sortDescriptors = [sortByName]
        do {
            let managedContext = AppDelegate.sharedAppDelegate.coreDataStack.managedContext
            let results = try managedContext.fetch(taskFetch)
            tasks = results
        } catch let error as NSError {
            print("Fetch error: \(error) description: \(error.userInfo)")
        }
    }
    
    @objc func addTask() {
        let ac = UIAlertController(title: "Add Task", message: nil, preferredStyle: .alert)
        
        ac.addTextField { text in
            text.placeholder = "Name"
            text.keyboardType = .default
        }
        ac.addTextField { text in
            text.placeholder = "Priority (1 - 10)"
            text.keyboardType = .decimalPad
        }
        ac.addTextField { text in
            text.placeholder = "Description"
            text.keyboardType = .default
        }
        
        ac.addAction(UIAlertAction(title: "Submit", style: .default) { [weak self, weak ac] _ in
            guard let self = self else { return }
            guard let ac = ac else { return }
            let nameText = ac.textFields?[0].text
            guard let priorityText = ac.textFields?[1].text else { return }
            let bodyText = ac.textFields?[2].text
            
            let managedContext = AppDelegate.sharedAppDelegate.coreDataStack.managedContext
            let newTask = Task(context: managedContext)
            newTask.setValue(nameText, forKey: #keyPath(Task.name))
            newTask.setValue(Double(priorityText)! / 10, forKey: #keyPath(Task.priority))
            newTask.setValue(bodyText, forKey: #keyPath(Task.body))
            self.tasks.insert(newTask, at: 0)
            AppDelegate.sharedAppDelegate.coreDataStack.saveContext()
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(ac, animated: true)
    }

    @objc func editOptions(sender: UIButton) {
        var currentTask: Task!
        for task in tasks {
            if task.name == sender.titleLabel?.text {
                currentTask = task
                continue
            }
        }
        guard currentTask != nil else { return }
        guard let i = tasks.firstIndex(of: currentTask) else { return }
        let ac = UIAlertController(title: "Edit Task", message: nil, preferredStyle: .alert)
        ac.addTextField { text in
            text.placeholder = "\(currentTask.name ?? "Name")"
            text.keyboardType = .default
        }
        ac.addTextField { text in
            text.placeholder = "\(currentTask.priority * 10)"
            text.keyboardType = .decimalPad
        }
        ac.addTextField { text in
            if currentTask.body == "" {
                text.placeholder = "Description"
            } else {
                text.placeholder = "\(currentTask.body ?? "Description")"
            }
            text.keyboardType = .default
        }
        
        ac.addAction(UIAlertAction(title: "Submit", style: .default) { [weak self, weak ac] _ in
            guard let self = self else { return }
            guard let ac = ac else { return }
            var nameText = ac.textFields?[0].text
            guard var priorityText = ac.textFields?[1].text else { return }
            var bodyText = ac.textFields?[2].text
            
            if nameText == "" {
                nameText = currentTask.name
            }
            if priorityText == "" {
                priorityText = "\(currentTask.priority * 10)"
            }
            if bodyText == "" || bodyText != nil {
                bodyText = currentTask.body
            }
            
            guard Double(priorityText)! <= 1 else { return }
            
            let managedContext = AppDelegate.sharedAppDelegate.coreDataStack.managedContext
            let newTask = Task(context: managedContext)
            newTask.setValue(nameText, forKey: #keyPath(Task.name))
            newTask.setValue(Double(priorityText)! / 10, forKey: #keyPath(Task.priority))
            newTask.setValue(bodyText, forKey: #keyPath(Task.body))
            self.tasks.remove(at: i)
            self.tasks.insert(newTask, at: 0)
            AppDelegate.sharedAppDelegate.coreDataStack.saveContext()
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })
        
        ac.addAction(UIAlertAction(title: "Delete", style: .cancel) { [weak self] _ in
            guard let self = self else { return }
            // Remove the note from the CoreData
            AppDelegate.sharedAppDelegate.coreDataStack.managedContext.delete(self.tasks[i])
            self.tasks.remove(at: i)
            // Save Changes
            AppDelegate.sharedAppDelegate.coreDataStack.saveContext()
            // Remove row from TableView
            self.tableView.deleteRows(at: [IndexPath(row: i, section: 0)], with: .left)
        })
        
        present(ac, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let currentTask = tasks[indexPath.row]
        let cellView = cell.viewWithTag(5) as? UIButton
        
        cellView?.setTitle(currentTask.name, for: .normal)
        cellView?.setTitleColor(.black, for: .normal)
        cellView?.addTarget(self, action: #selector(editOptions), for: .touchUpInside)
        cellView?.layer.cornerRadius = 10
        
        switch currentTask.priority {
        case 0...0.25:
            cellView!.backgroundColor = .lightGray
        case 0.25...0.75:
            cellView!.backgroundColor = .orange
        case 0.75...1:
            cellView!.backgroundColor = .red
        default:
            break
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
}


//
//  TasksTableViewController.swift
//  CoreData Migration
//
//  Created by Omar Allaham on 11/19/21.
//

import UIKit
import CoreData

class TasksTableViewController: UITableViewController {
    
    lazy var context: NSManagedObjectContext! = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    lazy var resultsController: NSFetchedResultsController<Task> = createResultsController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Tasks"
        
        clearsSelectionOnViewWillAppear = true
        
        do {
            try resultsController.performFetch()
            tableView.reloadData()
        } catch(let error) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.displayAlert(for: error)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        tableView.indexPathsForSelectedRows?.forEach({
            tableView.deselectRow(at: $0, animated: true)
        })
    }
    
    func createResultsController() -> NSFetchedResultsController<Task> {
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: #keyPath(Task.creationDate), ascending: true)
        ]
        
        let controller = NSFetchedResultsController<Task>(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        controller.delegate = self
        
        return controller
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultsController.fetchedObjects?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let task = resultsController.fetchedObjects?[indexPath.row]
        
        let cell: UITableViewCell = {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell") else {
                    // Never fails:
                return UITableViewCell(style: .subtitle, reuseIdentifier: "UITableViewCell")
            }
            return cell
        }()
        
        cell.textLabel?.text = task?.title
        cell.detailTextLabel?.text = task?.detail
         
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let task = resultsController.fetchedObjects?[indexPath.row]
        
        presentTaskViewController(for: task)
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let delete = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion in
            guard let self = self else { completion(false); return }
            
            self.deleteTask(at: indexPath, completion: completion)
        }
        
        return UISwipeActionsConfiguration(actions: [delete])
    }
}

extension TasksTableViewController: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.performSelector(onMainThread: #selector(UITableView.reloadData), with: nil, waitUntilDone: false)
    }
}

extension TasksTableViewController {
    
    func deleteTask(at indexPath: IndexPath, completion: ((Bool) -> Void)) {
        
        let tasks = resultsController.fetchedObjects ?? []
        let task = tasks[indexPath.row]
        
        let context = task.managedObjectContext
        context?.performAndWait {
            context?.delete(task)
            try! context?.save()
        }
        
        completion(true)
    }
}

extension UIViewController {
    
    @IBAction
    func newTask(_ sender: Any?) {
        
        presentTaskViewController(for: nil)
    }
    
    func presentTaskViewController(for task: Task?) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let vc = storyboard.instantiateViewController(withIdentifier: "TaskViewController") as! TaskViewController
        
        vc.task = task
        
        show(vc, sender: nil)
    }
    
    func displayAlert(for error: Error) {
        
        let alert = UIAlertController.init(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        
        present(alert, animated: true)
    }
}

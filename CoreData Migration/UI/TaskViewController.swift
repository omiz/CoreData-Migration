//
//  TaskViewController.swift
//  CoreData Migration
//
//  Created by Omar Allaham on 11/19/21.
//

import UIKit
import CoreData

class TaskViewController: UIViewController {
    
    var task: Task?
    lazy var context: NSManagedObjectContext! = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var detailTextField: UITextField!
    
    lazy var saveItemButton: UIBarButtonItem = .init(
        systemItem: .save,
        primaryAction: UIAction(handler: self.save),
        menu: nil
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = saveItemButton
        navigationItem.title = task == nil ? "New Task" : "Edit Task"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateView()
    }
    
    func updateView() {
        
        titleTextField.text = task?.title
        detailTextField.text = task?.detail
    }

    @IBAction
    func reportSettings(_ sender: Any?) {
        
        guard let task = task else {
            alertMissingTask()
            return
        }
        
        showReportSettings(for: task)
    }
    
    func alertMissingTask() {
        
        let alert = UIAlertController(title: "Error", message: "Please save the task first!", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
                        
        present(alert, animated: true)
    }
    
    func save(_ sender: Any?) {
        
        let title = titleTextField.text ?? ""
        let detail = detailTextField.text ?? ""
        
        updateOrCreateTask(title: title, detail: detail)
        
        navigationController?.popViewController(animated: true)
    }
    
    func updateOrCreateTask(title: String, detail: String) {
        
        let context = task?.managedObjectContext ?? self.context
        
        context?.performAndWait {
            let task = self.task ?? Task(context: context!)
            
            task.title = title
            task.detail = detail
            
            do { try context?.save() }
            catch { displayAlert(for: error) }
        }
    }
}

extension UIViewController {
    
    func showReportSettings(for task: Task) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let vc = storyboard.instantiateViewController(withIdentifier: "ReportViewController") as! ReportViewController
        
        vc.task = task
        
        show(vc, sender: nil)
    }
}

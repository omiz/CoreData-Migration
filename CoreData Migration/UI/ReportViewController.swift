//
//  ReportViewController.swift
//  CoreData Migration
//
//  Created by Omar Allaham on 11/19/21.
//

import UIKit

class ReportViewController: UIViewController {
    
    var task: Task!
    
    @IBOutlet weak var switch1: UISwitch!
    @IBOutlet weak var switch2: UISwitch!
    @IBOutlet weak var textView: UITextView!
    
    lazy var saveItemButton: UIBarButtonItem = .init(
        systemItem: .save,
        primaryAction: UIAction(handler: self.save),
        menu: nil
    )

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = saveItemButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateView()
    }
    
    func updateView() {
        switch1.isOn = task.reportSettings1
        switch2.isOn = task.reportSettings2
        textView.text = task.reportNote
    }

    func save(_ sender: Any?) {
        
        let context = task.managedObjectContext
        let s1 = switch1.isOn
        let s2 = switch2.isOn
        let note = textView.text
        
        context?.performAndWait {
            task.reportSettings1 = s1
            task.reportSettings2 = s2
            task.reportNote = note
            
            do { try context?.save() }
            catch { displayAlert(for: error) }
        }
    }
}

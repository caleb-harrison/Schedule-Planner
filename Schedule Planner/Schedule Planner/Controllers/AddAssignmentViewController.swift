//
//  AddAssignmentViewController.swift
//  Schedule Planner
//
//  Created by Caleb Harrison on 3/23/21.
//

import UIKit
import CoreData
import Foundation

class AddAssignmentViewController: UIViewController,  UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var tableView: UITableView!
    var parentVC: AssignmentsViewController!
    var courses2: [Course] = []
    var selectedIndex: Int = -1
    var selectedCourse: Course!
    
    @IBOutlet var assignmentNameTextfield: UITextField!
    @IBOutlet var assignmentDescTextfield: UITextField!
    @IBOutlet var dueDatePicker: UIDatePicker!
    
    @IBOutlet var cancelButton: UIButton!
    @IBOutlet var saveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeButtonsPretty()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.white
        
        // set date picker color and default to 11:59pm tonight
        let tonight = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: Date())!
        dueDatePicker.setValue(UIColor.white, forKeyPath: "textColor")
        dueDatePicker.setDate(tonight, animated: false)
        
        getCourses()
        print("Current courses in array: \(courses2.count).")
    }
    
    /// save button clicked
    @IBAction func saveButtonClicked() {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
            return
        }

        let managedContext =
        appDelegate.persistentContainer.viewContext

        let entity =
        NSEntityDescription.entity(forEntityName: "Assignment",
                                  in: managedContext)!

        let assignment = NSManagedObject(entity: entity,
                                  insertInto: managedContext) as! Assignment
        
        if checkFields() {
            assignment.course = selectedCourse
            assignment.name = assignmentNameTextfield.text ?? "name"
            assignment.desc = assignmentDescTextfield.text ?? "desc"
            assignment.dueDate = dueDatePicker.date
            
            do {
                try managedContext.save()
                self.parentVC.getAssignments() // update assignment table view
                self.dismiss(animated: true, completion: {})
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
            
        } else {
            let alert = UIAlertController(title: "Missing fields. Try again.", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
            self.present(alert, animated: true)
            print("missing fields, try again!")
        }
    }
    
    @IBAction func cancelButtonClicked() {
        self.dismiss(animated: true, completion: {})
    }
    
    // check if text fields are filled in
    func checkFields() -> Bool {
        if (assignmentNameTextfield.hasText) &&
            (assignmentDescTextfield.hasText) &&
            (selectedIndex != -1) {
            return true
        } else {
            return false
        }
    }
    
    // get courses from database
    func getCourses() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
         
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest =
           NSFetchRequest<NSManagedObject>(entityName: "Course")
         
        do {
            courses2 = try managedContext.fetch(fetchRequest) as? [Course] ?? []
            self.tableView.reloadData()
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    // clicked course function
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // select course for assignment to be added to
        selectedIndex = indexPath.row
        selectedCourse = courses2[selectedIndex]
        print("Selected course: \(selectedCourse.name ?? "no course name")")
    }
    
    // return size of courses array
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return courses2.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        let cell = tableView.dequeueReusableCell(withIdentifier: "CourseCell2", for: indexPath) as! CourseCell2
        cell.courseLabel2.text = courses2[indexPath.row].name
        return cell
    }
    
    func makeButtonsPretty() {
        cancelButton.layer.cornerRadius = 8.0
        saveButton.layer.cornerRadius = 8.0
    }
    

}
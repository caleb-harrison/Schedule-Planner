//
//  CoursesViewController.swift
//  Schedule Planner
//
//  Created by Caleb Harrison on 3/23/21.
//

import UIKit
import CoreData
import Foundation

class CoursesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    /// all course's table view
    @IBOutlet var tableView: UITableView!
    
    /// courses array
    var courses: [Course] = []
    
    /// selected index
    var selectedIndex: Int = 0
    
    /// runs when view appears
    override func viewWillAppear(_ animated: Bool) {
        getCourses()
    }
    
    /// runs when view first loads
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 44
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.white
        
        getCourses()
        
        // add long press to delete
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        longPressGesture.minimumPressDuration = 0.5
        self.tableView.addGestureRecognizer(longPressGesture)
    }
    
    /// get courses from database
    func getCourses() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
         
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest =
           NSFetchRequest<NSManagedObject>(entityName: "Course")
         
        do {
            courses = try managedContext.fetch(fetchRequest) as? [Course] ?? []
            self.tableView.reloadData()
            print("Current courses in array: \(courses.count).")
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    /// add course button
    @IBAction func addCourseButtonClicked() {
        getCourseInfo()
    }
    
    /// alert to get initial course info
    func getCourseInfo() {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
            return
        }

        let managedContext =
        appDelegate.persistentContainer.viewContext
        
        let entity =
        NSEntityDescription.entity(forEntityName: "Course",
                                  in: managedContext)!
        
        let course = NSManagedObject(entity: entity,
                                  insertInto: managedContext) as! Course
        
        let alert = UIAlertController(title: "Course Information",
              message: nil,
              preferredStyle: .alert)
        
        let save = UIAlertAction(title: "Save", style: .default, handler: { (action) -> Void in
            // get textfield's text
            let nameText = alert.textFields![0]
            let instructorText = alert.textFields![1]
            
            do {
                // save changes
                course.name = nameText.text
                course.instructor = instructorText.text
                try managedContext.save()
                self.courses.append(course)
                self.tableView.reloadData()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        })
        
        // cancel button
        let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: { (action) -> Void in })
        
        // textfield (for course name)
        alert.addTextField { (textField: UITextField) in
            textField.keyboardAppearance = .dark
            textField.keyboardType = .default
            textField.autocorrectionType = .default
            textField.placeholder = "Enter your course name"
        }
        
        // textfield (for instructor)
        alert.addTextField { (textField: UITextField) in
            textField.keyboardAppearance = .dark
            textField.keyboardType = .default
            textField.autocorrectionType = .default
            textField.placeholder = "Enter your instructor's name"
        }
        
        // add action buttons and present the alert
        alert.addAction(cancel)
        alert.addAction(save)
        present(alert, animated: true, completion: nil)
        
    }
    
    /// handle long press function
    @objc func handleLongPress(longPressGesture: UILongPressGestureRecognizer) {
        // find out where the long press is
        let p = longPressGesture.location(in: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: p)
        let courseName = courses[indexPath!.row].name
        if longPressGesture.state == UIGestureRecognizer.State.began {
            let alert = UIAlertController(title: "Would you like to delete \(courseName ?? "this course")?", message: nil, preferredStyle: .alert)
            selectedIndex = indexPath!.row
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: {_ in
                alert.dismiss(animated: true, completion: {})
                self.deleteCourse(indexPath: indexPath!)
            }))
            self.present(alert, animated: true)
        }
    }
    
    /// delete course from database and array
    func deleteCourse(indexPath: IndexPath) {
        let deletedCourse = courses[selectedIndex]
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext =
        appDelegate.persistentContainer.viewContext
        
        managedContext.delete(deletedCourse)
        courses.remove(at: selectedIndex)
        tableView.deleteRows(at: [indexPath], with: .fade)
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    /// alert to edit course info
    func editCourseInfo(indexPath: IndexPath) {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
            return
        }

        let managedContext =
        appDelegate.persistentContainer.viewContext
        
        let alert = UIAlertController(title: "Edit Course Information",
              message: nil,
              preferredStyle: .alert)
        
        let saveEdit = UIAlertAction(title: "Save", style: .default, handler: { (action) -> Void in
            // get textfield's text
            let nameText = alert.textFields![0]
            let instructorText = alert.textFields![1]
            
            do {
                // save changes
                self.courses[indexPath.row].name = nameText.text
                self.courses[indexPath.row].instructor = instructorText.text
                try managedContext.save()
                self.tableView.reloadData()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        })
        
        // cancel button
        let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: { (action) -> Void in })
        
        // textfield (for course name)
        alert.addTextField { (textField: UITextField) in
            textField.keyboardAppearance = .dark
            textField.keyboardType = .default
            textField.autocorrectionType = .default
            textField.text = self.courses[indexPath.row].name
            textField.placeholder = "Enter your course name"
        }
        
        // textfield (for instructor)
        alert.addTextField { (textField: UITextField) in
            textField.keyboardAppearance = .dark
            textField.keyboardType = .default
            textField.autocorrectionType = .default
            textField.text = self.courses[indexPath.row].instructor
            textField.placeholder = "Enter your instructor's name"
        }
        
        // add action buttons and present the alert
        alert.addAction(cancel)
        alert.addAction(saveEdit)
        present(alert, animated: true, completion: nil)
        
    }
    
    /// alert to show course info
    func showCourseInfo(indexPath: IndexPath) {
        let alert = UIAlertController(title: courses[indexPath.row].name, message: "\(courses[indexPath.row].instructor ?? "instructor") // Assignments: \(courses[indexPath.row].assignments?.count ?? 0)", preferredStyle: .alert)
        selectedIndex = indexPath.row
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Edit", style: .default, handler: {_ in
            alert.dismiss(animated: true, completion: {})
            self.editCourseInfo(indexPath: indexPath)
        }))
        self.present(alert, animated: true)
    }
    
    /// clicked course cell function
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showCourseInfo(indexPath: indexPath)
    }
    
    /// return size of courses array
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return courses.count
    }
    
    /// fill each cell with it's information
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CourseCell", for: indexPath) as! CourseCell
        cell.courseLabel.text = courses[indexPath.row].name
        return cell
    }
    
}
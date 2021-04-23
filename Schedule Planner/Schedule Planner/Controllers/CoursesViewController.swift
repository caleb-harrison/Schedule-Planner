//
//  CoursesViewController.swift
//  Schedule Planner
//
//  Created by Caleb Harrison on 3/23/21.
//

import UIKit
import Combine
import CoreData
import Foundation
import SwifterSwift

class CoursesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    /// all course's table view
    @IBOutlet var tableView: UITableView!
    
    /// courses array
    var courses: [Course] = []
    
    /// selected index
    var selectedIndex: Int = 0
    
    /// current semester label
    @IBOutlet var currentSemester: UILabel!
    
    /// runs when view appears
    override func viewWillAppear(_ animated: Bool) {
        getCourses()
    }
    
    /// runs when view first loads
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //deleteAll()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.white
        
        getCourses()
        currentSemester.text = getSemester()
        
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
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in })
        
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
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in })
        
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
        let alert = UIAlertController(title: courses[indexPath.row].name, message: "\(courses[indexPath.row].instructor ?? "instructor") - Assignments: \(courses[indexPath.row].assignments?.count ?? 0)", preferredStyle: .alert)
        selectedIndex = indexPath.row
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Edit Course", style: .default, handler: {_ in
            alert.dismiss(animated: true, completion: {})
            self.editCourseInfo(indexPath: indexPath)
        }))
        alert.addAction(UIAlertAction(title: "Change Color", style: .default, handler: {_ in
            // change color
            self.changeColor(indexPath: indexPath)
        }))
        self.present(alert, animated: true)
    }
    
    /// gets current semester and returns string
    func getSemester() -> String {
        let today = Date()
        let year = Calendar.current.component(.year, from: today)
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"
        
        let springStart = formatter.date(from: "01-01-\(year)")
        let springEnd = formatter.date(from: "05-01-\(year)")
        let summerStart = formatter.date(from: "05-01-\(year)")
        let summerEnd = formatter.date(from: "08-10-\(year)")
        let fallStart = formatter.date(from: "08-10-\(year)")
        let fallEnd = formatter.date(from: "12-31-\(year)")
        
        if (springStart! ... springEnd!).contains(today) {
            //print("current semester: Spring")
            return "Spring \(year)"
        } else if (summerStart! ... summerEnd!).contains(today) {
            //print("current semester: Summer")
            return "Summer \(year)"
        } else if (fallStart! ... fallEnd!).contains(today){
            //print("current semester: Fall")
            return "Spring \(year)"
        } else {
            //print("No semester/season found.")
            return "Current Semester"
        }
    }
    
    var cancellable: AnyCancellable?
    
    func changeColor(indexPath: IndexPath) {
        let picker = UIColorPickerViewController()
        picker.selectedColor = UIColor(hexString: courses[indexPath.row].courseColor ?? "#858585") ?? UIColor.systemGreen
            
        //  Subscribing selectedColor property changes.
        self.cancellable = picker.publisher(for: \.selectedColor)
            .sink { color in
                
                //  Changing view color on main thread.
                DispatchQueue.main.async {
                    self.courses[indexPath.row].courseColor = color.hexString
                    self.tableView.reloadData()
                    
                    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                        return
                    }

                    let managedContext = appDelegate.persistentContainer.viewContext
                    
                    do {
                        try managedContext.save()
                    } catch let error as NSError {
                        print("Could not save. \(error), \(error.userInfo)")
                    }
                }
            }
        
        self.present(picker, animated: true, completion: nil)
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
        cell.instructorLabel.text = courses[indexPath.row].instructor
        cell.thumbnailLabel.text = "\(courses[indexPath.row].name!.prefix(1))"
        cell.thumbnailView.backgroundColor = UIColor(hexString: courses[indexPath.row].courseColor ?? "#858585")
        cell.addRoundCorners()
        
        return cell
    }
    
    /// delete all objects in database
    func deleteAll() {
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext =
        appDelegate.persistentContainer.viewContext
        
        // Initialize Fetch Request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Course")

        // Configure Fetch Request
        fetchRequest.includesPropertyValues = false

        do {
            let items = try managedContext.fetch(fetchRequest) as! [NSManagedObject]

            for item in items {
                managedContext.delete(item)
            }

            // Save Changes
            try managedContext.save()

        } catch {
            // Error Handling
            // ...
        }
    }
    
}

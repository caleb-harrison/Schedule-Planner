//
//  AddAssignmentViewController.swift
//  Schedule Planner
//
//  Created by Caleb Harrison on 3/23/21.
//

import UIKit
import CoreData
import Foundation
import UserNotifications

class AddAssignmentViewController: UIViewController,  UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    @IBOutlet var tableView: UITableView!
    var parentVC: AssignmentsViewController!
    var courses2: [Course] = []
    var selectedIndex: Int!
    var selectedCourse: Course!
    
    @IBOutlet var assignmentNameTextfield: UITextField!
    @IBOutlet var assignmentDescTextfield: UITextField!
    @IBOutlet var dueDatePicker: UIDatePicker!
    
    @IBOutlet var cancelButton: UIButton!
    @IBOutlet var saveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeButtonsPretty()
        assignmentNameTextfield.delegate = self
        assignmentDescTextfield.delegate = self
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
        if checkFields() {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }

            let managedContext = appDelegate.persistentContainer.viewContext

            let entity = NSEntityDescription.entity(forEntityName: "Assignment",
                                  in: managedContext)!

            let assignment = NSManagedObject(entity: entity,
                                  insertInto: managedContext) as! Assignment
        
            assignment.course = selectedCourse
            assignment.name = assignmentNameTextfield.text
            assignment.desc = assignmentDescTextfield.text
            assignment.dueDate = dueDatePicker.date
            
            do {
                try managedContext.save()
                self.parentVC.getAssignments() // update assignment table view
                
                // set notification for due date
                scheduleNotification(assignmentName: assignmentNameTextfield.text!, dueDate: dueDatePicker.date)
                
                self.dismiss(animated: true, completion: {})
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        }
    }
    
    @IBAction func cancelButtonClicked() {
        self.dismiss(animated: true, completion: {})
    }
    
    // check if text fields are filled in
    func checkFields() -> Bool {
        var array = [String]()
        var nameBool = false
        var descBool = false
        var courseBool = false
        
        if (assignmentNameTextfield.hasText) {
            nameBool = true
        } else {
            array.append("Assignment Name")
        }
        
        if (assignmentDescTextfield.hasText) {
            descBool = true
        } else {
            array.append("Assignment Description")
        }
        
        if (selectedCourse != nil) {
            courseBool = true
        } else {
            array.append("Selected Course")
        }
        
        if (nameBool && descBool && courseBool) {
            return true
        } else {
            var string = ""
            
            for word in array {
                string.append(word + "\n")
            }
            string.removeLast()
            
            let alert = UIAlertController(title: "Missing the following fields:", message: string, preferredStyle: .alert)
            alert.setValue(NSAttributedString(string: alert.message ?? "", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.medium), NSAttributedString.Key.foregroundColor: UIColor.red]), forKey: "attributedMessage")
            alert.addAction(UIAlertAction(title: "Try Again", style: .cancel, handler: nil))
            self.present(alert, animated: true)
            
            return false
        }
    }
    
    /// schedule notification for due date at selected time everyday
    func scheduleNotification(assignmentName: String, dueDate: Date) {
        let center = UNUserNotificationCenter.current()
        
        // Requests authorization from the user for notifications to be sent through the app.
        center.requestAuthorization(options: [.alert, .sound]) {(granted, error) in
        }
        
        // Creates notification "reminder" with attributes title, body, and sound.
        // Sound will have to be changed from current da baby LEZ GOOOOO
        
        let reminder = UNMutableNotificationContent()
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm"
        let dueTime = formatter.string(from: dueDate)
        
        reminder.title = "Your assignment, \(assignmentName), is due today at \(dueTime)."
        // reminder.body = assignmentDescTextfield.text ?? "desc"
        // reminder.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "vibez-lets-go.mp3"))
        
        // This part is the one that is still in progress, when setting date equal
        // to dueDatePicker.date it pulls from the date and time the user said the
        // assignment is due at. This will need to be changed to 8AM and is currently
        // being worked on.
        
        //let date = Calendar.current.date(bySettingHour: 9, minute: 30, second: 00, of: dueDate)! // 9:30AM
        let date = Calendar.current.date(bySettingHour: 20, minute: 55, second: 00, of: dueDate)! // 5:10PM
        
        print("Scheduled notification for \(date)")
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second ], from: date)
        
        // The trigger basically just checks to see what time it is and if it
        // matches the date in "let date = dueDatePicker.date" the notification
        // will be pushed
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuidString, content: reminder, trigger: trigger)
        
        center.add(request) { (error) in
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
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

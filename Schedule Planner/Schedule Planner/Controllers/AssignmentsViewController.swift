//
//  AssignmentsViewController.swift
//  Schedule Planner
//
//  Created by Caleb Harrison on 3/23/21.
//

import UIKit
import Lottie
import CoreData
import Foundation

class AssignmentsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    /// all assignment's table view
    @IBOutlet var tableView: UITableView!
    
    /// assignments array
    var assignments: [Assignment] = []
    
    /// courses array
    var courses: [Course] = []
    
    /// selected index
    var selectedIndex: Int = 0
    
    /// view for animations
    let animationView = AnimationView()
    
    /// current semester label
    @IBOutlet var currentSemester: UILabel!
    
    /// runs when view appears
    override func viewWillAppear(_ animated: Bool) {
        getAssignments()
    }
    
    /// runs when view first loads
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //deleteAll()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.white
        
        getAssignments()
        currentSemester.text = getSemester()
        print("Current assignments in array: \(assignments.count).")
        
        // add long press to delete
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        longPressGesture.minimumPressDuration = 0.5
        self.tableView.addGestureRecognizer(longPressGesture)
    }
    
    /// get assignments from database, sort, and reload tableview
    func getAssignments() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
         
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest =
           NSFetchRequest<NSManagedObject>(entityName: "Assignment")
         
        do {
            assignments = try managedContext.fetch(fetchRequest) as? [Assignment] ?? []
            sortAssignments()
            self.tableView.reloadData()
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    /// sort assignments by due date/time
    func sortAssignments() {
        // checks time interval since now and sorts by distance
        if assignments.count > 1 {
            assignments.sort(by: {($0.dueDate!.timeIntervalSinceNow) < ($1.dueDate!.timeIntervalSinceNow)})
        }
    }
    
    ///mark assignment as complete
    func completeAssignment(indexPath: IndexPath) {
        // delete from table view and database
        deleteAssignment(indexPath: indexPath)
        
        // play confetti animation
        playConfetti()
    }
    
    /// play confetti animation
    func playConfetti() {
        animationView.isHidden = false
        animationView.animation = Animation.named("confetti-2")
        animationView.backgroundColor = .none
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .playOnce
        animationView.frame = view.bounds
        view.addSubview(animationView)
        animationView.play() { (finished) in
            self.animationView.isHidden = true
        }
    }
    
    /// delete assignment from database and array then reload tableview
    func deleteAssignment(indexPath: IndexPath) {
        selectedIndex = indexPath.row
        let deletedAssignment = assignments[selectedIndex]
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext =
        appDelegate.persistentContainer.viewContext
        
        managedContext.delete(deletedAssignment)
        assignments.remove(at: selectedIndex)
        tableView.deleteRows(at: [indexPath], with: .fade)
        self.tableView.reloadData()
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    /// handle long press function for delete alert
    @objc func handleLongPress(longPressGesture: UILongPressGestureRecognizer) {
        // find out where the long press is
        let p = longPressGesture.location(in: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: p)
        let assignmentName = assignments[indexPath!.row].name
        if longPressGesture.state == UIGestureRecognizer.State.began {
            let alert = UIAlertController(title: "Would you like to delete \(assignmentName ?? "this assignment")?", message: nil, preferredStyle: .alert)
            selectedIndex = indexPath!.row
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: {_ in
                alert.dismiss(animated: true, completion: {})
                self.deleteAssignment(indexPath: indexPath!)
            }))
            self.present(alert, animated: true)
        }
    }
    
    /// alert to show assignment inforrmation
    func showAssignmentInfo(indexPath: IndexPath) {
        let alert = UIAlertController(title: assignments[indexPath.row].name, message: assignments[indexPath.row].desc, preferredStyle: .alert)
        selectedIndex = indexPath.row
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Edit", style: .default, handler: {_ in
            alert.dismiss(animated: true, completion: {})
        }))
        alert.addAction(UIAlertAction(title: "Complete", style: .default, handler: {_ in
            alert.dismiss(animated: true, completion: {
                self.completeAssignment(indexPath: indexPath)
            })
        }))
        self.present(alert, animated: true)
    }
    
    /// add new assignment/shows assignment creation screen
    @IBAction func addNewAssignment() {
        getCourses()
        
        if courses.count > 0 {
            // segue to add assignment screen
            performSegue(withIdentifier: "AddAssignmentSegue", sender: self)
        } else {
            // alert saying to add a course first
            let alert = UIAlertController(title: "You must add a course before adding an assignment.", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
            self.present(alert, animated: true)
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
            courses = try managedContext.fetch(fetchRequest) as? [Course] ?? []
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    /// get assignment's due date and turn to string (Month/Day)
    func monthAndDayToString(assignment: Assignment) -> String {
        let date = assignment.dueDate!
        let formatter = DateFormatter()
        formatter.dateFormat = "M/dd"
        return "Due: \((formatter.string(from: date)))"
    }
    
    /// get assignment's due time and turn to string (Hour:Minute)
    func timeToString(assignment: Assignment) -> String {
        let time = assignment.dueDate!
        let formatter = DateFormatter()
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        formatter.dateFormat = "h:mma"
        return (formatter.string(from: time))
    }
    
    /// clicked assignment function
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showAssignmentInfo(indexPath: indexPath)
    }
    
    /// return assignment count for how many cells to show
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("found assignments count of \(assignments.count)")
        return assignments.count
    }
    
    /// fill each cell with it's information
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AssignmentCell", for: indexPath) as! AssignmentCell
        cell.assignmentLabel.text = assignments[indexPath.row].name
        cell.dueDateLabel.text = monthAndDayToString(assignment: assignments[indexPath.row])
        cell.dueTimeLabel.text = timeToString(assignment: assignments[indexPath.row])
        cell.courseNameLabel.text = String(assignments[indexPath.row].course!.name ?? "No Course Selected")
        cell.courseNameLabel.textColor = UIColor(hexString: assignments[indexPath.row].course!.courseColor ?? "#858585")
        
        cell.completeButtonAction = { [unowned self] in
            
            // this code works but only marks the top one as complete..
            // you must first select a row and then hit the complete button
            // because the indexpath is only changed that way..
            // so; must find a way to get indexpath just from hitting button
            //print(indexPath.row)
            self.completeAssignment(indexPath: indexPath)
        }
        
        return cell
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
    
    /// prepare view controller for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddAssignmentSegue" {
            if let vc = segue.destination as? AddAssignmentViewController {
                vc.parentVC = self
            }
        }
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
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Assignment")

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

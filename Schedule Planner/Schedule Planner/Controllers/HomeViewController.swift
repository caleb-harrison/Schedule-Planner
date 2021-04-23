//
//  HomeViewController.swift
//  Schedule Planner
//
//  Created by Caleb Harrison on 3/23/21.
//

import UIKit
import Lottie
import CoreData
import Foundation

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var profilePicture: UIImageView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var profileName: UILabel!
    @IBOutlet var assignmentCountLabel: UILabel!
    @IBOutlet var homeMessage: UILabel!
    
    /// view for animations
    let animationView = AnimationView()
    
    /// assignments array
    var assignments: [Assignment] = []
    
    /// selected index
    var selectedIndex: Int = 0
    
    /// runs when view appears
    override func viewWillAppear(_ animated: Bool) {
        getTodaysAssignments()
        getProfilePicture()
        getProfileName()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.white
        
        getTodaysAssignments()
        getWelcomeMessage()
        print("Todays assignments in array: \(assignments.count).")
        
        // add long press to delete
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        longPressGesture.minimumPressDuration = 0.5
        self.tableView.addGestureRecognizer(longPressGesture)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.profilePicture.layer.cornerRadius = profilePicture.bounds.width/2
    }
    
    /// get todays assignments from database, sort, and reload tableview
    func getTodaysAssignments() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
         
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest =
           NSFetchRequest<NSManagedObject>(entityName: "Assignment")
         
        do {
            assignments = try managedContext.fetch(fetchRequest) as? [Assignment] ?? []
            sortAssignments()
            filterAssignments()
            self.tableView.reloadData()
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    /// filter assignments to only show what's due today
    func filterAssignments() {
        if assignments.count > 0 {
            let calendar = Calendar.current
            assignments = assignments.filter({calendar.isDateInToday($0.dueDate! as Date)})
        }
    
        assignmentCountLabel.text = "You have \(assignments.count) assignments due today."
        
        // assignments.count is the amount of assignments due today
    }
    
    /// sort assignments by due date/time
    func sortAssignments() {
        // checks time interval since now and sorts by distance
        if assignments.count > 0 {
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
        filterAssignments()
        
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
    
    func getProfileName() {
        profileName.text = UserDefaults.standard.string(forKey: "ProfileName") ?? "Student"
    }
    
    func getProfilePicture() {
        if let imageData = UserDefaults.standard.object(forKey: "profilePicture") as? Data, let image = UIImage(data: imageData) {
            
            self.profilePicture.image = image
        }
    }
    
    func getWelcomeMessage() {
        let phrases = ["Welcome back,",
                       "What's up,",
                       "Do your work,"]
        homeMessage.text = phrases.randomElement()
    }
    
    /// clicked assignment function
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //showAssignmentInfo(indexPath: indexPath)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("found assignments count of \(assignments.count)")
        return assignments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodaysAssignmentCell", for: indexPath) as! TodaysAssignmentCell
        cell.assignmentLabel.text = assignments[indexPath.row].name
        cell.dueDateLabel.text = monthAndDayToString(assignment: assignments[indexPath.row])
        cell.dueTimeLabel.text = timeToString(assignment: assignments[indexPath.row])
        cell.courseNameLabel.text = String(assignments[indexPath.row].course!.name ?? "No Course Selected")
        cell.courseNameLabel.textColor = UIColor(hexString: assignments[indexPath.row].course!.courseColor ?? "#858585")
        
        cell.completeButtonAction = { [unowned self] in
            self.completeAssignment(indexPath: indexPath)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: Date())
    }
}

//
//  AssignmentCell.swift
//  Schedule Planner
//
//  Created by Caleb Harrison on 3/23/21.
//

import Foundation
import UIKit

class AssignmentCell: UITableViewCell {
    
    /// label to show assignment name
    @IBOutlet var assignmentLabel: UILabel!
    
    /// label to show due date
    @IBOutlet var dueDateLabel: UILabel!
    
    /// label to show due time
    @IBOutlet var dueTimeLabel: UILabel!
    
    /// label to show assignment's course name
    @IBOutlet var courseNameLabel: UILabel!
    
    /// complete button
    @IBOutlet weak var completeButton: UIButton!
    
    /// action to be added to complete button
    var completeButtonAction: (() -> ())?
    
    /// adds action from other view controller
    override func awakeFromNib() {
        super.awakeFromNib()
        // Add action to perform when the button is tapped
        self.completeButton.addTarget(self, action: #selector(completeButtonClicked(_:)), for: .touchUpInside)
    }
    
    /// complete button clicked calls action
    @IBAction func completeButtonClicked(_ sender: Any) {
        completeButtonAction?()
    }
    
}

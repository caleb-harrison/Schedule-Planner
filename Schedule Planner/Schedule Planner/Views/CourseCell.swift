//
//  CourseCell.swift
//  Schedule Planner
//
//  Created by Caleb Harrison on 3/23/21.
//

import Foundation
import UIKit

class CourseCell: UITableViewCell {
    
    /// label to show course name
    @IBOutlet var courseLabel: UILabel!
    
    /// label to show instructor name
    @IBOutlet var instructorLabel: UILabel!
    
    /// thumbnail square view
    @IBOutlet var thumbnailView: UIView!
    
    /// thumbnail square label text
    @IBOutlet var thumbnailLabel: UILabel!
    
    func addRoundCorners() {
        thumbnailView.layer.cornerRadius = 8.0
    }
}

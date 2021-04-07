//
//  TabBarController.swift
//  Schedule Planner
//
//  Created by Caleb Harrison on 3/23/21.
//

import UIKit
import SOTabBar

class TabBarController: SOTabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        
        // instantiate home storyboard
        let homeStoryboard = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HOME_ID")
        
        // instantiate assignments storyboard
        let assignmentsStoryboard = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ASSIGNMENTS_ID")
        
        // instantiate courses storyboard
        let coursesStoryboard = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "COURSES_ID")
        
        // instantiate profile storyboard
        let profileStoryboard = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PROFILE_ID")
        
        // set home tab bar icon
        homeStoryboard.tabBarItem = UITabBarItem(title: "Home", image: UIImage(named: "home"), selectedImage: UIImage(named: "home_Selected"))
        
        // set assignments tab bar icon
        assignmentsStoryboard.tabBarItem = UITabBarItem(title: "Assignments", image: UIImage(named: "assignments"), selectedImage: UIImage(named: "assignments_Selected"))
        
        // set courses tab bar icon
        coursesStoryboard.tabBarItem = UITabBarItem(title: "Courses", image: UIImage(named: "courses"), selectedImage: UIImage(named: "courses_Selected"))
        
        // set profile tab bar icon
        profileStoryboard.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(named: "profile"), selectedImage: UIImage(named: "profile_Selected"))
           
        // save all view controllers in array
        viewControllers = [homeStoryboard,
                           assignmentsStoryboard,
                           coursesStoryboard,
                           profileStoryboard]
    }
    
    override func loadView() {
        super.loadView()
        SOTabBarSetting.tabBarHeight = 50.0
        SOTabBarSetting.tabBarTintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        SOTabBarSetting.tabBarSizeSelectedImage = CGFloat(25.0)
        SOTabBarSetting.tabBarCircleSize = CGSize(width: 60, height: 60)
    }
    
}

extension TabBarController: SOTabBarControllerDelegate {
    func tabBarController(_ tabBarController: SOTabBarController, didSelect viewController: UIViewController) {
        print(viewController.tabBarItem.title ?? "")
    }
}

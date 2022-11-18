//
//  TabBarViewController.swift
//  SkinSkan
//
//  Created by Brian Ooi on 11/14/22.
//

import Foundation
import UIKit

/// View controller class to add rounded corners to the bottom tab bar
class TabBarViewController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBar.layer.masksToBounds = true
        self.tabBar.clipsToBounds = true
        self.tabBar.layer.borderColor = UIColor.lightGray.cgColor
        self.tabBar.layer.borderWidth = 0.15
        self.tabBar.layer.cornerRadius = 20
        self.tabBar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        self.tabBar.unselectedItemTintColor = UIColor.lightGray
    }
}

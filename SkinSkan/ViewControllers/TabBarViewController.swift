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
        self.tabBar.layer.cornerRadius = 20
    }
}

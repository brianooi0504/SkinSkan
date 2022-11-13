//
//  HomeViewController.swift
//  SkinSkan
//
//  Created by Brian Ooi on 9/22/22.
//

import Foundation
import UIKit

/// View controller class for the home screen where the user can decide to start a test, see test history, or disease information
/// First tab (index 0) for the root tab bar controller
class HomeViewController: UIViewController {
    // MARK: IBOutlets
    /// References for the Start a test, See test history, and Read more on skin diseases buttons
    @IBOutlet var testButton: UIButton!
    @IBOutlet var historyButton: UIButton!
    @IBOutlet var infoButton: UIButton!
    
    // MARK: IBActions
    /// For the Read more on skin diseases button
    /// Displays the InformationViewController by switching to the second tab (index 1)
    @IBAction func showInformationVC(_ sender: Any) {
        tabBarController?.selectedIndex = 1
    }

    /// For the See test history button
    /// Displays the ProfileViewController by switching to the fourth and final tab (index 3)
    @IBAction func showProfileVC(_ sender: Any) {
        tabBarController?.selectedIndex = 3
    }
}

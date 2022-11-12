//
//  HomeViewController.swift
//  SkinSkan
//
//  Created by Brian Ooi on 9/22/22.
//

import Foundation
import UIKit

class HomeViewController: UIViewController {
    @IBOutlet var testButton: UIButton!
    @IBOutlet var historyButton: UIButton!
    @IBOutlet var infoButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Welcome!"
    }
    
    @IBAction func showInformationVC(_ sender: Any) {
        tabBarController?.selectedIndex = 1
    }

    @IBAction func showProfileVC(_sender: Any) {
        tabBarController?.selectedIndex = 3
    }
}

//
//  HomeViewController.swift
//  SkinSkan
//
//  Created by Brian Ooi on 9/22/22.
//

import Foundation
import UIKit

//PLACES API = "AIzaSyCVj3pN9drA9QdjGh0HxbQ94LzVyBFJy8U"

class HomeViewController: UIViewController {
    @IBOutlet var testButton: UIButton!
    @IBOutlet var historyButton: UIButton!
    @IBOutlet var infoButton: UIButton!
    
    override func viewDidLoad() {
        title = "Welcome!"
    }
    
    @IBAction func showInformationVC(_ sender: Any) {
        tabBarController?.selectedIndex = 1
    }

}

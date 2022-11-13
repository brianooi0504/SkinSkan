//
//  AboutViewController.swift
//  SkinSkan
//
//  Created by Brian Ooi on 11/13/22.
//

import Foundation
import UIKit

/// View controller class for the About pop up to display app and disclaimer information
class AboutViewController: UIViewController {
    // MARK: IBActions
    /// For top right Done bar button
    /// Dismisses the popup view controller
    @IBAction func doneButtonTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
}

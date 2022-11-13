//
//  SettingsCell.swift
//  SkinSkan
//
//  Created by Brian Ooi on 11/8/22.
//

import Foundation
import UIKit

/// TableViewCell class used in TableView of ProfileViewController
class ProfileCell: UITableViewCell {
    /// References for labels and switches for each row
    @IBOutlet var switchControl: UISwitch!
    @IBOutlet var settingsLabel: UILabel!
    
    /// Variables for UserDefaults for the Save History setting
    let userDefaults = UserDefaults.standard
    let SAVE_HISTORY_KEY = "saveHistoryKey"
    
    /// Obtains row information from ProfileViewController and configures the cell
    func configure(labelText: String, containsSwitch: Bool) {
        settingsLabel.text = labelText
        switchControl.addTarget(self, action: #selector(handleSwitchAction), for: .valueChanged)
        /// Hides the switch for non-app settings sections
        switchControl.isHidden = !containsSwitch
        setSwitch()
    }
    
    /// Sets the switch to turn on or off based on current UserDefaults
    func setSwitch() {
        if userDefaults.bool(forKey: SAVE_HISTORY_KEY) {
            switchControl.setOn(true, animated: true)
        } else {
            switchControl.setOn(false, animated: true)
        }
    }
    
    /// Method called when the switch state is changed
    /// Saves the new setting to UserDefaults
    @objc func handleSwitchAction(sender: UISwitch) {
        if sender.isOn {
            print("Turned On")
            userDefaults.set(true, forKey: SAVE_HISTORY_KEY)
        } else {
            print("Turned Off")
            userDefaults.set(false, forKey: SAVE_HISTORY_KEY)
        }
    }
}

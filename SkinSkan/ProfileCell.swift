//
//  SettingsCell.swift
//  SkinSkan
//
//  Created by Brian Ooi on 11/8/22.
//

import Foundation
import UIKit

class ProfileCell: UITableViewCell {
    @IBOutlet var switchControl: UISwitch!
    @IBOutlet var settingsLabel: UILabel!
    let userDefaults = UserDefaults.standard
    let SAVE_HISTORY_KEY = "saveHistoryKey"
    
    func configure(labelText: String, containsSwitch: Bool) {
        settingsLabel.text = labelText
        switchControl.addTarget(self, action: #selector(handleSwitchAction), for: .valueChanged)
        switchControl.isHidden = !containsSwitch
        setSwitch()
    }
    
    func setSwitch() {
        if userDefaults.bool(forKey: SAVE_HISTORY_KEY) {
            switchControl.setOn(true, animated: true)
        } else {
            switchControl.setOn(false, animated: true)
        }
    }
    
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

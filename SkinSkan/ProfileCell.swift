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
    private var userDefaults: UserDefaults!
    private var userDefaultsKey: String!
    
    func configure(labelText: String, containsSwitch: Bool, userDefaults: UserDefaults, userDefaultsKey: String) {
        self.userDefaults = userDefaults
        self.userDefaultsKey = userDefaultsKey
        settingsLabel.text = labelText
        switchControl.addTarget(self, action: #selector(handleSwitchAction), for: .valueChanged)
        switchControl.isHidden = !containsSwitch
        setSwitch()
    }
    
    func setSwitch() {
        if userDefaults.bool(forKey: userDefaultsKey) {
            switchControl.setOn(true, animated: true)
        } else {
            switchControl.setOn(false, animated: true)
        }
    }
    
    @objc func handleSwitchAction(sender: UISwitch) {
        if sender.isOn {
            print("Turned On")
            userDefaults.set(true, forKey: userDefaultsKey)
        } else {
            print("Turned Off")
            userDefaults.set(false, forKey: userDefaultsKey)
        }
    }
}

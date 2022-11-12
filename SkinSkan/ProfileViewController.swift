//
//  ProfileViewController.swift
//  SkinSkan
//
//  Created by Brian Ooi on 9/22/22.
//

import Foundation
import UIKit

class ProfileViewController: UITableViewController {
    var testResults: [String] = ["Test 1", "Test 2"]
    let userDefaults = UserDefaults.standard
    let SAVE_HISTORY_KEY = "saveHistoryKey"
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return ProfileSections.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = ProfileSections(rawValue: section) else { return 0 }
        
        switch section {
        case .testHistory:
            return testResults.count
        case .appSettings:
            return appSettingsOptions.allCases.count
        case .feedback:
            return feedbackOptions.allCases.count
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor(red: 55/255, green: 120/255, blue: 250/255, alpha: 1)

        let title = UILabel()
        title.font = UIFont.boldSystemFont(ofSize: 16)
        title.textColor = .white
        title.text = ProfileSections(rawValue: section)?.description
        view.addSubview(title)
        title.translatesAutoresizingMaskIntoConstraints = false
        title.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        title.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16).isActive = true

        return view
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath) as! ProfileCell
        guard let section = ProfileSections(rawValue: indexPath.section) else { return UITableViewCell() }
        
        switch section {
        case .testHistory:
            cell.configure(labelText: testResults[indexPath.row], containsSwitch: false, userDefaults: userDefaults, userDefaultsKey: SAVE_HISTORY_KEY)
        case .appSettings:
            let appSetting = appSettingsOptions(rawValue: indexPath.row)
            cell.configure(labelText: appSetting?.description ?? "error", containsSwitch: true, userDefaults: userDefaults, userDefaultsKey: SAVE_HISTORY_KEY)
        case .feedback:
            let feedbackChoice = feedbackOptions(rawValue: indexPath.row)
            cell.configure(labelText: feedbackChoice?.description ?? "error", containsSwitch: false, userDefaults: userDefaults, userDefaultsKey: SAVE_HISTORY_KEY)
        }
        
        return cell
    }
}

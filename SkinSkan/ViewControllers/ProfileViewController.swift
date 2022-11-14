//
//  ProfileViewController.swift
//  SkinSkan
//
//  Created by Brian Ooi on 9/22/22.
//

import Foundation
import UIKit
import CoreData

/// View controller class for the profile screen where test history and about are displayed, save history settings are changed, feedbacks are sent
/// Fourth and final tab (index 3) for the root tab bar controller
class ProfileViewController: UIViewController {
    // MARK: Variables
    /// DateFormatter object used to convert Date objects into Strings
    let dateFormatter = DateFormatter()
    
    /// Core Data variables
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    /// All test history to be obtained from Core Data
    var testResults: [Prediction] = []
    
    // MARK: IBOutlets
    /// References the TableView
    @IBOutlet var profileTableView: UITableView!
    
    /// Fetch all test history data from Core Data
    override func viewDidLoad() {
        super.viewDidLoad()
        /// Sets the format for the DateFormatter
        dateFormatter.dateFormat = "MMM dd yyyy HH:mm:ss"
        fetchPredictions()
    }
    
    /// Fetch all test history data from Core Data every time the ProfileViewController is displayed to display the most updated information
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        fetchPredictions()
    }
    
    // MARK: Self-Defined Methods
    /// Method called to obtain test history data from Core Data
    func fetchPredictions() {
        do {
            self.testResults = try context.fetch(Prediction.fetchRequest())
            
            /// Reload the TableView after obtaining data
            DispatchQueue.main.async {
                self.profileTableView.reloadData()
            }
        } catch {
            print("Unable to load test history")
        }
    }
    
    /// Method called to dismiss the test history pop up
    @objc func dismissPopUp() {
        self.dismiss(animated: true, completion: nil)
    }
    
    /// Displays the NearbyViewController by switching to the third tab (index 2)
    func openNearbyTab() {
        tabBarController?.selectedIndex = 2
    }
}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    // MARK: TableViewDataSource Methods
    /// Sets number of sections in TableView according to ProfileSections enumeration
    func numberOfSections(in tableView: UITableView) -> Int {
        return ProfileSections.allCases.count
    }
    
    /// Sets the number of rows in each TableView section according to ProfileSections, AppSettingsOptions, FeedbackOptions enums
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = ProfileSections(rawValue: section) else { return 0 }
        
        switch section {
        case .testHistory:
            return testResults.count
        case .appSettings:
            return AppSettingsOptions.allCases.count
        case .feedback:
            return FeedbackOptions.allCases.count
        }
    }
    
    /// Configures each TableViewCell as ProfileCell class instances using ProfileCell identifier
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath) as! ProfileCell
        /// Adds a disclosure indicator at the end of each cell
        cell.accessoryType = .disclosureIndicator
        guard let section = ProfileSections(rawValue: indexPath.section) else { return UITableViewCell() }
        
        switch section {
        case .testHistory:
            /// Sets the label text and switch options with the datetime from each test history entry
            cell.configure(labelText: dateFormatter.string(from: testResults[indexPath.row].datetime), containsSwitch: false)
        case .appSettings:
            /// Sets the label text and switch options according to AppSettingsOptions enumeration
            let appSetting = AppSettingsOptions(rawValue: indexPath.row)
            cell.configure(labelText: appSetting?.description ?? "error", containsSwitch: true)
            /// App setting cells do not show a disclosure indicator at the end
            cell.accessoryType = .none
        case .feedback:
            /// Sets the label text and switch options according to FeedbackOptions enumeration
            let feedbackChoice = FeedbackOptions(rawValue: indexPath.row)
            cell.configure(labelText: feedbackChoice?.description ?? "error", containsSwitch: false)
        }
        
        /// Sets round corners for the cell
        cell.layer.cornerRadius = 8
        return cell
    }
    
    // MARK: TableViewDelegate Methods
    /// Sets the header view for each TableView section
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor(named: "MedMaroon")

        let title = UILabel()
        title.font = UIFont.boldSystemFont(ofSize: 16)
        title.textColor = .white
        /// Section title is obtained from ProfileSections enumeration
        title.text = ProfileSections(rawValue: section)?.description
        view.addSubview(title)
        
        title.translatesAutoresizingMaskIntoConstraints = false
        title.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        title.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16).isActive = true
        /// Round corners are added to the header view
        view.layer.cornerRadius = 8

        return view
    }

    /// Sets the height for the section headers
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    /// Sets the height for each TableView row
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    /// Adds a Delete button as a trailing swipe action (accessible when user swipes left on a cell)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let section = ProfileSections(rawValue: indexPath.section) else { return nil }
        
        switch section {
        /// The button is only added for rows in the Test History section
        case .testHistory:
            let action = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in
                
                /// Deletes the test history entry from Core Data and saves the updated test history data
                let historyToRemove = self.testResults[indexPath.row]
                self.context.delete(historyToRemove)
                
                do {
                    try self.context.save()
                } catch {
                    print("Cannot delete history")
                }
                
                /// Retrieves the most updated test history data and reloads the TableView
                self.fetchPredictions()
            }
            
            return UISwipeActionsConfiguration(actions: [action])
        default:
            return nil
        }
    }
    
    /// Sets the actions and methods called whenever a TableView row is selected
    /// Only for rows in Test History and About & Feedback sections
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        /// Deselects the selected row
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let section = ProfileSections(rawValue: indexPath.section) {
            switch section {
            /// For rows in the Test History section
            /// Initializes a ResultViewController and passes in the Prediction object
            /// Displays the ResultViewController as a pop up
            case .testHistory:
                guard let vc = storyboard?.instantiateViewController(withIdentifier: "ResultViewController") as? ResultViewController else { return }
                /// Adds a top right Done bar button
                vc.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissPopUp))
                /// ResultViewController is configured with the selected Prediction object
                /// Sets action for Find Dermatologist button to dismiss ResultViewController and show NearbyViewController
                vc.configure(predictionResult: testResults[indexPath.row], findDermMethod: {
                    self.dismissPopUp()
                    self.openNearbyTab()
                })
                /// The title of the navigation bar in the ResultViewController is the datetime of the selected Prediction object
                vc.title = dateFormatter.string(from: testResults[indexPath.row].datetime)
                
                let navController = UINavigationController(rootViewController: vc)
                present(navController, animated: true)
            
            /// For rows in the About & Feedback section
            /// Initializes a FeedbackViewController and displays as a pop up for Feedback
            /// Initializes a AboutViewController and displays as a pop up for About
            case .feedback:
                let feedbackChoice = FeedbackOptions(rawValue: indexPath.row)
                
                switch feedbackChoice {
                case .feedback:
                    guard let vc = storyboard?.instantiateViewController(withIdentifier: "FeedbackViewController") as? FeedbackViewController else { return }
                    let navController = UINavigationController(rootViewController: vc)
                    present(navController, animated: true)
                
                case .about:
                    guard let vc = storyboard?.instantiateViewController(withIdentifier: "AboutViewController") as? AboutViewController else { return }
                    let navController = UINavigationController(rootViewController: vc)
                    present(navController, animated: true)
                
                default:
                    print("None")
                }
            default:
                print("Nothing")
            }
        }
    }
}

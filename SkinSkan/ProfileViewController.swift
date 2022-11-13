//
//  ProfileViewController.swift
//  SkinSkan
//
//  Created by Brian Ooi on 9/22/22.
//

import Foundation
import UIKit
import CoreData

class ProfileViewController: UITableViewController {
    var testResults: [Prediction] = []
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let dateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormatter.dateFormat = "MMM dd yyyy HH:mm:ss"
        tableView.layoutMargins = .init(top: 0.0, left: 16, bottom: 0.0, right: 16)
        // if you want the separator lines to follow the content width
        tableView.separatorInset = tableView.layoutMargins
        fetchPredictions()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        print("Hello")
        fetchPredictions()
    }
    
    func fetchPredictions() {
        do {
            self.testResults = try context.fetch(Prediction.fetchRequest())
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } catch {
            print("Unable to load test history")
        }
    }
    
}

extension ProfileViewController{
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
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath) as! ProfileCell
        cell.accessoryType = .disclosureIndicator
        guard let section = ProfileSections(rawValue: indexPath.section) else { return UITableViewCell() }
        
        switch section {
        case .testHistory:
            cell.configure(labelText: dateFormatter.string(from: testResults[indexPath.row].datetime), containsSwitch: false)
        case .appSettings:
            let appSetting = appSettingsOptions(rawValue: indexPath.row)
            cell.configure(labelText: appSetting?.description ?? "error", containsSwitch: true)
            cell.accessoryType = .none
        case .feedback:
            let feedbackChoice = feedbackOptions(rawValue: indexPath.row)
            cell.configure(labelText: feedbackChoice?.description ?? "error", containsSwitch: false)
        }
        
        return cell
    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let section = ProfileSections(rawValue: indexPath.section) else { return nil }
        
        switch section {
        case .testHistory:
            let action = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in
                
                let historyToRemove = self.testResults[indexPath.row]
                self.context.delete(historyToRemove)
                
                do {
                    try self.context.save()
                } catch {
                    print("Cannot delete history")
                }
                
                self.fetchPredictions()
            }
            
            return UISwipeActionsConfiguration(actions: [action])
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let section = ProfileSections(rawValue: indexPath.section) {
            switch section {
            case .testHistory:
                guard let vc = storyboard?.instantiateViewController(withIdentifier: "ResultViewController") as? ResultViewController else { return }
                
                vc.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissPopUp))
                vc.configure(predictionResult: testResults[indexPath.row])
                vc.title = dateFormatter.string(from: testResults[indexPath.row].datetime)
                
                let navController = UINavigationController(rootViewController: vc)
                present(navController, animated: true)
            case .feedback:
                let feedbackChoice = feedbackOptions(rawValue: indexPath.row)
                
                switch feedbackChoice {
                case .feedback:
                    guard let vc = storyboard?.instantiateViewController(withIdentifier: "FeedbackViewController") as? FeedbackViewController else { return }
                    let navController = UINavigationController(rootViewController: vc)
                    present(navController, animated: true)
                case .about:
                    guard let vc = storyboard?.instantiateViewController(withIdentifier: "AboutViewController") as? AboutViewController else { return }
                    let navController = UINavigationController(rootViewController: vc)
                    present(navController, animated: true)
                case .none:
                    print("None")
                }
            default:
                print("Nothing")
            }
        }
    }
    
    @objc func dismissPopUp() {
        self.dismiss(animated: true, completion: nil)
    }
}

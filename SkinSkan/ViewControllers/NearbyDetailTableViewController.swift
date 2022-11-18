//
//  NearbyDetailViewControllerNew.swift
//  SkinSkan
//
//  Created by Brian Ooi on 9/23/22.
//

import Foundation
import UIKit

/// View controller class for the TableView housed in the ContainerView in NearbyDetailTableViewController
class NearbyDetailTableViewController: UITableViewController {
    // MARK: Variables
    private var dermatologist: Dermatologist!
    /// Titles for each sections of the TableVIew
    private let sectionLabels = ["Name", "How to get there", "Operating hours", "Contacts", "Website", "Rating", "Learn More"]
    private var detailTableData: [DetailCellData]!
    /// Pattern used to generate the Google search link for the dermatologist
    let pattern = "[^A-Za-z0-9]+"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// Initializes the array storing all information to be displayed in the TableView
        detailTableData = [DetailCellData(expanded: true, info: dermatologist.title),
                           DetailCellData(expanded: true, info: dermatologist.address),
                           DetailCellData(expanded: true, info: dermatologist.hours.joined(separator: "\n")),
                           DetailCellData(expanded: true, info: dermatologist.contacts),
                           DetailCellData(expanded: true, info: dermatologist.website),
                           DetailCellData(expanded: true, info: String(dermatologist.rating) + " ★"),
                           DetailCellData(expanded: true, info: "Get more information on Google")]
        
        tableView.reloadData()
        
    }
    
    /// Obtains dermatologist information from NearbyDetailViewController and configures the view controller
    func configure(dermatologist: Dermatologist) {
        self.dermatologist = dermatologist
    }
    
    // MARK: Self-Defined Functions
    /// Called when the view for each TableView section is pressed
    @objc func handleExpand(button: UIButton) {
        let section = button.tag
        
        let indexPath = IndexPath(row: 0, section: section)
        let indexPaths: [IndexPath] = [indexPath]
        
        /// Inverts the Expanded variable in the detailTableData entry
        let expanded = detailTableData[section].expanded
        detailTableData[section].expanded = !expanded
        
        /// Changes the title of the TableView section header
        button.setTitle(expanded ? sectionLabels[section] + " +++" : sectionLabels[section] + " ---", for: .normal)
        
        if expanded {
            /// Delete rows when collapsing the TableView section
            tableView.deleteRows(at: indexPaths, with: .fade)
        } else {
            /// Add a row when expanding the TableView section
            tableView.insertRows(at: indexPaths, with: .fade)
        }
    }
    
    /// Opens pop up to allow users to select navigation apps to use to display the directions
    @objc func openMap() {
        let latitude = dermatologist.location.coordinate.latitude
        let longitude = dermatologist.location.coordinate.longitude
        
        /// Generate URL links for Apple Maps, Google Maps, and Waze for linking use
        let appleURL = "http://maps.apple.com/?daddr=\(latitude),\(longitude)"
        let googleURL = "comgooglemaps://?daddr=\(latitude),\(longitude)&directionsmode=driving"
        let wazeURL = "waze://?ll=\(latitude),\(longitude)&navigate=yes"
        
        let appleMapsItem = ("Apple Maps", URL(string: appleURL)!)
        let googleItem = ("Google Maps", URL(string:googleURL)!)
        let wazeItem = ("Waze", URL(string:wazeURL)!)
        
        let navApps = [appleMapsItem, googleItem, wazeItem]
        
        /// Pops up the alert with the above three options
        let alert = UIAlertController(title: "Selection", message: "Select Navigation App", preferredStyle: .actionSheet)
        for app in navApps {
            let button = UIAlertAction(title: app.0, style: .default, handler: { _ in
                UIApplication.shared.open(app.1, options: [:], completionHandler: {success in
                    /// If the selected application is not installed, an alert pops up to notify the user
                    if !success {
                        let alert = UIAlertController(title: "Oops!", message: "\(app.0) is not installed!", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in print("OK tap")}))
                        self.present(alert, animated: true, completion: nil)
                    }
                })
            })
            alert.addAction(button)
        }
        /// Adds a cancel option in the alert
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancel)
        present(alert, animated: true)
    }
    
    /// Opens a pop up to allow users to call the number if contact number is available
    @objc func phoneCall() {
        let phoneNumber = detailTableData[3].info
        
        if phoneNumber != "N/A" {
            let phoneURL: NSURL = URL(string: "TEL://\(phoneNumber.filter("0123456789".contains))")! as NSURL
            UIApplication.shared.open(phoneURL as URL, options: [:], completionHandler: nil)
        }
        
    }
    
    /// Opens the link using Safari if a link is available
    @objc func openBrowser(website: String) {
        if website != "N/A" {
            if let url = URL(string: website) {
                UIApplication.shared.open(url)
            }
        }
    }
}

extension NearbyDetailTableViewController {
    // MARK: TableViewDataSource Methods
    /// Sets number of sections in TableView according to number of elements in detailTableData array
    override func numberOfSections(in tableView: UITableView) -> Int {
        return detailTableData.count
    }
    
    /// Sets the number of rows in each TableView section according to whether it is expanded or collapsed
    /// Displays 1 row for every section if is expanded, 0 if collapsed
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !detailTableData[section].expanded {
            return 0
        }
        
        return 1
    }
    
    /// Configures each TableViewCell as NearbyDetailCell class instances using NearbyDetailCell identifier
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "NearbyDetailCell", for: indexPath) as? NearbyDetailCell else {
            fatalError("Dequeue cell error")
        }
        cell.textLabel?.text = detailTableData[indexPath.section].info
        cell.layer.cornerRadius = 8
        return cell
    }
    
    // MARK: TableViewDelegate Methods
    /// Sets the height of each TableView section
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 36
    }
    
    /// Sets the view of each TableView section header
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let expanded = detailTableData[section].expanded
        let button = UIButton(type: .system)
        button.setTitle(expanded ? sectionLabels[section] + " ---" : sectionLabels[section] + " +++", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(named: "DarkMaroon")
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        /// Calls handleInfoExpand method when selected to expand or collapse the TableView section
        button.addTarget(self, action: #selector(handleExpand), for: .touchUpInside)

        button.tag = section
        button.layer.cornerRadius = 8

        return button
    }
    
    /// Calls openMap method to allow users to select nav apps to open directions to the location
    /// Calls phoneCall method to allow users to call the contact number directly
    /// Calls openBrowser method to open the link in the Website section if available
    /// Calls openBrowser method to open the Google search link
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        /// Deselects the selected row
        tableView.deselectRow(at: indexPath, animated: true)
        let section = indexPath.section
        
        switch section {
            /// When address row is selected
            case 1: openMap()
            /// When contact number row is selected
            case 3: phoneCall()
            /// When dermatologist website row is selected
            case 4: openBrowser(website: detailTableData[4].info)
            case 6:
            /// When Get more information on Google row is selected
                openBrowser(website: "http://www.google.com/search?q=\(dermatologist.title.replacingOccurrences(of: pattern, with: "%20", options: [.regularExpression]))")
            default:
                print("Default")
        }
    }

    

}


//
//  InformationDetailTableViewController.swift
//  SkinSkan
//
//  Created by Brian Ooi on 10/5/22.
//

import Foundation
import UIKit

/// View controller class for the TableView housed in the ContainerView in InformationDetailViewController
class InformationDetailTableViewController: UITableViewController {
    // MARK: Variables
    private var disease: Disease!
    /// Titles for each sections of the TableVIew
    private let sectionLabels = ["Name", "Description", "Similar Disease(s)", "Symptoms", "Treatments", "Learn More"]
    private var detailTableData: [DetailCellData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// Initializes the array storing all information to be displayed in the TableView
        detailTableData = [DetailCellData(expanded: true, info: disease.name),
                           DetailCellData(expanded: true, info: disease.desc),
                           DetailCellData(expanded: true, info: disease.similar),
                           DetailCellData(expanded: true, info: disease.symptom),
                           DetailCellData(expanded: true, info: disease.treatment),
                           DetailCellData(expanded: true, info: "Read more on WebMD")]

        tableView.reloadData()
    }
    
    /// Obtains disease information from InformationDetailViewController and configures the view controller
    func configure(disease: Disease) {
        self.disease = disease
    }

    // MARK: Self-Defined Functions
    /// Called when the view for each TableView section is pressed
    @objc func handleInfoExpand(button: UIButton) {
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
    
    /// Opens the link using Safari if a link is available
    @objc func openBrowser(website: String) {
        if website != "N/A" {
            if let url = URL(string: website) {
                UIApplication.shared.open(url)
            }
        }
    }
}

extension InformationDetailTableViewController {
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
    
    /// Configures each TableViewCell as InformationDetailCell class instances using InformationDetailCell identifier
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "InformationDetailCell", for: indexPath) as? InformationDetailCell else {
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
        button.addTarget(self, action: #selector(handleInfoExpand), for: .touchUpInside)
        button.tag = section
        button.layer.cornerRadius = 8

        return button
    }
    
    /// Calls openBrowser method to open the link in the Website section if available
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        /// Deselects the selected row
        tableView.deselectRow(at: indexPath, animated: true)
        
        let section = indexPath.section
        
        switch section {
            case 5: openBrowser(website: disease.link)
            default:
                print("Default")
        }
    }
}

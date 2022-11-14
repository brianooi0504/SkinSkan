//
//  InformationDetailTableViewController.swift
//  SkinSkan
//
//  Created by Brian Ooi on 10/5/22.
//

import Foundation
import UIKit

class InformationDetailTableViewController: UITableViewController {
    private var disease: Disease!
    private let sectionLabels = ["Name", "Description", "Similar Disease(s)", "Symptoms", "Treatments", "Learn More"]
    private var detailTableData: [DetailCellData]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        detailTableData = [DetailCellData(expanded: true, info: disease.name),
                           DetailCellData(expanded: true, info: disease.desc),
                           DetailCellData(expanded: true, info: disease.similar),
                           DetailCellData(expanded: true, info: disease.symptom),
                           DetailCellData(expanded: true, info: disease.treatment),
                           DetailCellData(expanded: true, info: "Read more on WebMD")]

        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let expanded = detailTableData[section].expanded
        let button = UIButton(type: .system)
        button.setTitle(expanded ? sectionLabels[section] + " ---" : sectionLabels[section] + " +++", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(named: "MedMaroon")
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.addTarget(self, action: #selector(handleInfoExpand), for: .touchUpInside)
        button.tag = section
        button.layer.cornerRadius = 8

        return button
    }

    @objc func handleInfoExpand(button: UIButton) {
        let section = button.tag
        
        var indexPaths = [IndexPath]()
        let indexPath = IndexPath(row: 0, section: section)
        indexPaths.append(indexPath)
        
        let expanded = detailTableData[section].expanded
        detailTableData[section].expanded = !expanded
        
        button.setTitle(expanded ? sectionLabels[section] + " +++" : sectionLabels[section] + " ---", for: .normal)
        
        if expanded {
            tableView.deleteRows(at: indexPaths, with: .fade)
        } else {
            tableView.insertRows(at: indexPaths, with: .fade)
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return detailTableData.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !detailTableData[section].expanded {
            return 0
        }
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionLabels[section]
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 36
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "InformationDetailCell", for: indexPath) as? InformationDetailCell else {
            fatalError("Dequeue cell error")
        }
        cell.textLabel?.text = detailTableData[indexPath.section].info
        cell.layer.cornerRadius = 8
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let section = indexPath.section
        
        switch section {
            case 5: openBrowser(website: disease.link)
            default:
                print("Default")
        }
    }
    
    func configure(disease: Disease) {
        self.disease = disease
    }
    
    @objc func openBrowser(website: String) {
        if website != "N/A" {
            if let url = URL(string: website) {
                UIApplication.shared.open(url)
            }
        }
    }
}

//
//  NearbyDetailViewControllerNew.swift
//  SkinSkan
//
//  Created by Brian Ooi on 9/23/22.
//

import Foundation
import UIKit
import MapKit
import CoreLocation

class NearbyDetailTableViewController: UITableViewController {
    private var dermatologist: Dermatologist!
    private let sectionLabels = ["Name", "How to get there", "Operating hours", "Contacts", "Website", "Rating", "Learn More"]
    private var detailTableData: [DetailCellData]!
    let pattern = "[^A-Za-z0-9]+"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        detailTableData = [DetailCellData(expanded: true, info: dermatologist.title),
                           DetailCellData(expanded: true, info: dermatologist.address),
                           DetailCellData(expanded: true, info: dermatologist.hours.joined(separator: "\n")),
                           DetailCellData(expanded: true, info: dermatologist.contacts),
                           DetailCellData(expanded: true, info: dermatologist.website),
                           DetailCellData(expanded: true, info: String(dermatologist.rating) + " ★"),
                           DetailCellData(expanded: true, info: "Get more information on Google")]

        tableView.reloadData()
        
    }
    
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let expanded = detailTableData[section].expanded
        let button = UIButton(type: .system)
        button.setTitle(expanded ? sectionLabels[section] + " Close" : sectionLabels[section] + " Open", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .yellow
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)

        button.addTarget(self, action: #selector(handleExpand), for: .touchUpInside)

        button.tag = section

        return button
    }

    @objc func handleExpand(button: UIButton) {
        let section = button.tag
        
        var indexPaths = [IndexPath]()
        let indexPath = IndexPath(row: 0, section: section)
        indexPaths.append(indexPath)
        
        let expanded = detailTableData[section].expanded
        detailTableData[section].expanded = !expanded
        
        button.setTitle(expanded ? sectionLabels[section] + " Open" : sectionLabels[section] + " Close", for: .normal)
        
        if expanded {
            tableView.deleteRows(at: indexPaths, with: .fade)
        } else {
            tableView.insertRows(at: indexPaths, with: .fade)
        }
    }
    
    func configure(dermatologist: Dermatologist) {
        self.dermatologist = dermatologist
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
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 36
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "NearbyDetailCell", for: indexPath) as? NearbyDetailCell else {
            fatalError("Dequeue cell error")
        }
        cell.textLabel?.text = detailTableData[indexPath.section].info
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = indexPath.section
        
        switch section {
            case 1: openMap()
            case 3: phoneCall()
            case 4: openBrowser(website: detailTableData[4].info)
            case 6:
                openBrowser(website: "http://www.google.com/search?q=\(dermatologist.title.replacingOccurrences(of: pattern, with: "%20", options: [.regularExpression]))")
            default:
                print("Default")
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.setSelected(false, animated: true)
    }

    @objc func openMap() {
        let latitude = dermatologist.location.coordinate.latitude
        let longitude = dermatologist.location.coordinate.longitude
        
        let appleURL = "http://maps.apple.com/?daddr=\(latitude),\(longitude)"
        let googleURL = "comgooglemaps://?daddr=\(latitude),\(longitude)&directionsmode=driving"
        let wazeURL = "waze://?ll=\(latitude),\(longitude)&navigate=yes"

        let googleItem = ("Google Maps", URL(string:googleURL)!)
        let wazeItem = ("Waze", URL(string:wazeURL)!)
        var installedNavigationApps = [("Apple Maps", URL(string:appleURL)!)]

        if UIApplication.shared.canOpenURL(googleItem.1) {
            installedNavigationApps.append(googleItem)
        }

        if UIApplication.shared.canOpenURL(wazeItem.1) {
            installedNavigationApps.append(wazeItem)
        }

        let alert = UIAlertController(title: "Selection", message: "Select Navigation App", preferredStyle: .actionSheet)
        for app in installedNavigationApps {
            let button = UIAlertAction(title: app.0, style: .default, handler: { _ in
                UIApplication.shared.open(app.1, options: [:], completionHandler: nil)
            })
            alert.addAction(button)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancel)
        present(alert, animated: true)
    }
    
    @objc func phoneCall() {
        let phoneNumber = detailTableData[3].info
        
        if phoneNumber != "N/A" {
            let phoneURL: NSURL = URL(string: "TEL://\(phoneNumber.filter("0123456789".contains))")! as NSURL
            UIApplication.shared.open(phoneURL as URL, options: [:], completionHandler: nil)
        }
        
    }
    
    @objc func openBrowser(website: String) {
        if website != "N/A" {
            if let url = URL(string: website) {
                UIApplication.shared.open(url)
            }
        }
    }

}


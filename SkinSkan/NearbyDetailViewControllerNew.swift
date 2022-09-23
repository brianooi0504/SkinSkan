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

struct CellDataNew {
    var expanded: Bool
    var info: String
}


class NearbyDetailViewControllerNew: UITableViewController {
    private var dermatologist: Dermatologist!
    private let sectionLabels = ["How to get there", "Services offered", "Operating hours", "Doctors available", "Contacts", "Rating"]
    private var detailTableData: [CellData]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        detailTableData = [CellData(expanded: true, info: dermatologist.address),
                           CellData(expanded: true, info: dermatologist.servicesOffered),
                           CellData(expanded: true, info: dermatologist.fullOpHrs),
                           CellData(expanded: true, info: dermatologist.doctors.joined(separator: ", ")),
                           CellData(expanded: true, info: dermatologist.contacts.joined(separator: ", ")),
                           CellData(expanded: true, info: String(dermatologist.rating))]

        tableView.reloadData()
        
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        let button = UIButton(type: .system)
        button.setTitle(sectionLabels[section] + " Close", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .yellow
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)

        button.addTarget(self, action: #selector(openMap), for: .touchUpInside)

        button.tag = section

        return button
    }

    @objc func handleExpand(button: UIButton) {
        print("Button pressed")
        
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
        self.title = dermatologist.title
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "NearbyDetailCell", for: indexPath) as? NearbyDetailCell else {
            fatalError("Dequeue cell error")
        }
        cell.textLabel?.text = detailTableData[indexPath.section].info
        return cell
    }

    
    @objc func openMap(button: UIButton) {
//        let address = detailTableData[0].info
//        var latitude: Double?
//        var longitude: Double?
//
//        let geoCoder = CLGeocoder()
//        geoCoder.geocodeAddressString(address) { (placemarks, error) in
//            let placemark = placemarks?.first
//            latitude = placemark?.location?.coordinate.latitude
//            longitude = placemark?.location?.coordinate.longitude
////            else {
//
////            }
//        }
        
        let latitude = 3.0672267
        let longitude = 101.603841
        print("Lat: \(latitude), Lon: \(longitude)")
        
        let appleURL = "http://maps.apple.com/?daddr=\(latitude),\(longitude)"
        let googleURL = "comgooglemaps://?daddr=\(latitude),\(longitude)&directionsmode=driving"
        let wazeURL = "waze://?ll=\(latitude),\(longitude)&navigate=false"

        let googleItem = ("Google Map", URL(string:googleURL)!)
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
    
    @objc func phoneCall(button: UIButton) {
        let phoneNumber = detailTableData[4].info
        
        let phoneURL: NSURL = URL(string: "TEL://\(phoneNumber)")! as NSURL
        UIApplication.shared.open(phoneURL as URL, options: [:], completionHandler: nil)
        
        
    }
    
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//      let region = regions[indexPath.row]
//
//      UIApplication.shared.open(region.phoneNumber.url) { success in
//        if success {
//          // ...
//        } else if let cell = tableView.cellForRow(at: indexPath) {
//          let menu = UIMenuController.shared
//          menu.setTargetRect(cell.frame, in: tableView)
//          menu.setMenuVisible(true, animated: true)
//        } else {
//          tableView.deselectRow(at: indexPath, animated: true)
//        }
//      }
//    }

}


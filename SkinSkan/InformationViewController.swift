//
//  InformationViewController.swift
//  SkinSkan
//
//  Created by Brian Ooi on 9/22/22.
//

import Foundation
import UIKit

class InformationViewController: UITableViewController {
    private var dermatologists: [Dermatologist] = []
    
    let derm1 = Dermatologist(title: "Clinic 1", hours: "0800 - 2000 hrs", fullOpHrs: "Mon-Sun 0800 - 2000hrs", distance: "200 metres", address: "5, Jalan Universiti, Bandar Sunway, 47500 Subang Jaya, Selangor", servicesOffered: "Consultation", doctors: ["Dr. Kumar", "Dr. Lee"], contacts: ["0123456789"], rating: 4.5)
    let derm2 = Dermatologist(title: "Clinic 2", hours: "1000 - 1800 hrs", fullOpHrs: "Mon-Sun 0800 - 2000hrs", distance: "500 metres", address: "5, Jalan Universiti, Bandar Sunway, 47500 Subang Jaya, Selangor", servicesOffered: "Consultation", doctors: ["Dr. Kumar", "Dr. Lee"],  contacts: ["0123456789"], rating: 4.5)
    let derm3 = Dermatologist(title: "Clinic 3", hours: "1000 - 2200 hrs", fullOpHrs: "Mon-Sun 0800 - 2000hrs", distance: "800 metres", address: "5, Jalan Universiti, Bandar Sunway, 47500 Subang Jaya, Selangor", servicesOffered: "Consultation", doctors: ["Dr. Kumar", "Dr. Lee"], contacts: ["0123456789"], rating: 4.5)
    let derm4 = Dermatologist(title: "Clinic 4", hours: "1000 - 1900 hrs", fullOpHrs: "Mon-Sun 0800 - 2000hrs", distance: "1.2 km", address: "5, Jalan Universiti, Bandar Sunway, 47500 Subang Jaya, Selangor", servicesOffered: "Consultation", doctors: ["Dr. Kumar", "Dr. Lee"], contacts: ["0123456789"], rating: 4.5)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dermatologists = [derm1, derm2, derm3, derm4]
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        let button = UIButton(type: .system)
        button.setTitle("Add new cell", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .gray
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        
        button.addTarget(self, action: #selector(handleExpand), for: .touchUpInside)
        
        button.tag = section //with the help of button.tag we keep track of which section header was clicked.

        return button
    }

    @objc func handleExpand(button: UIButton) {
        print("Button pressed")
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dermatologists.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "InformationCell", for: indexPath) as? InformationCell else {
            fatalError("Dequeue cell error")
        }
        cell.textLabel?.text = dermatologists[indexPath.section].title
        return cell
    }
    
}

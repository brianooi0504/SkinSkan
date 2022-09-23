//
//  NearbyViewController.swift
//  SkinSkan
//
//  Created by Brian Ooi on 9/23/22.
//

import Foundation
import UIKit

class NearbyViewController: UIViewController, UITableViewDataSource {
    @IBOutlet var dermatologistTableView: UITableView!
    private var dermatologists: [Dermatologist] = []
    
    let derm1 = Dermatologist(title: "Clinic 1", hours: "0800 - 2000 hrs", fullOpHrs: "Mon-Sun 0800 - 2000hrs", distance: "200 metres", address: "5, Jalan Universiti, Bandar Sunway, 47500 Subang Jaya, Selangor", servicesOffered: "Consultation", doctors: ["Dr. Kumar", "Dr. Lee"], contacts: ["0123456789"], rating: 4.5)
    let derm2 = Dermatologist(title: "Clinic 2", hours: "1000 - 1800 hrs", fullOpHrs: "Mon-Sun 0800 - 2000hrs", distance: "500 metres", address: "5, Jalan Universiti, Bandar Sunway, 47500 Subang Jaya, Selangor", servicesOffered: "Consultation", doctors: ["Dr. Kumar", "Dr. Lee"],  contacts: ["0123456789"], rating: 4.5)
    let derm3 = Dermatologist(title: "Clinic 3", hours: "1000 - 2200 hrs", fullOpHrs: "Mon-Sun 0800 - 2000hrs", distance: "800 metres", address: "5, Jalan Universiti, Bandar Sunway, 47500 Subang Jaya, Selangor", servicesOffered: "Consultation", doctors: ["Dr. Kumar", "Dr. Lee"], contacts: ["0123456789"], rating: 4.5)
    let derm4 = Dermatologist(title: "Clinic 4", hours: "1000 - 1900 hrs", fullOpHrs: "Mon-Sun 0800 - 2000hrs", distance: "1.2 km", address: "5, Jalan Universiti, Bandar Sunway, 47500 Subang Jaya, Selangor", servicesOffered: "Consultation", doctors: ["Dr. Kumar", "Dr. Lee"], contacts: ["0123456789"], rating: 4.5)

    override func viewDidLoad() {
        super.viewDidLoad()
        dermatologists = [derm1, derm2, derm3, derm4]
        dermatologistTableView.dataSource = self
        dermatologistTableView.rowHeight = 70
        dermatologistTableView.reloadData()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "NearbyCell", for: indexPath) as? NearbyCell else {
            fatalError("Dequeue cell error")
        }
        let currentDermatologist = dermatologists[indexPath.row]
        cell.configure(dermatologist: currentDermatologist)
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dermatologists.count
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "NearbySegue" {
            if let destination = segue.destination as? NearbyDetailViewController {
                destination.configure(dermatologist: dermatologists[dermatologistTableView.indexPathForSelectedRow!.row])
            }
        }

    }
}

//
//  InformationViewController.swift
//  SkinSkan
//
//  Created by Brian Ooi on 9/22/22.
//

import Foundation
import UIKit

class InformationViewController: UITableViewController {
    private var diseases: [Disease] =
    [Disease(name: "Eczema (Atopic Dermatitis)", desc: nil, symptom: nil, treatment: nil),
     Disease(name: "Contact Dermatitis", desc: nil, symptom: nil, treatment: nil),
    Disease(name: "Hives (Urticaria)", desc: nil, symptom: nil, treatment: nil),
    Disease(name: "Psoriasis", desc: nil, symptom: nil, treatment: nil),
    Disease(name: "Ringworm (Tinea Corporis)", desc: nil, symptom: nil, treatment: nil),
    Disease(name: "Herpes", desc: nil, symptom: nil, treatment: nil),
    Disease(name: "Vitiligo", desc: nil, symptom: nil, treatment: nil),
    Disease(name: "Lupus", desc: nil, symptom: nil, treatment: nil),
    Disease(name: "Scabies", desc: nil, symptom: nil, treatment: nil)]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return diseases.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "InformationCell", for: indexPath) as? InformationCell else {
            fatalError("Dequeue cell error")
        }
        cell.textLabel?.text = diseases[indexPath.row].name
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "InformationDetailSegue" {
            if let destination = segue.destination as? InformationDetailViewController {
                let selectedDisease: Disease = diseases[tableView.indexPathForSelectedRow!.row]
                destination.configure(disease: selectedDisease)
            }
        }
    }
    
}

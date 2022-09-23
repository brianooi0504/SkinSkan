//
//  NearbyDetailViewController.swift
//  SkinSkan
//
//  Created by Brian Ooi on 9/23/22.
//

import Foundation
import UIKit

struct CellData {
    var expanded: Bool
    var info: String
}

class TableHeader: UITableViewHeaderFooterView {
    static let identifier = "TableHeader"
    
    private let button: UIButton = {
        let button = UIButton()
        button.setTitle("Add new cell", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .gray
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)

//        button.addTarget(self, action: #selector(handleExpand), for: .touchUpInside)
        return button
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.text = "Select"
        label.font = .systemFont(ofSize: 22, weight: .semibold)
        label.textAlignment = .center
        
        return label
    }()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.sizeToFit()
        
    }
}

class NearbyDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private var dermatologist: Dermatologist!
    private let sectionLabels = ["How to get there", "Services offered", "Operating hours", "Doctors available", "Contacts", "Rating"]
    private var detailTableData: [CellData]!

    @IBOutlet var nearbyDetailImages: UIScrollView!
    @IBOutlet var nearbyDetailTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        detailTableData = [CellData(expanded: false, info: dermatologist.address),
                           CellData(expanded: false, info: dermatologist.servicesOffered),
                           CellData(expanded: false, info: dermatologist.fullOpHrs),
                           CellData(expanded: false, info: dermatologist.doctors.joined(separator: ", ")),
                           CellData(expanded: false, info: dermatologist.contacts.joined(separator: ", ")),
                           CellData(expanded: false, info: String(dermatologist.rating))]
        
        nearbyDetailTable.dataSource = self
        
        nearbyDetailTable.register(TableHeader.self, forHeaderFooterViewReuseIdentifier: "header")
        
//        nearbyDetailTable.rowHeight = 70
        nearbyDetailTable.reloadData()
    }
    
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//
//        let button = UIButton(type: .system)
//        button.setTitle("Add new cell", for: .normal)
//        button.setTitleColor(.black, for: .normal)
//        button.backgroundColor = .gray
//        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
//
//        button.addTarget(self, action: #selector(handleExpand), for: .touchUpInside)
//
//        button.tag = section //with the help of button.tag we keep track of which section header was clicked.
//
//        return button
//    }

    @objc func handleExpand(button: UIButton) {
        print("Button pressed")
    }
    
    func configure(dermatologist: Dermatologist) {
        self.dermatologist = dermatologist
        self.title = dermatologist.title
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return detailTableData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionLabels[section]
    }
    
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 36
//    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "NearbyDetailCell", for: indexPath) as? NearbyDetailCell else {
            fatalError("Dequeue cell error")
        }
        cell.textLabel?.text = detailTableData[indexPath.section].info
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header")
        return header
    }
//    func tableView(_ tableView: UITableView,
//         viewForHeaderInSection section: Int) -> UIView? {
//      return tableView.dequeueReusableHeaderFooterView(withIdentifier: String(describing: MyCustomHeaderView.self))
//    }
}


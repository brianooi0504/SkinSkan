//
//  NearbyDetailCell.swift
//  SkinSkan
//
//  Created by Brian Ooi on 9/23/22.
//

import Foundation
import UIKit

/// Struct used to store expanded/collapsed information about the TableView sections and the data for their rows
/// Used for TableViews in NearbyDetailTableViewController and InformationDetailTableViewController
struct DetailCellData {
    var expanded: Bool
    var info: String
}

/// TableViewCell class used in TableView of NearbyDetailTableViewController
class NearbyDetailCell: UITableViewCell {
}

/// TableViewCell class used in TableView of InformationViewController
class InformationCell: UITableViewCell {
}

/// TableViewCell class used in TableView of InformationDetailTableViewController
class InformationDetailCell: UITableViewCell {
}

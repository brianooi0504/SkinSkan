//
//  NearbyCell.swift
//  SkinSkan
//
//  Created by Brian Ooi on 9/22/22.
//

import Foundation
import UIKit

class NearbyCell: UITableViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var hoursLabel: UILabel!
    @IBOutlet var distanceLabel: UILabel!
    
    private var dermatologist: Dermatologist!
    
    func configure(dermatologist: Dermatologist) {
        titleLabel.text = dermatologist.title
        hoursLabel.text = dermatologist.hours
        distanceLabel.text = dermatologist.distance
    }
}

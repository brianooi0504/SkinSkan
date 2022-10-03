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
    @IBOutlet var distanceLabel: UILabel!
    @IBOutlet var ratingLabel: UILabel!
    @IBOutlet var openingLabel: UILabel!
    
    private var dermatologist: Dermatologist!
    
    func configure(dermatologist: Dermatologist) {
        titleLabel.text = dermatologist.title
        distanceLabel.text = dermatologist.distance
        ratingLabel.text = String(dermatologist.rating) + " ★"
        openingLabel.text = dermatologist.openNow
    }
}

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
        let distance = dermatologist.distance
        
        titleLabel.text = dermatologist.title
        ratingLabel.text = String(dermatologist.rating) + " ★"
        openingLabel.text = dermatologist.openNow
        
        if distance < 1000 {
            distanceLabel.text = String(format:"%d m", distance)
        } else {
            distanceLabel.text = String(format:"%.2f km", Double(distance)/1000)
        }
    }
}

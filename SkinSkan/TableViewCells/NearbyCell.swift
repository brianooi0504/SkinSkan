//
//  NearbyCell.swift
//  SkinSkan
//
//  Created by Brian Ooi on 9/22/22.
//

import Foundation
import UIKit

/// TableViewCell class used in TableView of NearbyViewController
class NearbyCell: UITableViewCell {
    /// References for labels for dermatologist name, rating, distance from current location, and opening status
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var distanceLabel: UILabel!
    @IBOutlet var ratingLabel: UILabel!
    @IBOutlet var openingLabel: UILabel!
    
    private var dermatologist: Dermatologist!
    
    /// Obtains dermatologist information from NearbyViewController and configures the cell
    func configure(dermatologist: Dermatologist) {
        let distance = dermatologist.distance
        
        titleLabel.text = dermatologist.title
        ratingLabel.text = String(dermatologist.rating) + " ★"
        openingLabel.text = dermatologist.openNow
        
        /// DIsplays distance in metres (m) if less than 1km, and kilometres (km) if more than 1km
        if distance < 1000 {
            distanceLabel.text = String(format:"%d m", distance)
        } else {
            distanceLabel.text = String(format:"%.2f km", Double(distance)/1000)
        }
    }
}

//
//  Prediction+CoreDataProperties.swift
//  SkinSkan
//
//  Created by Brian Ooi on 11/14/22.
//
//

import Foundation
import CoreData
import UIKit

/// Class generated by Core Data to store Prediction results into persistent storage
extension Prediction {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Prediction> {
        return NSFetchRequest<Prediction>(entityName: "Prediction")
    }

    @NSManaged public var confidences: [Double]
    @NSManaged public var datetime: Date
    @NSManaged public var image: UIImage
    @NSManaged public var results: [String]

}

extension Prediction : Identifiable {

}

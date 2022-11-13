//
//  Prediction+CoreDataProperties.swift
//  SkinSkan
//
//  Created by Brian Ooi on 11/13/22.
//
//

import Foundation
import CoreData
import UIKit


extension Prediction {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Prediction> {
        return NSFetchRequest<Prediction>(entityName: "Prediction")
    }

    @NSManaged public var confidences: [Double]
    @NSManaged public var datetime: Date
    @NSManaged public var id: UUID?
    @NSManaged public var image: UIImage
    @NSManaged public var results: [String]

}

extension Prediction : Identifiable {

}

@objc(NSAttributedStringTransformer)
class NSAttributedStringTransformer: NSSecureUnarchiveFromDataTransformer {
    override class var allowedTopLevelClasses: [AnyClass] {
        return super.allowedTopLevelClasses + [NSAttributedString.self]
    }
}

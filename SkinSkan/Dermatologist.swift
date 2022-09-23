//
//  Dermatologist.swift
//  SkinSkan
//
//  Created by Brian Ooi on 9/23/22.
//

import Foundation

struct Dermatologist: Codable {
    var title: String
    var hours: String
    var fullOpHrs: String
    var distance: String
    var address: String
    var servicesOffered: String
    var doctors: [String]
    var contacts: [String]
    var rating: Float
}

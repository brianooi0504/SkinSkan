//
//  Dermatologist.swift
//  SkinSkan
//
//  Created by Brian Ooi on 9/23/22.
//

import Foundation

class Dermatologist: Codable {
    var id: String
    var title: String
    var lat: Double
    var lng: Double
    var distance: String
    var rating: Double
    var hours: [String]? = []
    var openNow: String? = ""
    var address: String? = ""
    var contacts: String? = ""
    var website: String? = ""
    
    init(id: String, title: String, lat: Double, lng: Double, distance: String, rating: Double) {
        self.id = id
        self.title = title
        self.lat = lat
        self.lng = lng
        self.distance = distance
        self.rating = rating
    }
    
    func addInfo(hours: [String], openNow: String, address: String, contacts: String, website: String) {
        self.hours = hours
        self.openNow = openNow
        self.address = address
        self.contacts = contacts
        self.website = website
    }
}

struct DermResult: Codable {
    let results: [Result]
}

struct Result: Codable {
    let geometry: Geometry
    let icon: String
    let name: String
    let place_id: String
    let rating: Double
    let vicinity: String
}

struct Geometry: Codable {
    let location: Location
}

struct Location: Codable {
    let lat: Double
    let lng: Double
}

struct DermDetails: Codable {
    let result: DetailResult
}

struct DetailResult: Codable {
    let formatted_address: String?
    let formatted_phone_number: String?
    let opening_hours: Opening?
    let website: String?
}

struct Opening: Codable {
    let open_now: Bool?
    let weekday_text: [String]?
}

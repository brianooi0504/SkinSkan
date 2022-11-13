//
//  Dermatologist.swift
//  SkinSkan
//
//  Created by Brian Ooi on 9/23/22.
//

import Foundation
import CoreLocation
import UIKit

/// Class to store dermatologist information for the NearbyViewControllers
class Dermatologist {
    var id: String
    var title: String
    var location: CLLocation
    var distance: Int
    var rating: Double
    var number: Int = 0
    var hours: [String] = ["N/A"]
    var openNow: String = "-"
    var address: String = "N/A"
    var contacts: String = "N/A"
    var website: String = "N/A"
    var photos: [UIImage] = []
    
    /// Initialization information obtained using Google Nearby Search API
    init(id: String, title: String, location: CLLocation, distance: Int, rating: Double) {
        self.id = id
        self.title = title
        self.location = location
        self.distance = distance
        self.rating = rating
    }
    
    /// Adds in the optional information after more detailed data is obtained separately using Google Place Details API
    func addInfo(hours: [String], openNow: String, address: String, contacts: String, website: String) {
        self.hours = hours
        self.openNow = openNow
        self.address = address
        self.contacts = contacts
        self.website = website
    }
    
    /// Adds in the optional photos after images are obtained separately using Google Place Photos API
    func addPhotos(photo: UIImage) {
        self.photos.append(photo)
    }
}

// MARK: Codable Structs for Google Nearby Search API
/// Structs for dermatologist data to match structure of Google Nearby Search JSON API
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

// MARK: Codable Structs for Google Place Details API
/// Structs for detailed data to match structure of Google Place Details JSON API
struct DermDetails: Codable {
    let result: DetailResult
}

struct DetailResult: Codable {
    let formatted_address: String?
    let formatted_phone_number: String?
    let opening_hours: Opening?
    let photos: [Photo]?
    let website: String?
}

/// Photo references are saved so that images can be obtained afterwards with Google Place Photos JSON API
struct Photo: Codable {
    let photo_reference: String
}

struct Opening: Codable {
    let open_now: Bool?
    let weekday_text: [String]?
}

//
//  NearbyViewController.swift
//  SkinSkan
//
//  Created by Brian Ooi on 9/23/22.
//

import Foundation
import UIKit
import CoreLocation
import MapKit

/// View controller class for the nearby screen where nearby dermatologists are displayed
/// Third tab (index 2) for the root tab bar controller
class NearbyViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    // MARK: Variables
    private var dermatologists: [Dermatologist] = []
    /// API Key used in Google Nearby Search API, Google Place Details API, and Google Place Photos API
    private let apiKey = "AIzaSyBvgegzPAD8vdVz7qRcxONYlfOVHvWCU30x12345"
    /// CL Location Manager object used to store the user's current location
    var locationManager = CLLocationManager()
    private var currentLocation: CLLocation?
    /// Radius of region showed in the map view
    private var regionRadius: CLLocationDistance = 5000

    // MARK: IBOutlets
    /// References the TableView and the MapView
    @IBOutlet var dermatologistTableView: UITableView!
    @IBOutlet var nearbyMapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dermatologistTableView.dataSource = self
        dermatologistTableView.rowHeight = 80
        /// Reloads the TableView to display the updated dermatologist information
        dermatologistTableView.reloadData()

        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    // MARK: IBActions
    /// For the top right bar button item
    /// Resets the MapView to be centered around the user's current location
    @IBAction func reCenterLoc(_ sender: UIBarButtonItem) {
        /// Deselects the selected row in the TableView
        guard let selectedRow = dermatologistTableView.indexPathForSelectedRow else { return }
        dermatologistTableView.deselectRow(at: selectedRow, animated: true)
        if let currentLocation = currentLocation {
            setMapCenter(coordinates: currentLocation.coordinate, locName: "My Position", regionRadius: regionRadius)
        }
    }
    
    // MARK: TableViewDataSource Methods
    /// Sets number of sections in TableView (1)
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    /// Sets the number of rows in each TableView section according to number of dermatologists found
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dermatologists.count
    }
    
    /// Configures each TableViewCell as NearbyCell class instances using NearbyCell identifier
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "NearbyCell", for: indexPath) as? NearbyCell else {
            fatalError("Dequeue cell error")
        }
        let currentDermatologist = dermatologists[indexPath.row]
        cell.configure(dermatologist: currentDermatologist)
        cell.layer.cornerRadius = 8
        return cell
    }
    
    // MARK: TableViewDelegate Methods
    /// Shifts the MapView to be centered around the dermatologist location selected
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedDerm = dermatologists[indexPath.row]
        let selectedCoord = selectedDerm.location.coordinate
        
        setMapCenter(coordinates: selectedCoord, locName: selectedDerm.title, regionRadius: 1000)
    }
    
    // MARK: Self-Defined Functions
    /// Called to get all nearby dermatologists available using Google Nearby Places API
    func getNearbyData(url: URL?, currentLoc: CLLocation) {
        guard let url = url else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { [self] (data, response, error) in
            guard let data = data else {
                return
            }

            /// Decode the JSON file as DermResult instances
            do {
                let dermResult = try JSONDecoder().decode(DermResult.self, from: data)
                
                for result in dermResult.results {
                    let dermLoc = CLLocation(latitude: result.geometry.location.lat, longitude: result.geometry.location.lng)
                    let dermDistance = Int(currentLoc.distance(from: dermLoc))
                    
                    /// Create Dermatologist object with information obtained, including Place ID, name, coordinates, distance from current location, and Google ratings
                    let newDerm = Dermatologist(id: result.place_id, title: result.name, location: dermLoc, distance: dermDistance, rating: result.rating)
                    
                    /// Create a new annotation pin on the map at the coordinates that displays the title and ratings
                    let newMarker = MKPointAnnotation()
                    newMarker.coordinate = dermLoc.coordinate
                    newMarker.title = result.name
                    newMarker.subtitle = String(result.rating) + " ★"
                    nearbyMapView.addAnnotation(newMarker)
                    
                    /// Create URL to be used with Google Place Details API in the getDetailedData function
                    let detailSearchURL = "https://maps.googleapis.com/maps/api/place/details/json?fields=formatted_address%2Cformatted_phone_number%2Copening_hours%2cphotos%2Cwebsite&place_id=\(result.place_id)&key=\(self.apiKey)"
                    
                    self.getDetailedData(url: URL(string: detailSearchURL), derm: newDerm)

                    /// Append the Dermatologist object into the dermatologists array
                    self.dermatologists.append(newDerm)
                }
                
                /// Sort the dermatologists object by distance in ascending order
                self.dermatologists.sort(by: ({$0.distance < $1.distance}))
                
                /// Set the number attribute as the index location of the dermatologist in the dermatologists array
                for (i, derm) in self.dermatologists.enumerated() {
                    derm.number = i
                }
                
                /// Reloads the data of the TableView
                DispatchQueue.main.async {
                    self.dermatologistTableView.reloadData()
                }

            }
            catch {
                print("Error loading nearby data")
            }
        }.resume()
        
    }
    
    /// Called to get detailed information about each dermatologist using Google Place Details API
    func getDetailedData(url: URL?, derm: Dermatologist) {
        guard let url = url else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                return
            }
            
            /// Decode the JSON file as DermDetails instances
            do {
                let dermDetails = try JSONDecoder().decode(DermDetails.self, from: data)
                
                let dermDetailResult = dermDetails.result
                
                /// Format the opening status by defaulting to '-' and set to 'open' if the business is open at the moment and vice versa
                var openingNow = "-"
                
                if let available = dermDetailResult.opening_hours?.open_now {
                    available ? (openingNow = "Open") :  (openingNow = "Closed")
                }
                
                /// Calls the getImagefromURL method to obtain location images using the obtained photo reference links
                if let dermDetailResultPhotoRefs = dermDetailResult.photos {
                    for photoRef in dermDetailResultPhotoRefs {
                        /// Create a URL to be used with Google Place Photos API in the getImagefromURL function
                        let refString = photoRef.photo_reference
                        let photoURL = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photo_reference=\(refString)&key=\(self.apiKey)"
                        self.getImagefromURL(url: URL(string: photoURL), derm: derm)
                    }
                }
                
                /// Add the additional information into the Dermatologist object, including business hours, opening status, address, contact information, and website
                derm.addInfo(hours: dermDetailResult.opening_hours?.weekday_text ?? ["N/A"], openNow: openingNow, address: dermDetailResult.formatted_address ?? "N/A", contacts: dermDetailResult.formatted_phone_number ?? "N/A", website: dermDetailResult.website ?? "N/A")
            }
            catch {
                print("Error loading details for " + derm.title)
            }
        }.resume()
    }
    
    /// Called to get location images available using Google Place Photos API
    func getImagefromURL(url: URL?, derm: Dermatologist) {
        guard let url = url else {
            return
        }
        
        /// Decodee the obtained image file as UIImage instances
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                return
            }
            if let image = UIImage(data: data) {
                /// Add the images into the Dermatologist object
                derm.addPhotos(photo: image)
            } else {
                print("Error loading images for " + derm.title)
            }
        }.resume()
    }
    
    /// Method called when the annotation callout is pressed to display dermatologist details popup
    @objc func didClickDetailDisclosure(button: UIButton) {
        let tag = button.tag
        /// Instantiate a NearbyDetailViewController pop up
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "NearbyDetailViewController") as? NearbyDetailViewController else { return }
        /// Adds a top right Done bar button
        vc.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissPopUp))
        /// NearbyDetailViewController is configured with the selected Dermatologist object
        vc.configure(dermatologist: dermatologists[tag])
        
        let navController = UINavigationController(rootViewController: vc)
        present(navController, animated: true)
    }
    
    /// Method called to dismiss the dermatologist details pop up
    @objc func dismissPopUp() {
        self.dismiss(animated: true, completion: nil)
    }
    
    /// Method called to shift the map centred around the selected location
    func setMapCenter(coordinates: CLLocationCoordinate2D, locName: String, regionRadius: CLLocationDistance) {
        nearbyMapView.setCenter(coordinates, animated: true)
        
        /// Find the index of the annotations and display the callout for the annotation
        let annotationIndex = getAnnotationIndex(locName: locName, annotations: nearbyMapView.annotations)
        nearbyMapView.selectAnnotation(nearbyMapView.annotations[annotationIndex], animated: true)
        
        /// Set the map region to be centred around the selected location
        let coordinateRegion = MKCoordinateRegion(center: coordinates, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        nearbyMapView.setRegion(coordinateRegion, animated: true)
    }
    
    /// Method called to get the index location for the dermatologist in the dermatologists array
    func getButtonTag(dermName: String) -> Int {
        for derm in dermatologists {
            if derm.title == dermName {
                return derm.number
            }
        }
        
        return 0
    }
    
    /// Method called to get the index location of the annotation for the location in the annotations array
    func getAnnotationIndex(locName: String, annotations: [MKAnnotation]) -> Int {
        for i in 0 ..< annotations.count {
            if locName == annotations[i].title {
                return i
            }
        }
        
        return 0
    }
    
    /// Method called to get the notify users about missing location services permission and to prompt users to allow them
    func accessNeededAlert() {
        guard let settingsAppURL = URL(string: UIApplication.openSettingsURLString),
                UIApplication.shared.canOpenURL(settingsAppURL) else {
            assertionFailure("Unable to open App privacy settings")
            return
        }
        
        let alert = UIAlertController(
            title: "SkinSkan Would Like to Access your Location",
            message: "This app requires location services to obtain nearby dermatologists.",
            preferredStyle: UIAlertController.Style.alert
        )
        
        /// Opens the application setting in the device Settings app to let user change location services permission
        alert.addAction(UIAlertAction(title: "Allow Location", style: .default, handler: { (alert) -> Void in
            UIApplication.shared.open(settingsAppURL, options: [:], completionHandler: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
}

extension NearbyViewController: CLLocationManagerDelegate, MKMapViewDelegate {
    // MARK: CLLocationManagerDelegate Methods
    /// Method called after the user's current location has been obtained
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]
    ) {
        /// Stops updating the user location once a location has been obtained to improve loading performance
        while locations.count == 0 {
        }
        
        manager.stopUpdatingLocation()
        manager.delegate = nil
        
        /// getNearbyData method is called with the current location obtained to get information about nearby dermatologists
        if let location = locations.first {
            currentLocation = location
            
            /// Create URL to be used with Google Nearby Places API in the getNearbyData function
            let mapSearchURL = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?keyword=dermatologist&location=\( location.coordinate.latitude)%2C\(location.coordinate.longitude)&radius=\(String(regionRadius))&type=doctor&key=\(apiKey)"
            
            getNearbyData(url: URL(string: mapSearchURL), currentLoc: location)

            /// Create a map annotation for the user's current location and displays it
            let currentMarker = MKPointAnnotation()
            currentMarker.coordinate = location.coordinate
            currentMarker.title = "My Position"
            nearbyMapView.addAnnotation(currentMarker)
            
            /// Shifts the map to be centered around the user's current location
            setMapCenter(coordinates: location.coordinate, locName: "My Position", regionRadius: regionRadius)
            
        }
    }
    
    /// Method called if the user does not allow location services permissions
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error
    ) {
        /// If user denies location services permission, the accessNeededAlert method is called to prompt user to allow it
        switch manager.authorizationStatus {
        case .denied: accessNeededAlert()
        default: print("Location unavailable!")
        }
    }
    
    // MARK: MKMapViewDelegate Methods
    /// Method called to configure the annotations on the MapView
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        /// Set default variables
        let currentLocTitle = "My Position"
        var identifier = ""
        var tag = 9999
        
        /// Obtain the index location of the location in the dermatologists index if the location is a dermatologist
        if let title = annotation.title ?? nil {
            if title == currentLocTitle {
                identifier = "MyPosition"
            } else {
                tag = getButtonTag(dermName: title)
                identifier = String(tag)
            }
        }
        
        /// Add a button in the annotation so that users can click and view details of the dermatologists
        let placemarkButton = UIButton(type: .detailDisclosure)
        placemarkButton.addTarget(self, action: #selector(didClickDetailDisclosure), for: .touchUpInside)
        placemarkButton.tag = tag
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
            if annotation.title != currentLocTitle {
                annotationView?.rightCalloutAccessoryView = placemarkButton
            }
        } else {
            annotationView?.annotation = annotation
        }
        
        /// Sets the annotation pin image as a house icon for the user's current locations
        if annotation.title == currentLocTitle {
            annotationView?.image = UIImage(systemName: "house.circle.fill")?.withRenderingMode(.alwaysTemplate)
        }
        
        return annotationView
    }
}

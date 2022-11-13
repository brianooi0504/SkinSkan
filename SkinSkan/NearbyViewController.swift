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

class NearbyViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet var dermatologistTableView: UITableView!
    @IBOutlet var nearbyMapView: MKMapView!
    
    private var dermatologists: [Dermatologist] = []
    private let apiKey = "AIzaSyAeOgQKGWPLOJG8f_gxW6FTxktXiTsq92k"
    var locationManager = CLLocationManager()
    private var currentLocation: CLLocation?
    private var regionRadius: CLLocationDistance = 5000

    override func viewDidLoad() {
        super.viewDidLoad()
        dermatologistTableView.dataSource = self
        dermatologistTableView.rowHeight = 80
        dermatologistTableView.reloadData()

        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "NearbyCell", for: indexPath) as? NearbyCell else {
            fatalError("Dequeue cell error")
        }
        let currentDermatologist = dermatologists[indexPath.row]
        cell.configure(dermatologist: currentDermatologist)
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dermatologists.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedDerm = dermatologists[indexPath.row]
        let selectedCoord = selectedDerm.location.coordinate
        
        setMapCenter(coordinates: selectedCoord, locName: selectedDerm.title, regionRadius: 1000)
    }
    
    func getNearbyData(url: URL?, currentLoc: CLLocation) {
        guard let url = url else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { [self] (data, response, error) in
            guard let data = data else {
                return
            }

            do {
                let dermResult = try JSONDecoder().decode(DermResult.self, from: data)
                
                for result in dermResult.results {
                    let dermLoc = CLLocation(latitude: result.geometry.location.lat, longitude: result.geometry.location.lng)
                    let dermDistance = Int(currentLoc.distance(from: dermLoc))
                    
                    let newDerm = Dermatologist(id: result.place_id, title: result.name, location: dermLoc, distance: dermDistance, rating: result.rating)
                    
                    let newMarker = MKPointAnnotation()
                    newMarker.coordinate = dermLoc.coordinate
                    newMarker.title = result.name
                    newMarker.subtitle = String(result.rating) + " ★"
                    nearbyMapView.addAnnotation(newMarker)
                    
                    let detailSearchURL = "https://maps.googleapis.com/maps/api/place/details/json?fields=formatted_address%2Cformatted_phone_number%2Copening_hours%2cphotos%2Cwebsite&place_id=\(result.place_id)&key=\(self.apiKey)"
                    
                    self.getDetailedData(url: URL(string: detailSearchURL), derm: newDerm)

                    self.dermatologists.append(newDerm)
                }
                
                self.dermatologists.sort(by: ({$0.distance < $1.distance}))
                
                for (i, derm) in self.dermatologists.enumerated() {
                    derm.number = i
                }
                
                DispatchQueue.main.async {
                    self.dermatologistTableView.reloadData()
                }

            }
            catch {
                print("Error loading nearby data")
            }
        }.resume()
        
    }
    
    func getDetailedData(url: URL?, derm: Dermatologist) {
        guard let url = url else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                return
            }
            do {
                let dermDetails = try JSONDecoder().decode(DermDetails.self, from: data)
                
                let dermDetailResult = dermDetails.result
                
                var openingNow = "-"
                
                if let available = dermDetailResult.opening_hours?.open_now {
                    available ? (openingNow = "Open") :  (openingNow = "Closed")
                }
                
                if let dermDetailResultPhotoRefs = dermDetailResult.photos {
                    for photoRef in dermDetailResultPhotoRefs {
                        let refString = photoRef.photo_reference
                        let photoURL = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photo_reference=\(refString)&key=\(self.apiKey)"
                        self.getImagefromURL(url: URL(string: photoURL), derm: derm)
                    }
                }
                
                derm.addInfo(hours: dermDetailResult.opening_hours?.weekday_text ?? ["N/A"], openNow: openingNow, address: dermDetailResult.formatted_address ?? "N/A", contacts: dermDetailResult.formatted_phone_number ?? "N/A", website: dermDetailResult.website ?? "N/A")
            }
            catch {
                print("Error loading details for " + derm.title)
            }
        }.resume()
    }
    
    func getImagefromURL(url: URL?, derm: Dermatologist) {
        guard let url = url else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                return
            }
            if let image = UIImage(data: data) {
                derm.addPhotos(photo: image)
            } else {
                print("Error loading images for " + derm.title)
            }
        }.resume()
        
    }
}

extension NearbyViewController: CLLocationManagerDelegate, MKMapViewDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]
    ) {
        manager.stopUpdatingLocation()
        manager.delegate = nil
        
        if let location = locations.first {
            currentLocation = location
            
            let mapSearchURL = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?keyword=dermatologist&location=\( location.coordinate.latitude)%2C\(location.coordinate.longitude)&radius=\(String(regionRadius))&type=doctor&key=\(apiKey)"
            
            getNearbyData(url: URL(string: mapSearchURL), currentLoc: location)

            let currentMarker = MKPointAnnotation()
            currentMarker.coordinate = location.coordinate
            currentMarker.title = "My Position"
            nearbyMapView.addAnnotation(currentMarker)
            
            setMapCenter(coordinates: location.coordinate, locName: "My Position", regionRadius: regionRadius)
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error
    ) {
        print("Location unavailable!")
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let currentLocTitle = "My Position"
        var identifier = ""
        var tag = 9999
        
        if let title = annotation.title ?? nil {
            if title == currentLocTitle {
                identifier = "MyPosition"
            } else {
                tag = getButtonTag(dermName: title)
                identifier = String(tag)
            }
        }
        
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
        
        if annotation.title == currentLocTitle {
            annotationView?.image = UIImage(systemName: "house.circle.fill")?.withRenderingMode(.alwaysTemplate)
        }
        
        return annotationView
    }
    
    @objc func didClickDetailDisclosure(button: UIButton) {
        let tag = button.tag
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "NearbyDetailViewController") as? NearbyDetailViewController else { return }
        
        vc.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissPopUp))
        vc.configure(dermatologist: dermatologists[tag])
        
        let navController = UINavigationController(rootViewController: vc)
        present(navController, animated: true)
    }
    
    @objc func dismissPopUp() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func reCenterLoc(_ sender: UIBarButtonItem) {
        if let currentLocation = currentLocation {
            setMapCenter(coordinates: currentLocation.coordinate, locName: "My Position", regionRadius: regionRadius)
        }
    }
    
    func setMapCenter(coordinates: CLLocationCoordinate2D, locName: String, regionRadius: CLLocationDistance) {
        nearbyMapView.setCenter(coordinates, animated: true)
        
        let annotationIndex = getAnnotationIndex(locName: locName, annotations: nearbyMapView.annotations)
        nearbyMapView.selectAnnotation(nearbyMapView.annotations[annotationIndex], animated: true)
        
        let coordinateRegion = MKCoordinateRegion(center: coordinates, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        nearbyMapView.setRegion(coordinateRegion, animated: true)
    }
    
    func getButtonTag(dermName: String) -> Int {
        for derm in dermatologists {
            if derm.title == dermName {
                return derm.number
            }
        }
        
        return 0
    }
    
    func getAnnotationIndex(locName: String, annotations: [MKAnnotation]) -> Int {
        for i in 0 ..< annotations.count {
            if locName == annotations[i].title {
                return i
            }
        }
        
        return 0
    }
}

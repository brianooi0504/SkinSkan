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
    private var dermatologistTitles = [String: Int]()
    private var mapMarkers: [MKAnnotation] = []
    private var latitude: Double?
    private var longitude: Double?
    private let apiKey = "AIzaSyDK2NejXEQ3hQj-M627SpiqIHhrS-KvS-k"
    private var mapSearchURL: String!
    var locationManager = CLLocationManager()
    private var currentLocation: CLLocation!
    private var currentLocation2D: CLLocationCoordinate2D!
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
        let selectedLocation = CLLocationCoordinate2DMake(selectedDerm.lat, selectedDerm.lng)
        
        nearbyMapView.setCenter(selectedLocation, animated: true)
        
        let annotationIndex = getAnnotationIndex(dermName: selectedDerm.title, annotations: nearbyMapView.annotations)
        
        nearbyMapView.selectAnnotation(nearbyMapView.annotations[annotationIndex], animated: true)
        
        let coordinateRegion = MKCoordinateRegion(center: selectedLocation, latitudinalMeters: 1000, longitudinalMeters: 1000)
        nearbyMapView.setRegion(coordinateRegion, animated: true)
    }
    
    func getNearbyData(url: URL?) {
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
                    let lat = result.geometry.location.lat
                    let lng = result.geometry.location.lng
                    
                    let newDerm = Dermatologist(id: result.place_id, title: result.name, lat: lat, lng: lng, distance: getDistance(myLoc: currentLocation, locLat: lat, locLong: lng), rating: result.rating)
                    
                    let markerLocation = CLLocationCoordinate2DMake(CLLocationDegrees(result.geometry.location.lat), CLLocationDegrees(result.geometry.location.lng))
                    let newMarker = MKPointAnnotation()
                    newMarker.coordinate = markerLocation
                    newMarker.title = result.name
                    newMarker.subtitle = String(result.rating) + " ★"
                    nearbyMapView.addAnnotation(newMarker)
                    
                    self.getDetailedData(url: URL(string: "https://maps.googleapis.com/maps/api/place/details/json?fields=formatted_address%2Cformatted_phone_number%2Copening_hours%2Cwebsite&place_id=\(result.place_id)&key=\(self.apiKey)"), derm: newDerm)

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
                print("Error loading data")
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
                
                derm.addInfo(hours: dermDetailResult.opening_hours?.weekday_text ?? ["N/A"], openNow: openingNow, address: dermDetailResult.formatted_address ?? "N/A", contacts: dermDetailResult.formatted_phone_number ?? "N/A", website: dermDetailResult.website ?? "N/A")
            }
            catch {
                print("Error loading details for " + derm.title)
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
            latitude = Double(location.coordinate.latitude)
            longitude = Double(location.coordinate.longitude)
            currentLocation = CLLocation(latitude: latitude!, longitude: longitude!)
            currentLocation2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
            
            mapSearchURL = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?keyword=dermatologist&location=\( String(latitude!))%2C\(String(longitude!))&radius=\(String(regionRadius))&type=doctor&key=\(apiKey)"
            
//            mapSearchURL = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?keyword=dermatologist&location=\( String(latitude!))%2C\(String(longitude!))&rankby=distance&type=doctor&key=\(apiKey)"
            
            getNearbyData(url: URL(string: mapSearchURL))

            
            let currentMarker = MKPointAnnotation()
            currentMarker.coordinate = currentLocation2D
            currentMarker.title = "My Position"
            nearbyMapView.addAnnotation(currentMarker)
            
            nearbyMapView.setCenter(currentLocation2D, animated: true)
            
            nearbyMapView.showAnnotations(mapMarkers, animated: true)
            
            let annotationIndex = getAnnotationIndex(dermName: "My Position", annotations: nearbyMapView.annotations)
            nearbyMapView.selectAnnotation(nearbyMapView.annotations[annotationIndex], animated: true)
            
            let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
            nearbyMapView.setRegion(coordinateRegion, animated: true)
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error
    ) {
        print("Location unavailable!")
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var identifier = ""
        var tag = 9999
        
        if annotation.title == "My Position" {
            identifier = "MyPosition"
        } else {
            tag = getButtonTag(dermName: annotation.title!!)
            identifier = String(tag)
        }
        
        let placemarkButton = UIButton(type: .detailDisclosure)
        placemarkButton.addTarget(self, action: #selector(didClickDetailDisclosure), for: .touchUpInside)
        placemarkButton.tag = tag
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
            if annotation.title != "My Position" {
                annotationView?.rightCalloutAccessoryView = placemarkButton
            }
        } else {
            annotationView?.annotation = annotation
        }
        
        if annotation.title == "My Position" {
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
        nearbyMapView.setCenter(currentLocation2D, animated: true)
        
        let annotationIndex = getAnnotationIndex(dermName: "My Position", annotations: nearbyMapView.annotations)
        nearbyMapView.selectAnnotation(nearbyMapView.annotations[annotationIndex], animated: true)
    }
    
    func getButtonTag(dermName: String) -> Int {
        for derm in dermatologists {
            if derm.title == dermName {
                return derm.number!
            }
        }
        
        return 0
    }
    
    func getAnnotationIndex(dermName: String, annotations: [MKAnnotation]) -> Int {
        for i in 0 ..< annotations.count {
            if dermName == annotations[i].title {
                return i
            }
        }
        
        return 0
    }
    
    func getDistance(myLoc: CLLocation, locLat: Double, locLong: Double) -> Int {
        let loc = CLLocation(latitude: locLat, longitude: locLong)
        let distance = myLoc.distance(from: loc)
        
        return Int(distance)
    }
}

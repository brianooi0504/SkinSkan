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

class NearbyViewController: UIViewController, UITableViewDataSource, CLLocationManagerDelegate, MKMapViewDelegate {
    @IBOutlet var dermatologistTableView: UITableView!
    @IBOutlet var nearbyMapView: MKMapView!
    
    private var dermatologists: [Dermatologist] = []
    private var mapMarkers: [MKAnnotation] = []
    private var latitude: String?
    private var longitude: String?
    private let apiKey = "AIzaSyAzCXzhBaejzCR6DWSHOuWhQa0DeM-acWk"
    private var mapSearchURL: String?
    var locationManager = CLLocationManager()
    private var regionRadius: CLLocationDistance = 5000

    override func viewDidLoad() {
        super.viewDidLoad()
        dermatologistTableView.dataSource = self
        dermatologistTableView.rowHeight = 80
        dermatologistTableView.reloadData()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]
    ) {
        if let location = locations.first {
            let latDouble = Double(location.coordinate.latitude)
            let longDouble = Double(location.coordinate.longitude)
            latitude = String(latDouble)
            longitude = String(longDouble)
            
            mapSearchURL = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?keyword=dermatologist&location=\( latitude!)%2C\(longitude!)&radius=\(String(regionRadius))&type=doctor&key=\(apiKey)"
            
            getNearbyData(url: URL(string: mapSearchURL!))
            
            let currentLocation = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
//            let currentMarker = MKPointAnnotation()
//            currentMarker.coordinate = currentLocation
//            currentMarker.title = "My Position"
//            nearbyMapView.addAnnotation(currentMarker)
            
            nearbyMapView.setCenter(currentLocation, animated: true)
            
            nearbyMapView.showAnnotations(mapMarkers, animated: true)
            
            let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
            nearbyMapView.setRegion(coordinateRegion, animated: true)
            
            manager.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error
    ) {
        print("Location unavailable!")
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
                
                for (i, result) in dermResult.results.enumerated() {
                    let newDerm = Dermatologist(id: result.place_id, title: result.name, lat: result.geometry.location.lat, lng: result.geometry.location.lng, distance: result.name, rating: result.rating)
                    
                    let markerLocation = CLLocationCoordinate2DMake(CLLocationDegrees(result.geometry.location.lat), CLLocationDegrees(result.geometry.location.lng))
                    let newMarker = MKPointAnnotation()
                    newMarker.coordinate = markerLocation
                    newMarker.title = String(i) + "-" + result.name
                    newMarker.subtitle = String(result.rating)
                    nearbyMapView.addAnnotation(newMarker)
                    
                    self.getDetailedData(url: URL(string: "https://maps.googleapis.com/maps/api/place/details/json?fields=formatted_address%2Cformatted_phone_number%2Copening_hours%2Cwebsite&place_id=\(result.place_id)&key=\(self.apiKey)"), derm: newDerm)

                    self.dermatologists.append(newDerm)
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
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "Placemark"
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        let placemarkButton = UIButton(type: .detailDisclosure)
        placemarkButton.addTarget(self, action: #selector(didClickDetailDisclosure), for: .touchUpInside)
        if let name = annotation.title {
            let buttonID = name!.components(separatedBy: "-")[0]
            print(buttonID)
            placemarkButton.tag = Int(buttonID)!
        }
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
            annotationView?.rightCalloutAccessoryView = placemarkButton
        } else {
            annotationView?.annotation = annotation
        }
        
        return annotationView
    }
    
    @objc func didClickDetailDisclosure(button: UIButton) {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "NearbyDetailViewController") as? NearbyDetailViewController else { return }
        
        vc.configure(dermatologist: dermatologists[button.tag])
        present(vc, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "NearbyDetailSegue" {
            if let destination = segue.destination as? NearbyDetailViewController {
                let currentRow = dermatologistTableView.indexPathForSelectedRow!.row
                let selectedDerm: Dermatologist = dermatologists[currentRow]
                destination.configure(dermatologist: selectedDerm)
            }
        }
    }

}

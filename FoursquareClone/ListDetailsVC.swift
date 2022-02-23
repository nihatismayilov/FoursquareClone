//
//  ListDetailsVC.swift
//  FoursquareClone
//
//  Created by Nihad Ismayilov on 18.02.22.
//

import UIKit
import MapKit
import CoreLocation
import Firebase
import SDWebImage

class ListDetailsVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var placeNameLabel: UILabel!
    @IBOutlet weak var placeTypeLabel: UILabel!
    @IBOutlet weak var placeAtmosphereLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    var chosenLatitude = Double()
    var chosenLongitude = Double()
    
    var chosenPlaceId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        getData()
        
    }
    
    func getData() {
        let firestoreDatabase = Firestore.firestore()
        
        firestoreDatabase.collection("Places").addSnapshotListener { snapshot, error in
            if error != nil {
                print(error?.localizedDescription)
            } else {
                
                if snapshot?.isEmpty != true && snapshot != nil {
                    
                    for document in snapshot!.documents {
                        let documentId = document.documentID
                        
                        if documentId == self.chosenPlaceId {
                            if let placeName = document.get("placeName") as? String {
                                self.placeNameLabel.text = placeName
                            }
                            if let placeType = document.get("placeType") as? String {
                                self.placeTypeLabel.text = placeType
                            }
                            if let placeAtmosphere = document.get("placeAtmosphere") as? String {
                                self.placeAtmosphereLabel.text = placeAtmosphere
                            }
                            if let placeImageUrl = document.get("imageUrl") as? String {
                                self.imageView.sd_setImage(with: URL(string: placeImageUrl))
                            }
                            if let placeLatitude = document.get("latitude") as? Double {
                                self.chosenLatitude = placeLatitude
                            }
                            if let placeLongitude = document.get("longitude") as? Double {
                                self.chosenLongitude = placeLongitude
                            }
                            
                            let location = CLLocationCoordinate2D(latitude: self.chosenLatitude, longitude: self.chosenLongitude)
                            let span = MKCoordinateSpan(latitudeDelta: 0.035, longitudeDelta: 0.035)
                            let region = MKCoordinateRegion(center: location, span: span)
                            self.mapView.setRegion(region, animated: true)
                            
                            let annotation = MKPointAnnotation()
                            annotation.coordinate = location
                            annotation.title = self.placeNameLabel.text
                            annotation.subtitle = self.placeTypeLabel.text
                            self.mapView.addAnnotation(annotation)
                            
                        }
                    }
                }
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        }
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.canShowCallout = true
            let button = UIButton(type: .detailDisclosure)
            pinView?.rightCalloutAccessoryView = button
        } else {
            pinView?.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if self.chosenLatitude != 0.0 && self.chosenLongitude != 0.0 {
            
            let requestLocation = CLLocation(latitude: self.chosenLatitude, longitude: self.chosenLongitude)
            
            CLGeocoder().reverseGeocodeLocation(requestLocation) { placemarks, error in
                
                if let placemark = placemarks {
                    
                    if placemark.count > 0 {
                        
                        let mkPlaceMark = MKPlacemark(placemark: placemark[0])
                        let mapItem = MKMapItem(placemark: mkPlaceMark)
                        mapItem.name = self.placeNameLabel.text
                        
                        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
                        
                        mapItem.openInMaps(launchOptions: launchOptions)
                    }
                }
                
            }
            
        }
        
    }
    
}

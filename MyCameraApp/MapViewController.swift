//
//  MapViewController.swift
//  MyCameraApp
//
//  Created by Afam Ezechukwu on 02/01/2018.
//  Copyright © 2018 The Gypsy. All rights reserved.
//

import UIKit
import MapKit
import Photos
import CoreLocation

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    var imageFetchResult = PHFetchResult<PHAsset>()
    var annotationPHAssests = [PHAsset]()
    var locationManager = CLLocationManager()
    var photoAnnotations = [ImageAnnotation]()
    var photoDictionary = [CLLocationCoordinate2D: [MKAnnotation]]()
    var subtitleDictionary = [CLLocationCoordinate2D: String]()

    @IBOutlet var mapView: MKMapView!
    
    @IBAction func mapSegmentControl(_ sender: UISegmentedControl) {
        mapView.mapType = MKMapType.init(rawValue: UInt(sender.selectedSegmentIndex)) ?? .standard
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if imageFetchResult.count > 0 {
            for annotation in mapView.annotations {
                mapView.removeAnnotation(annotation)
            }
            
            populateMap()
        }
        
    }
    
    @objc func appMovedToForeground() {
        if imageFetchResult.count > 0 {
            for annotation in mapView.annotations {
                mapView.removeAnnotation(annotation)
            }
            
            populateMap()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.mapView.delegate = self
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        let userLocation = locationManager.location?.coordinate
        let newRegion = MKCoordinateRegionMake(userLocation!, MKCoordinateSpanMake(0.05, 0.05))
        
        self.mapView!.setRegion(newRegion, animated: true)
        
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToForeground), name: Notification.Name.UIApplicationWillEnterForeground, object: nil)
        
        for annotation in mapView.annotations {
            mapView.removeAnnotation(annotation)
        }
        
        populateMap()
        
    }
    
    func populateMap(){
        DispatchQueue.global(qos: .background).async {
            self.photoAnnotations = []
            let phImageRequestOptions = PHImageRequestOptions()
            phImageRequestOptions.isSynchronous = true
            phImageRequestOptions.deliveryMode = .highQualityFormat
            
            let phFetchOptions = PHFetchOptions()
            phFetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: true)]
            
            let phFetchResult: PHFetchResult = PHAsset.fetchAssets(with: .image, options: phFetchOptions)
            print(phFetchResult)
            print(phFetchResult.count)
            self.imageFetchResult = phFetchResult
            if phFetchResult.count > 0 {
                for i in 0..<phFetchResult.count {
                    if phFetchResult[i].location != nil {
                        let pictureCoordinate = phFetchResult[i].location?.coordinate
                        
                        let latitude = Double((pictureCoordinate?.latitude)!)
                        let longitude = Double((pictureCoordinate?.longitude)!)
                        
                        let roundLat = Double(round(1000*latitude)/1000)
                        let roundLon = Double(round(100*longitude)/100)
                        
                        let annotation = ImageAnnotation()
                        let annotationCoordinate = CLLocationCoordinate2DMake(roundLat, roundLon)
                        annotation.coordinate = annotationCoordinate
                        
                        annotation.phAsset = phFetchResult[i]
                        
                        self.mapView.addAnnotation(annotation)
                    }
                }
                let annotations = self.mapView.annotations as! [ImageAnnotation]
                var coordinateToAnnotations = [CLLocationCoordinate2D: [ImageAnnotation]]()
                for annotation in annotations {
                    let coordinate = annotation.coordinate
                    let annotationsAtCoordinate = coordinateToAnnotations[coordinate] ?? [ImageAnnotation]()
                    coordinateToAnnotations[coordinate] = annotationsAtCoordinate + [annotation]
                }
                self.mapView.removeAnnotations(annotations)
                self.photoDictionary = coordinateToAnnotations
                for coordinate in coordinateToAnnotations{
                    print(coordinate.value.count)
                    let annotation = ImageAnnotation()
                    let annotationCoordinate = coordinate.key
                    annotation.coordinate = annotationCoordinate
                    if coordinate.value.count == 1 {
                        annotation.title = "\(coordinate.value.count) Photo"
                    } else {
                        annotation.title = "\(coordinate.value.count) Photos"
                    }
                    let location = CLLocation(latitude: annotationCoordinate.latitude, longitude: annotationCoordinate.longitude)
                    print(location)
                    let geocoder = CLGeocoder()
                    geocoder.reverseGeocodeLocation(location) {placemarks, error in
                        if placemarks?.count ?? 0 > 0 {
                            let placemark = placemarks![0]
                            annotation.subtitle = "At \(self.stringForPlacemark(placemark))"
                            self.subtitleDictionary[annotationCoordinate] = annotation.subtitle
                            print(annotation.subtitle!)
                        }
                    }
                    self.photoAnnotations.append(annotation)
                }
            } else {
                print("You got no photos.")
                if PHPhotoLibrary.authorizationStatus() != PHAuthorizationStatus.denied{
                    print("not denied")
                    self.populateMap()
                } else {
                    print("denied")
                }
            }
            
            DispatchQueue.main.async {
                self.mapView.addAnnotations(self.photoAnnotations)
                self.photoAnnotations = []
            }
        }
    }
    
    func stringForPlacemark(_ placemark: CLPlacemark) -> String {
        
        var string = ""
        
        if placemark.locality != nil {
            string += placemark.locality!
            print("subLocality is \(string)")
        }
        
        if placemark.subLocality != nil {
            if !string.isEmpty {
                string += " - "
            }
            string += placemark.subLocality!
            print("locality is \(string)")
        }
        
        if string.isEmpty && placemark.name != nil {
            string += placemark.name!
        }
        
        return string
    }
    
    func mapView(_ aMapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let annotationIdentifier = "Photo"
        
        if aMapView != self.mapView {
            return nil
        }
        
        if annotation is ImageAnnotation {
            var annotationView = self.mapView!.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) as! MKPinAnnotationView?
            if annotationView == nil {
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            }
            
            annotationView!.canShowCallout = true
            
            let disclosureButton = UIButton(type: .detailDisclosure)
            annotationView!.rightCalloutAccessoryView = disclosureButton
            
            return annotationView
        }
        
        return nil
    }
    
    //MARK: prepareForSegue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PhotoMapDetails" {
            let page = segue.destination as! MapPageViewController
            page.index = 0
            page.phAssets = self.annotationPHAssests
        }
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        self.annotationPHAssests = []
        let imageAnnotation = view.annotation as! ImageAnnotation
        for coordinate in photoDictionary {
            if coordinate.key == imageAnnotation.coordinate {
                print("Tapped")
                for annotation in coordinate.value {
                    let assetAnnotation = annotation as! ImageAnnotation
                    self.annotationPHAssests.append(assetAnnotation.phAsset!)
                }
            }
        }
        performSegue(withIdentifier: "PhotoMapDetails", sender: self)
        print(self.annotationPHAssests.count)
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if view.annotation is ImageAnnotation {
            let annotation = view.annotation as! ImageAnnotation
            
                if annotation.subtitle == nil {
                    print("title is '\(String(describing: annotation.subtitle))' ")
                    
                    annotation.subtitle = self.subtitleDictionary[CLLocationCoordinate2DMake(annotation.coordinate.latitude, annotation.coordinate.longitude)]
                }
            
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
extension CLLocationCoordinate2D: Hashable {
    public static func ==(lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
    
    public var hashValue: Int {
        get {
            return (latitude.hashValue&*397) &+ longitude.hashValue;
        }
    }
}

//
//  ImageDetailsViewController.swift
//  MyCameraApp
//
//  Created by Afam Ezechukwu on 24/12/2017.
//  Copyright © 2017 The Gypsy. All rights reserved.
//

import UIKit
import MapKit
import Photos

class ImageDetailsViewController: UIViewController {
    
    @IBAction func closeButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet var descriptionTextView: UITextView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var mapLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    var phAsset: PHAsset?
    var index: Int!
    var imageFetchResult = PHFetchResult<PHAsset>()
    var dictionary = Dictionary<String, String>()
    var descriptionDictionary = Dictionary<String, String>()
    
    @IBAction func unwindToDetails(sender: UIStoryboardSegue) {
        print("Saved")
        if let source = sender.source as? EditDetailsViewController{
            if !(source.text.isEmpty) {
                dictionary[(self.phAsset?.originalFilename)!] = source.text
                UserDefaults.standard.set(dictionary, forKey: "dictionary")
            }
            
            if !(source.imageDescription.isEmpty){
                descriptionDictionary[(self.phAsset?.originalFilename)!] = source.imageDescription
                UserDefaults.standard.set(descriptionDictionary, forKey: "descriptionDictionary")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dictionary = Dictionary<String, String>(minimumCapacity: imageFetchResult.count)
        descriptionDictionary = Dictionary<String, String>(minimumCapacity: imageFetchResult.count)
        
        let date = DateFormatter()
        date.dateFormat = "EEEE d MMMM yyyy"
        let dateLabel = date.string(from: (self.phAsset?.creationDate!)!)
        label.text = dateLabel
        
        if self.phAsset?.location != nil {
            let latitude = Double((self.phAsset?.location?.coordinate.latitude)!)
            let longitude = Double((self.phAsset?.location?.coordinate.longitude)!)
            let latDelta: CLLocationDegrees = 0.02
            let longDelta: CLLocationDegrees = 0.02
            let span: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: longDelta)
            let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let region: MKCoordinateRegion = MKCoordinateRegion(center: location, span: span)
            
            mapView.setRegion(region, animated: true)
            
            let annotation = MKPointAnnotation()
            annotation.title = ""
            annotation.subtitle = ""
            annotation.coordinate = location
            
            mapView.addAnnotation(annotation)
        } else {
            mapView.isHidden = true
            mapLabel.text = "No Location Found"
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let tempDict = UserDefaults.standard.object(forKey: "dictionary") as? Dictionary<String, String> {
            dictionary = tempDict
            print("Dictionary Index \(tempDict)")
            if dictionary[(self.phAsset?.originalFilename)!] == nil {
                titleLabel.text = self.phAsset?.originalFilename
            } else {
                titleLabel.text = dictionary[(self.phAsset?.originalFilename)!]
            }
        } else {
            titleLabel.text = self.phAsset?.originalFilename
        }
        if let tempImageDict = UserDefaults.standard.object(forKey: "descriptionDictionary") as? Dictionary<String, String> {
            descriptionDictionary = tempImageDict
            print("DescriptionDictionary Index \(tempImageDict)")
            if descriptionDictionary[(self.phAsset?.originalFilename)!] == nil {
                descriptionTextView.text = "Add a Description"
            } else {
                descriptionTextView.text = descriptionDictionary[(self.phAsset?.originalFilename)!]
            }
        }
    }
    
    //MARK: prepareForSegue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditDetail" {
            let editPage = segue.destination as! EditDetailsViewController
            editPage.index = self.index
            editPage.imageFetchResult = self.imageFetchResult
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

extension PHAsset {
    
    var originalFilename: String? {
        
        var fileName:String?
            
            
        let resources = PHAssetResource.assetResources(for: self)
        if let resource = resources.first {
            fileName = resource.originalFilename
        }
            
        if fileName == nil {
            fileName = self.value(forKey: "filename") as? String
        }
            
        return fileName
        
    }
}



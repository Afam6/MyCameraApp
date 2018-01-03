//
//  PreviewViewController.swift
//  MyCameraApp
//
//  Created by Afam Ezechukwu on 02/01/2018.
//  Copyright © 2018 The Gypsy. All rights reserved.
//

import UIKit
import Photos
import CoreLocation

class PreviewViewController: UIViewController, CLLocationManagerDelegate {
    
    var image: UIImage!
    var locationManager = CLLocationManager()

    @IBAction func cancelButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButton(_ sender: Any) {
        if PHPhotoLibrary.authorizationStatus() == .authorized {
            saveImage(image: image, location: locationManager.location)
            dismiss(animated: true, completion: nil)
        } else {
            PHPhotoLibrary.requestAuthorization({ (status) in
                if status == .authorized {
                    self.saveImage(image: self.image, location: self.locationManager.location)
                    self.dismiss(animated: true, completion: nil)
                } else {
                    self.dismiss(animated: true, completion: nil)
                }
            })
        }
        
    }
    
    @IBOutlet var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = self.image
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func saveImage(image: UIImage, location: CLLocation? = nil) {
        PHPhotoLibrary.shared().performChanges({
            let phAsset = PHAssetChangeRequest.creationRequestForAsset(from: image)
            if let location = location {
                phAsset.location = location
            }
        }, completionHandler: { success, error in
            if !success { NSLog("error creating asset: \(String(describing: error))") }
        })
    }

}

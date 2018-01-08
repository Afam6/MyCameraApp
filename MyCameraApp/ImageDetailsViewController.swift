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
    @IBAction func uploadToServer(_ sender: Any) {
        myImageUploadRequest()
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
    var image: UIImage?
    
    func myImageUploadRequest() {
        let myURL = URL(string: "http://143.167.194.13:8091/uploadPicture")
        var request = URLRequest(url: myURL!)
        request.httpMethod = "POST"
        let param = [
            "title" : self.titleLabel.text!,
            "description" : self.descriptionTextView.text!,
            "longitiude" : self.phAsset?.location?.coordinate.longitude as Any,
            "latitude" : self.phAsset?.location?.coordinate.latitude as Any,
            "dateTaken" : self.phAsset?.creationDate as Any
            ] as [String : Any]
        let boundary = generateBoundaryString()
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        var imageData: NSData? = nil
        PHImageManager.default().requestImage(for: self.phAsset!, targetSize: CGSize(width:500, height: 500), contentMode: .aspectFill, options: nil, resultHandler: {(result, info) in
            
            self.image = result
            
        })
        imageData = UIImagePNGRepresentation(self.image!) as NSData?
        if imageData == nil { return }
        request.httpBody = createBodyWithParameters(parameters: param, filePathKey: "filename", imageDataKey: imageData! as NSData, boundary: boundary) as Data
        let task = URLSession.shared.uploadTask(with: request, from: imageData! as Data){data, response, error in
            if error != nil {
                print("error=\(String(describing: error))")
                return
            }
            // You can print out response object
            print("******* response = \(String(describing: response))")
            
            // Print out response body
            let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            print("****** response data = \(responseString!)")
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary
                
                print("JSON \(json!)")
                
            }catch
            {
                print("JSON ERROR \(error)")
            }
            
        }
        
        task.resume()
        
    }
    
    func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }
    
    func createBodyWithParameters(parameters: [String: Any]?, filePathKey: String?, imageDataKey: NSData, boundary: String) -> NSData {
        let body = NSMutableData();
        
        if parameters != nil {
            for (key, value) in parameters! {
                body.appendString(string: "--\(boundary)\r\n")
                body.appendString(string: "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.appendString(string: "\(value)\r\n")
            }
        }
        
        
        let mimetype = "image/png"
        
        body.appendString(string: "--\(boundary)\r\n")
        body.appendString(string: "Content-Disposition: form-data; name=\"\(filePathKey!)\"; \"\r\n")
        body.appendString(string: "Content-Type: \(mimetype)\r\n\r\n")
        body.append(imageDataKey as Data)
        body.appendString(string: "\r\n")
        
        
        
        body.appendString(string: "--\(boundary)--\r\n")
        
        return body
    }
    
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

extension NSMutableData {
    
    func appendString(string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
        append(data!)
    }
}


//
//  ImageAnnotation.swift
//  MyCameraApp
//
//  Created by Afam Ezechukwu on 02/01/2018.
//  Copyright © 2018 The Gypsy. All rights reserved.
//

import Foundation
import MapKit
import CoreLocation
import Photos

public class ImageAnnotation: NSObject, MKAnnotation {
    public var coordinate = CLLocationCoordinate2D(latitude: 0, longitude:0)
    public var title: String? = "cluster"
    public var subtitle: String?
    var phAsset: PHAsset?
}

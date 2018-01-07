//
//  ImageViewController.swift
//  MyCameraApp
//
//  Created by Afam Ezechukwu on 19/12/2017.
//  Copyright © 2017 The Gypsy. All rights reserved.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass
import Photos
import MapKit

class ImageViewController: UIViewController, UIScrollViewDelegate {
    
    var tap = UIShortTapGestureRecognizer()
    var doubleTap = UITapGestureRecognizer()

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    var phAsset: PHAsset?
    var index: Int!
    var imageFetchResult = PHFetchResult<PHAsset>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isToolbarHidden = (self.navigationController?.isNavigationBarHidden)!
        self.navigationController?.toolbar.barTintColor = UIColor(red: 89.0/255, green: 206.0/255, blue: 134.0/255, alpha: 0.3)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("view will appear ...")
        print((self.navigationController?.toolbar.items?.first)!)
        self.navigationController?.toolbar.items?.first?.target = self
        self.navigationController?.toolbar.items?.first?.action = #selector(shareImage)
        
        print((self.navigationController?.toolbar.items?[2])!)
        self.navigationController?.toolbar.items?[2].target = self
        self.navigationController?.toolbar.items?[2].action = #selector(showDetails)
        
        PHImageManager.default().requestImage(for: phAsset!, targetSize: CGSize(width:500, height: 500), contentMode: .aspectFill, options: nil, resultHandler: {(result, info) in
            
            self.imageView.image = result
            
            
        })
        
        self.scrollView.minimumZoomScale = 1.0
        self.scrollView.maximumZoomScale = 6.0
        
        tap.numberOfTapsRequired = 1
        tap.require(toFail: doubleTap)
        tap.addTarget(self, action: #selector(tapScreen))
        self.view.addGestureRecognizer(tap)
        
        doubleTap.numberOfTapsRequired = 2
        doubleTap.addTarget(self, action: #selector(doubleTapScreen(recognizer:)))
        self.view.addGestureRecognizer(doubleTap)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    @objc private func shareImage() {
        print("sharing Image")
        let sharedImage: [Any] = [imageView.image!]
        let sharingViewController = UIActivityViewController(activityItems: sharedImage, applicationActivities: nil)
        self.present(sharingViewController, animated: true, completion: nil)
    }
    
    @objc private func showDetails() {
        print("showing Details")
        performSegue(withIdentifier: "Inspect", sender: nil)
    }
    
    //MARK: prepareForSegue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Inspect" {
            let details = segue.destination as! ImageDetailsViewController
            details.phAsset = self.phAsset
            details.index = self.index
            details.imageFetchResult = self.imageFetchResult
        }
    }
    
    @objc private func tapScreen() {
        print("tapped screen")
        self.viewWillAppear(false)
        if (self.navigationController?.isNavigationBarHidden)!{
            self.navigationController?.setNavigationBarHidden(false, animated: true)
            self.navigationController?.setToolbarHidden(false, animated: true)
            self.tabBarController?.tabBar.isHidden = false
        } else {
            self.navigationController?.setNavigationBarHidden(true, animated: true)
            self.navigationController?.setToolbarHidden(true, animated: true)
            self.tabBarController?.tabBar.isHidden = true
        }
    }
    
    @objc private func doubleTapScreen(recognizer: UITapGestureRecognizer) {
        print("double tapped")
        if scrollView.zoomScale == 1 {
            scrollView.zoom(to: zoomRectForScale(scale: (scrollView.maximumZoomScale)/2, center: recognizer.location(in: recognizer.view)), animated: true)
        } else {
            scrollView.setZoomScale(1, animated: true)
        }
    }
    
    func zoomRectForScale(scale: CGFloat, center: CGPoint) -> CGRect {
        var zoomRect = CGRect.zero
        zoomRect.size.height = imageView.frame.size.height / scale
        zoomRect.size.width  = imageView.frame.size.width  / scale
        let newCenter = imageView.convert(center, from: scrollView)
        zoomRect.origin.x = newCenter.x - (zoomRect.size.width / 2.0)
        zoomRect.origin.y = newCenter.y - (zoomRect.size.height / 2.0)
        return zoomRect
    }
}

class UIShortTapGestureRecognizer: UITapGestureRecognizer {
    let tapMaxDelay: Double = 0.4
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        let deadlineTime = DispatchTime.now() + tapMaxDelay
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
            // Enough time has passed and the gesture was not recognized -> It has failed.
            if  self.state != UIGestureRecognizerState.ended {
                self.state = UIGestureRecognizerState.failed
            }
        }
    }
    
}



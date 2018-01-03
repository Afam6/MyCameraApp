//
//  MapImageViewController.swift
//  MyCameraApp
//
//  Created by Afam Ezechukwu on 03/01/2018.
//  Copyright © 2018 The Gypsy. All rights reserved.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass
import Photos

class MapImageViewController: UIViewController, UIScrollViewDelegate {
    
    var tap = UIShortTapGestureRecognizer()
    var doubleTap = UITapGestureRecognizer()
    
    var phAssets = [PHAsset]()
    var phAsset: PHAsset?
    var index: Int!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
    
    @objc private func tapScreen() {
        print("tapped screen")
        if (self.navigationController?.isNavigationBarHidden)!{
            self.navigationController?.setNavigationBarHidden(false, animated: true)
        } else {
            self.navigationController?.setNavigationBarHidden(true, animated: true)
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
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

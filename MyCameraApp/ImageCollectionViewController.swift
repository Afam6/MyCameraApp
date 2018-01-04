//
//  ImageCollectionViewController.swift
//  MyCameraApp
//
//  Created by Afam Ezechukwu on 15/12/2017.
//  Copyright © 2017 The Gypsy. All rights reserved.
//

import UIKit
import Photos

class ImageCollectionViewController: UICollectionViewController, UIViewControllerTransitioningDelegate, UINavigationControllerDelegate {
    
    var indexPath: IndexPath!
    var imageFetchResult = PHFetchResult<PHAsset>()
    let shapeLayer = CAShapeLayer()
    let trackLayer = CAShapeLayer()
    var pulsatingLayer = CAShapeLayer()
    let percentageLabel: UILabel = {
        let label = UILabel()
        label.text = "0%"
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 32)
        return label
    }()
    var percentageTracker = 0
    var orientation: UIDeviceOrientation = UIDevice.current.orientation
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("view did load")
        
        collectionView?.isPagingEnabled = false
        
        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized{
            print("authorized")
        } else {
            print("unauthorized")
        }
        
        navigationController?.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(ImageCollectionViewController.rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToForeground), name: Notification.Name.UIApplicationWillEnterForeground, object: nil)
        
        grabPhotos()
        
        let collectionViewWidth = collectionView?.frame.width
        
        let padding: CGFloat = 2.0
        
        let itemsPerRow: CGFloat = 3.0
        
        let itemWidth = (collectionViewWidth! - padding) / itemsPerRow
        
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        
        let center = CGPoint(x: (collectionView?.center.x)!, y: (collectionView?.center.y)! - 65)
        
        let labelPosition = CGPoint(x: (collectionView?.center.x)!, y: (collectionView?.center.y)! - 65)
        
        if percentageTracker < 100{
            loader(center: center, labelPosition: labelPosition)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if imageFetchResult.count > 0 {
            print("view will appear")
            grabPhotos()
        }
        navigationController?.hidesBarsOnTap = false
        navigationController?.setToolbarHidden(true, animated: true)
        navigationController?.setNavigationBarHidden(false, animated: true)
        self.tabBarController?.tabBar.isHidden = false
    
        
        
        if UIDevice.current.orientation.isFlat && orientation.isLandscape {
            print("view is flat and landscape")
            let collectionViewWidth = collectionView?.frame.width
            print("width \(String(describing: collectionViewWidth))")
            let layout = collectionViewLayout as! UICollectionViewFlowLayout
            layout.itemSize = CGSize(width: collectionViewWidth!/6 - 1, height: collectionViewWidth!/6 - 1)

        } else {
            print("view is not flat")
            rotated()
        }
    }
    
    @objc func appMovedToForeground() {
        grabPhotos()
        collectionView?.reloadData()
    }
    
    @objc func rotated() {
        
        
        if UIDevice.current.orientation.isFlat {
            print("orientation is flat")
            
        } else {
            print("orientation is not flat")
            
        }
        
        if UIDeviceOrientationIsLandscape(UIDevice.current.orientation){
            orientation = UIDevice.current.orientation
            
            print("Flat Landscape")
            let collectionViewWidth = collectionView?.frame.width
            print("width \(String(describing: collectionViewWidth))")
            let layout = collectionViewLayout as! UICollectionViewFlowLayout
            layout.itemSize = CGSize(width: collectionViewWidth!/6 - 1, height: collectionViewWidth!/6 - 1)
            
            let center = CGPoint(x: (collectionView?.center.x)!, y: (collectionView?.center.y)!)
            
            if percentageTracker < 100{
                loader(center: center, labelPosition: center)
            }
        }
        
        if UIDeviceOrientationIsPortrait(UIDevice.current.orientation) {
            orientation = UIDevice.current.orientation
            
            let collectionViewWidth = collectionView?.frame.width
            print("Flat Portrait")
            print("width \(String(describing: collectionViewWidth))")
            
            let padding: CGFloat = 2.0
            
            let itemsPerRow: CGFloat = 3.0
            
            let itemWidth = (collectionViewWidth! - padding) / itemsPerRow
            
            let layout = collectionViewLayout as! UICollectionViewFlowLayout
            layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
            
            let center = CGPoint(x: (collectionView?.center.x)!, y: (collectionView?.center.y)! - 65)
            
            let labelPosition = CGPoint(x: (collectionView?.center.x)!, y: (collectionView?.center.y)! - 65)
            
            if percentageTracker < 100{
                loader(center: center, labelPosition: labelPosition)
            }
        }
    }
    
    //MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageFetchResult.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let phAsset: PHAsset = self.imageFetchResult[indexPath.item]
        
        let imageCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCollectionViewCell
        
        PHImageManager.default().requestImage(for: phAsset, targetSize: CGSize(width:100, height: 100), contentMode: .aspectFill, options: nil, resultHandler: { (result, info) in
            if let image = result {
                imageCell.imageView.image = image
            }
        })
        
        return imageCell
    }
    
    //MARK: UICollectionViewDelegate
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.indexPath = indexPath
        performSegue(withIdentifier: "ShowImageViewController", sender: nil)
        
    }
    
    
    //MARK: prepareForSegue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowImageViewController" {
            let page = segue.destination as! ImagePageViewController
            page.index = indexPath.item
            page.imageFetchResult = imageFetchResult
            page.transitioningDelegate = self
        }
    }
 
    
    //MARK: createLayer
    func createLayer(layer: CAShapeLayer, strokeColor: CGColor, lineWidth: CGFloat, fillColor: CGColor, position: CGPoint){
        
        let circularPath = UIBezierPath(arcCenter: .zero, radius: 100, startAngle: 0, endAngle: 2*CGFloat.pi, clockwise: true)
        
        layer.path = circularPath.cgPath
        layer.strokeColor = strokeColor
        layer.lineWidth = lineWidth
        layer.fillColor = fillColor
        layer.lineCap = kCALineCapRound
        layer.position = position
    }
    
    //MARK: loader
    func loader(center: CGPoint, labelPosition: CGPoint) {
        
        createLayer(layer: pulsatingLayer, strokeColor: UIColor.clear.cgColor, lineWidth: 10, fillColor: UIColor(red: 89.0/255, green: 206.0/255, blue: 134.0/255, alpha: 0.3).cgColor, position: center)
        collectionView?.layer.addSublayer(pulsatingLayer)
        
        createLayer(layer: trackLayer, strokeColor: UIColor.lightGray.cgColor, lineWidth: 20, fillColor: UIColor.white.cgColor, position: center)
        collectionView?.layer.addSublayer(trackLayer)
        
        let basicAnimation = CABasicAnimation(keyPath: "transform.scale")
        basicAnimation.toValue = 1.3
        basicAnimation.duration = 0.8
        basicAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        basicAnimation.autoreverses = true
        basicAnimation.repeatCount = Float.infinity
        basicAnimation.fillMode = kCAFillModeForwards
        basicAnimation.isRemovedOnCompletion = false
        pulsatingLayer.add(basicAnimation, forKey: "urSoBasic")
        
        createLayer(layer: shapeLayer, strokeColor: UIColor(red: 89.0/255, green: 206.0/255, blue: 134.0/255, alpha: 1.0).cgColor, lineWidth: 20, fillColor: UIColor.clear.cgColor, position: center)
        shapeLayer.transform = CATransform3DMakeRotation(-CGFloat.pi/2, 0, 0, 1)
        shapeLayer.strokeEnd = 0
        collectionView?.layer.addSublayer(shapeLayer)
        
        collectionView?.addSubview(percentageLabel)
        percentageLabel.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        percentageLabel.center = labelPosition
    }
    
    //MARK: grabPhotos
    func grabPhotos() {
        
        DispatchQueue.global(qos: .background).async {
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
                if self.percentageTracker == 0 {
                    for i in 0..<phFetchResult.count {
                        let percentage = CGFloat(i+1) / CGFloat(phFetchResult.count)
                        print(i)
                        DispatchQueue.main.async {
                            self.percentageLabel.text = "\(Int(percentage * 100))%"
                            self.shapeLayer.strokeEnd = percentage
                        }
                        self.percentageTracker = Int(percentage)
                    }
                }
                self.trackLayer.removeFromSuperlayer()
                self.shapeLayer.removeFromSuperlayer()
                self.pulsatingLayer.removeFromSuperlayer()
                self.percentageTracker = 100
            } else {
                print("You got no photos.")
                if PHPhotoLibrary.authorizationStatus() != PHAuthorizationStatus.denied{
                    print("not denied")
                    self.grabPhotos()
                } else {
                    print("denied")
                }
            }
            
            DispatchQueue.main.async {
                self.collectionView?.reloadData()
                self.percentageLabel.text = ""
            }
        }
    }
    
    let animationController = AnimationController()
    let interactionController = InteractionController()
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if operation == .push {
            interactionController.attachToViewController(viewController: toVC)
        }
        animationController.reverse = operation == .pop
        return animationController
    }
    
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        
        return interactionController.transitionInProgress ? interactionController : nil
    }
}

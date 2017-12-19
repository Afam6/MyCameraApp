//
//  ImagePageViewController.swift
//  MyCameraApp
//
//  Created by Afam Ezechukwu on 19/12/2017.
//  Copyright © 2017 The Gypsy. All rights reserved.
//

import UIKit
import Photos

class ImagePageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    var imageArray = [UIImage]()
    var imageFetchResult = PHFetchResult<PHAsset>()
    var index: Int!
    
    override var prefersStatusBarHidden: Bool {
        return navigationController?.isNavigationBarHidden == true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        let startingViewController: ImageViewController = self.viewControllerAtIndex(index, storyboard: self.storyboard!)!
        setNavigationTitle(index: index)
        let viewControllers = [startingViewController]
        setViewControllers(viewControllers, direction: .forward, animated: false, completion: {done in })
        dataSource = self
    }
    
    func viewControllerAtIndex(_ index: Int, storyboard: UIStoryboard) -> ImageViewController? {
        
        if (self.imageArray.count == 0) || (index >= self.imageArray.count) {
            return nil
        }
        
        let imageViewController = storyboard.instantiateViewController(withIdentifier: "ImageViewController") as! ImageViewController
        imageViewController.image = self.imageArray[index]
        return imageViewController
    }
    
    func indexOfViewController(_ viewController: ImageViewController) -> Int {
        return imageArray.index(of: viewController.image!) ?? NSNotFound
    }
    
    // MARK: - Page View Controller Data Source
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        var index = self.indexOfViewController(viewController as! ImageViewController)
        setNavigationTitle(index: index)
        if (index == 0) || (index == NSNotFound) {
            return nil
        }
        
        index -= 1
        return self.viewControllerAtIndex(index, storyboard: viewController.storyboard!)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var index = self.indexOfViewController(viewController as! ImageViewController)
        setNavigationTitle(index: index)
        if index == NSNotFound {
            return nil
        }
        
        index += 1
        if index == self.imageArray.count {
            return nil
        }
        return self.viewControllerAtIndex(index, storyboard: viewController.storyboard!)
    }
    
    func setNavigationTitle(index:Int) {
        if imageFetchResult[index].location != nil {
            let latitude = Double((imageFetchResult[index].location?.coordinate.latitude)!)
            let longitude = Double((imageFetchResult[index].location?.coordinate.longitude)!)
            let location = CLLocation(latitude: latitude, longitude: longitude)
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(location) {placemarks, error in
                if placemarks?.count ?? 0 > 0 {
                    let placemark = placemarks![0]
                    let title = "\(self.stringForPlacemark(placemark))"
                    let dateFormatter = DateFormatter()
                    
                    let calendar = Calendar.current
                    let currentYear = calendar.component(.year, from: Date())
                    let pictureYear = calendar.component(.year, from: self.imageFetchResult[index].creationDate!)
                    if currentYear != pictureYear{
                        print("Different year!")
                        dateFormatter.dateFormat = "d MMMM yyyy HH:mm"
                    } else {
                        dateFormatter.dateFormat = "d MMMM HH:mm"
                    }
                    
                    let subtitle = dateFormatter.string(from: self.imageFetchResult[index].creationDate!)
                    self.navigationItem.titleView = self.setTitle(title: title, subtitle: subtitle)
                    
                }
            }
        } else {
            let date = DateFormatter()
            let time = DateFormatter()
            
            let calendar = Calendar.current
            let currentYear = calendar.component(.year, from: Date())
            let pictureYear = calendar.component(.year, from: self.imageFetchResult[index].creationDate!)
            if currentYear != pictureYear{
                print("Different year!")
                date.dateFormat = "d MMMM yyyy"
                time.dateFormat = "HH:mm"
            } else {
                date.dateFormat = "d MMMM"
                time.dateFormat = "HH:mm"
            }
            
            let title = date.string(from: self.imageFetchResult[index].creationDate!)
            let subtitle = time.string(from: self.imageFetchResult[index].creationDate!)
            print("Time is \(title) \(subtitle). Index is \(index)")
            self.navigationItem.titleView = self.setTitle(title: title, subtitle: subtitle)
        }
    }
    
    func setTitle(title:String, subtitle:String) -> UIView {
        let titleLabel = UILabel()
        setLabel(label: titleLabel, position: -2, fontSize: 17, text: title)
        
        let subtitleLabel = UILabel()
        setLabel(label: subtitleLabel, position: 18, fontSize: 12, text: subtitle)
        
        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: max(titleLabel.frame.size.width, subtitleLabel.frame.size.width), height: 30))
        titleView.addSubview(titleLabel)
        titleView.addSubview(subtitleLabel)
        
        let widthDiff = subtitleLabel.frame.size.width - titleLabel.frame.size.width
        
        if widthDiff < 0 {
            let newX = widthDiff / 2
            subtitleLabel.frame.origin.x = abs(newX)
        } else {
            let newX = widthDiff / 2
            titleLabel.frame.origin.x = newX
        }
        
        return titleView
    }
    
    func setLabel(label: UILabel, position: CGFloat, fontSize: CGFloat, text: String)  {
        label.frame = CGRect(x: 0, y: position, width: 0, height: 0)
        label.backgroundColor = UIColor.clear
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: fontSize)
        label.text = text
        label.sizeToFit()
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
}

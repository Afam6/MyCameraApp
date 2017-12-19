//
//  ImageViewController.swift
//  MyCameraApp
//
//  Created by Afam Ezechukwu on 19/12/2017.
//  Copyright © 2017 The Gypsy. All rights reserved.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass

class ImageViewController: UIViewController {
    
    var tap = UIShortTapGestureRecognizer()
    var doubleTap = UITapGestureRecognizer()

    @IBOutlet weak var imageView: UIImageView!
    var image: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.imageView!.image = image
        
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

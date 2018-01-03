//
//  CameraViewController.swift
//  MyCameraApp
//
//  Created by Afam Ezechukwu on 02/01/2018.
//  Copyright © 2018 The Gypsy. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var captureSession = AVCaptureSession()
    var stillImageOutput: AVCaptureStillImageOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var frontCamera: AVCaptureDevice?
    var backCamera: AVCaptureDevice?
    var currentCamera: AVCaptureDevice?
    var toggleCamera = UITapGestureRecognizer()
    var zoom = UIPinchGestureRecognizer()
    let minimumZoom: CGFloat = 1.0
    let maximumZoom: CGFloat = 10.0
    var lastZoomFactor: CGFloat = 1.0
    var image: UIImage?

    @IBOutlet var cameraView: UIView!
    @IBAction func switchCamera(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            toggle()
        } else {
            print("No camera available")
        }
    }
    
    @IBAction func cameraButton(_ sender: Any) {
        if AVCaptureDevice.authorizationStatus(for: .video) ==  .authorized {
            if let connection = stillImageOutput?.connection(with: AVMediaType.video){
                connection.videoOrientation = AVCaptureVideoOrientation.portrait
                stillImageOutput?.captureStillImageAsynchronously(from: connection, completionHandler: { (sampleBuffer, error) in
                    if sampleBuffer != nil {
                        let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer!)
                        self.image = UIImage(data: imageData!)
                        self.performSegue(withIdentifier: "ShowPhotoSegue", sender: nil)
                    }
                })
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowPhotoSegue" {
            let previewViewController = segue.destination as! PreviewViewController
            previewViewController.image = self.image
        }
    }
    
    func updateOrientation(orientation: UIInterfaceOrientation) -> AVCaptureVideoOrientation {
        switch orientation {
            case .portraitUpsideDown:
                return .portraitUpsideDown
            case .landscapeLeft:
                return .landscapeLeft
            case .landscapeRight:
                return .landscapeRight
            default:
                return .portrait
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            captureSession.sessionPreset = AVCaptureSession.Preset.photo
            
            let devices = AVCaptureDevice.devices(for: AVMediaType.video)
            
            for device in devices {
                if device.position == AVCaptureDevice.Position.back {
                    backCamera = device
                } else if device.position == AVCaptureDevice.Position.front {
                    frontCamera = device
                }
            }
            
            currentCamera = backCamera
            
            do {
                let input = try AVCaptureDeviceInput(device: currentCamera!)
                captureSession.addInput(input)
                stillImageOutput = AVCaptureStillImageOutput()
                stillImageOutput?.outputSettings = [AVVideoCodecKey : AVVideoCodecJPEG]
                captureSession.addOutput(stillImageOutput!)
            } catch {
                print(error)
            }
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            previewLayer?.connection?.videoOrientation = updateOrientation(orientation: UIInterfaceOrientation(rawValue: UIApplication.shared.statusBarOrientation.rawValue)!)
            previewLayer?.frame = self.cameraView.bounds
            self.cameraView.layer.insertSublayer(previewLayer!, at: 0)
            captureSession.startRunning()
            toggleCamera.numberOfTapsRequired = 2
            toggleCamera.addTarget(self, action: #selector(toggle))
            self.view.addGestureRecognizer(toggleCamera)
            zoom.addTarget(self, action: #selector(pinch))
            self.view.addGestureRecognizer(zoom)
        } else {
            print("No camera available")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        previewLayer?.frame = self.cameraView.bounds
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { (context) -> Void in
            self.previewLayer?.connection?.videoOrientation = self.updateOrientation(orientation: UIInterfaceOrientation(rawValue: UIApplication.shared.statusBarOrientation.rawValue)!)
            self.previewLayer?.frame = self.cameraView.bounds
        }) { (context) -> Void in
            
        }
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    @objc private func toggle() {
        captureSession.beginConfiguration()
        let newCurrentCamera = (currentCamera?.position == .back) ? frontCamera : backCamera
        for input in captureSession.inputs {
            captureSession.removeInput(input as! AVCaptureDeviceInput)
        }
        do {
            let newCaptureDeviceInput = try AVCaptureDeviceInput(device: newCurrentCamera!)
            if captureSession.canAddInput(newCaptureDeviceInput) {
                captureSession.addInput(newCaptureDeviceInput)
            }
        } catch {
            print(error)
        }
        currentCamera = newCurrentCamera
        captureSession.commitConfiguration()
    }
    
    @objc private func pinch(_ pinch: UIPinchGestureRecognizer) {
        
        guard let device = currentCamera else { return }
        
        func minMaxZoom(_ factor: CGFloat) -> CGFloat {
            return min(min(max(factor, minimumZoom), maximumZoom), device.activeFormat.videoMaxZoomFactor)
        }
        
        func update(scale factor: CGFloat) {
            do {
                try device.lockForConfiguration()
                defer { device.unlockForConfiguration() }
                device.videoZoomFactor = factor
            } catch {
                print("\(error.localizedDescription)")
            }
        }
        
        let newScaleFactor = minMaxZoom(pinch.scale * lastZoomFactor)
        
        switch pinch.state {
        case .began: fallthrough
        case .changed: update(scale: newScaleFactor)
        case .ended:
            lastZoomFactor = minMaxZoom(newScaleFactor)
            update(scale: lastZoomFactor)
        default: break
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}


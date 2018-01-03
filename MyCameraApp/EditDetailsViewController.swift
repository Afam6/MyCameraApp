//
//  EditDetailsViewController.swift
//  MyCameraApp
//
//  Created by Afam Ezechukwu on 30/12/2017.
//  Copyright © 2017 The Gypsy. All rights reserved.
//

import UIKit
import Photos

class EditDetailsViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet var descriptionTextView: UITextView!
    
    @IBAction func cancelButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    var index: Int!
    var imageFetchResult = PHFetchResult<PHAsset>()
    var text: String!
    var imageDescription: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        saveButton.isEnabled = !((titleTextField.text?.isEmpty)!)
        titleTextField.delegate = self
        descriptionTextView.delegate = self
        
        self.descriptionTextView.layer.borderWidth = 0.5
        self.descriptionTextView.layer.borderColor = UIColor.gray.cgColor
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            return
        }
        
        self.text = self.titleTextField.text
        self.imageDescription = self.descriptionTextView.text
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        saveButton.isEnabled = false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        saveButton.isEnabled = false
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        saveButton.isEnabled = !((descriptionTextView.text?.isEmpty)!)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        saveButton.isEnabled = !((titleTextField.text?.isEmpty)!)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.titleTextField.endEditing(true)
        self.descriptionTextView.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

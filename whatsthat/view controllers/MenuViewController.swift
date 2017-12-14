//
//  ViewController.swift
//  whatsthat
//
//  Created by Han on 11/8/17.
//  Copyright © 2017 han. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class MenuViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let imagePicker = UIImagePickerController()

    var selectedImage: UIImage?
    
    @IBOutlet weak var cameraButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
    }

    @IBAction func cameraButtonTapped(_ sender: Any) {
        // Trigger an alert to provide photo options
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // Create Take photofrom camera option
        alert.addAction(UIAlertAction(title: Constants.cameraAction, style: .default, handler: { _ in
            self.checkCameraPermission()
        }))
        
        // Create choose photo from album option
        alert.addAction(UIAlertAction(title: Constants.photoAction, style: .default, handler: { _ in
            self.checkPhotoPermission()
        }))
        
        // Create Cancel option
        alert.addAction(UIAlertAction.init(title: Constants.cancelButton, style: .cancel, handler: nil))

        self.present(alert, animated: true, completion: nil)
        alert.view.tintColor = UIColor.darkGray
    }
}

// Image picker controller
extension MenuViewController {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            // Use editedImage Here
            selectedImage = editedImage
            
            // navigate to PhotoIdentificationViewController
            self.performSegue(withIdentifier: Constants.cameraToRecognitionSegue, sender: self)
            
        } else if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            // Use originalImage Here
            selectedImage = originalImage
            self.performSegue(withIdentifier: Constants.cameraToRecognitionSegue, sender: self)
        }
        picker.dismiss(animated: true)
    }

    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}


// Camera or Photo album
extension MenuViewController {
    // Check for camera permission
    func checkCameraPermission() {
        if AVCaptureDevice.authorizationStatus(for: AVMediaType.video) == .authorized {
            // Already Authorized
            self.openCamera()
        } else {
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (granted: Bool) -> Void in
                if granted == true {
                    // User granted
                    self.openCamera()
                } else {
                    // User rejected
                    self.alertToAllowCameraAccessViaSetting(Constants.camera)
                }
            })
        }
    }
    
    // Check for photo permission
    func checkPhotoPermission() {
        if PHPhotoLibrary.authorizationStatus() == .authorized {
            // Access has been granted.
            self.openCameraRoll()
        }
        else  {
            // Access has not been determined.
            PHPhotoLibrary.requestAuthorization({ (newStatus) in
                
                if (newStatus == PHAuthorizationStatus.authorized) {
                    self.openCameraRoll()
                }
                else {
                    self.alertToAllowCameraAccessViaSetting(Constants.photo)
                }
            })
        }
    }
    
    // imagePicker-- camera
    private func openCamera() {
        
        if(UIImagePickerController .isSourceTypeAvailable(.camera)) {
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
        else {
            let alert  = UIAlertController(title: Constants.alertTitle, message: Constants.alertMessageNoCamera, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: Constants.okButton, style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    //imagePicker-- camera roll
    private func openCameraRoll() {
        imagePicker.sourceType = .savedPhotosAlbum
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    // Prompt alert for allowing access to camera/photo
    private func alertToAllowCameraAccessViaSetting(_ setting: String) {
        let alert = UIAlertController(title: Constants.alertTitle, message: "Allow WhatsThat to access your \(setting) on Setting-privacy on your iPhone", preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: Constants.okButton, style: .default))
        
        present(alert, animated: true)
    }
}

// Segue
extension MenuViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let identifier = segue.identifier else { return }
        
        switch identifier {
            
        // Pass values to Photo recognition view
        case Constants.cameraToRecognitionSegue:
            let photoRecognizer = segue.destination as! PhotoRecognitionViewController
            photoRecognizer.image = selectedImage
            
        // Pass value to favorite view
        case Constants.favoriteSegue:
            let recognitions = PersistanceManager.sharedInstance.fetchFavites()
            
            let destinationViewController = segue.destination as? FavoritePhotosTableViewController
            destinationViewController?.favoritesRecognitions = recognitions
            
        default: break
        }
    }
}






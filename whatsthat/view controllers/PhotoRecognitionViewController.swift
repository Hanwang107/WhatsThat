//
//  PhotoRecognitionViewController.swift
//  whatsthat
//
//  Created by Han on 11/13/17.
//  Copyright © 2017 han. All rights reserved.
//

import UIKit
import MBProgressHUD

class PhotoRecognitionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // pass from menu view
    var image: UIImage?
    
    var imageUrl: URL?
    var currentLatitude: Double?
    var currentLongitude: Double?
    
    var visionResults = [LabelAnnotations]()
    var selectedResult = ""
    var favoriteRecognition: FavoriteRecognition!
    
    let googleManager = GoogleVisionAPIManager()
    let locationFinder = LocationFinder()
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var recognitionTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Display progress bar
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        // Show image view
        imageView.image = image
        
        locationFinder.delegate = self
    }
    
    // Fetch google vision after get the location data
    func fetchGoogleVisionResult() {
        
        //base64 decode image
        guard let imageData = image else {
            print(Constants.photoNotPicked)
            return
        }
        // Fetch data from google vision
        let binaryImageData = ImageHelper.shareInstance.base64EncodeImage(imageData)
        googleManager.delegate = self
        googleManager.fetchGoogleVision(with: binaryImageData)
        
        // This view controller itself will provide the delegate methods and row data for the table view.
        recognitionTableView.delegate = self
        recognitionTableView.dataSource = self
    }
    
    func findLocation() {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        locationFinder.findLocation()
    }
    
    // TableView
    // MARK: - Table view data source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // implementation, return the number of rows
        return self.visionResults.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.visionCell, for: indexPath)
        
        // Configure the cell...
        let visionResult = self.visionResults[indexPath.row]
        cell.textLabel?.text = "\(visionResult.description)"
        let probability = String(format: "%.2f", visionResult.score)
        cell.detailTextLabel?.text = "Score: \(probability)"
        cell.detailTextLabel?.textColor = .gray
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let row = indexPath.row
        selectedResult = visionResults[row].description
        
        self.performSegue(withIdentifier: Constants.recongtionToDetailSegue, sender: self)
    }
}

// Google vision api delegate
extension PhotoRecognitionViewController: GoogleVisionDelegate {
    func photoRecognized(results: [LabelAnnotations]) {
        self.visionResults = results

        DispatchQueue.main.async {
            MBProgressHUD.hide(for: self.view, animated: true)
            self.recognitionTableView.reloadData()
        }
    }

    func photoNotRecognized(reason: GoogleVisionAPIManager.FailureReason) {
        DispatchQueue.main.async {
            MBProgressHUD.hide(for: self.view, animated: true)
            
            let alertController = UIAlertController(title: Constants.alertTitlePhotoNotRecognized, message: reason.rawValue, preferredStyle: .alert)
            
            switch reason {
            case .badJSONResponse, .noData, .noLabel:
                let retryAction = UIAlertAction(title: Constants.retryButton, style: .default, handler: { (action) in
                    MBProgressHUD.showAdded(to: self.view, animated: true)
                    self.fetchGoogleVisionResult()
                })
                
                let cancelAction = UIAlertAction(title: Constants.cancelButton, style: .default, handler: nil)
                
                alertController.addAction(retryAction)
                alertController.addAction(cancelAction)
                
            case .networkRequestFailed:
                let okayAction = UIAlertAction(title: Constants.okButton, style: .default, handler: { (action) in
                    self.navigationController?.popViewController(animated: true)
                })
                
                alertController.addAction(okayAction)
            }
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
}

// FavoriteRecognition
extension PhotoRecognitionViewController {
    // Create Favorite recognition
    private func createFavoriteRecognition() {
        imageUrl = ImageHelper.shareInstance.getDocumentsDirectory(UUID().uuidString + ".png")
        guard let url = imageUrl else { return }
        
        favoriteRecognition = FavoriteRecognition(name: selectedResult, url: url, latitude: currentLatitude, longitude: currentLongitude)
    }
}

// Location finder delegate
extension PhotoRecognitionViewController: LocationFinderDelegate {
    func locationFound(latitude: Double, longitude: Double) {
        self.currentLatitude = latitude
        self.currentLongitude = longitude
        
        self.fetchGoogleVisionResult()
    }
    
    func locationNotFound(reason: LocationFinder.FailureReason) {
        DispatchQueue.main.async {
            MBProgressHUD.hide(for: self.view, animated: true)
            
            let alertController = UIAlertController(title: Constants.alertTitle, message: reason.rawValue, preferredStyle: .alert)
            
            switch reason {
            case .error, .timeout:
                let retryAction = UIAlertAction(title: Constants.retryButton, style: .default, handler: { (action) in
                    
                    self.findLocation()
                })
                
                let cancelAction = UIAlertAction(title: Constants.cancelButton, style: .default, handler: { (action) in
                    self.navigationController?.popViewController(animated: true)
                })
                
                alertController.addAction(retryAction)
                alertController.addAction(cancelAction)
                
            case .noPermission:
                let okayAction = UIAlertAction(title: Constants.okButton, style: .default, handler: { (action) in
                    self.navigationController?.popViewController(animated: true)
                })
                
                alertController.addAction(okayAction)
            }
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
}

// Segue
extension PhotoRecognitionViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.recongtionToDetailSegue {
            self.createFavoriteRecognition()
            
            let photoDetail = segue.destination as! PhotoDetailsViewController
            photoDetail.image = image
            photoDetail.favoriteRecognition = favoriteRecognition
        }
    }
}



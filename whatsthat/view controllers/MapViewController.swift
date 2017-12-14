//
//  MapViewController.swift
//  whatsthat
//
//  Created by Han on 11/28/17.
//  Copyright © 2017 han. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    var favoritesRecognitions = [FavoriteRecognition]()
    var selectedFavorite: FavoriteRecognition!

    @IBOutlet weak var mapView: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = Constants.titleMapView
        
        mapView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.displayFavorites()
    }
}

// Drop pins on map
extension MapViewController {
    
    // Locate the current regoin on MapView
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        
        guard let coordinate = userLocation.location?.coordinate  else { return }
        
        let region = MKCoordinateRegionMakeWithDistance(coordinate, 1000, 1000)
        mapView.setRegion(region, animated: true)
    }
    
    // Display favorites on the map view
    private func displayFavorites() {
        mapView.removeAnnotations(favoritesRecognitions)
        
        favoritesRecognitions = PersistanceManager.sharedInstance.fetchFavites()
        
        mapView.addAnnotations(favoritesRecognitions)
    }
}

// Display annotation on map view
extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = Constants.favoriteRecognition
        
        if annotation is FavoriteRecognition {
            if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) {
                annotationView.annotation = annotation

                return annotationView
            } else {
                let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView.canShowCallout = true
                annotationView.calloutOffset = CGPoint(x: -5, y: 5)
                
                let button = UIButton(type: .detailDisclosure)
                annotationView.rightCalloutAccessoryView = button
                
                // Display image annotation
                let favorite = annotation as! FavoriteRecognition
                guard let image = favorite.image else { return annotationView}
                let newImage = ImageHelper.shareInstance.resizeImage(image: image, newWidth: 80)
                annotationView.image = newImage
                
                return annotationView
            }
        }
        
        return nil
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        // Get which one tapped
        selectedFavorite = view.annotation as! FavoriteRecognition
        
        self.performSegue(withIdentifier: Constants.mapToDetailSegue, sender: self)
    }
}

// Segue
extension MapViewController {
    // Passing data with segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Go to map view
        if segue.identifier == Constants.mapToDetailSegue {
            let detailView = segue.destination as! PhotoDetailsViewController
            detailView.favoriteRecognition = selectedFavorite
            
            // Load image
            let fileName = selectedFavorite.url.lastPathComponent
            let url = ImageHelper.shareInstance.getDocumentsDirectory(fileName)
            detailView.image = UIImage(contentsOfFile: url.path)
        }
    }
}




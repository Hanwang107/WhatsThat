//
//  LocationFinder.swift
//  whatsthat
//
//  Created by Han on 11/29/17.
//  Copyright © 2017 han. All rights reserved.
//

import Foundation
import CoreLocation

protocol LocationFinderDelegate {
    func locationFound(latitude: Double, longitude: Double)
    func locationNotFound(reason: LocationFinder.FailureReason)
}

class LocationFinder: NSObject {
    
    enum FailureReason: String {
        case noPermission = "Location permission not available, please allow this app to use your location on Setting-privacy on your iPhone"
        case timeout = "It took too long to find your location"
        case error = "Error finding location"
    }
    
    let locationManager = CLLocationManager()
    
    var delegate: LocationFinderDelegate?
    var timer = Timer()
    
    override init() {
        super.init()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }
    
    func startTimer() {
        cancelTimer()
        
        timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: false, block: { (timer) in
            //code that will run 10 seconds later
            self.locationManager.stopUpdatingLocation()
            self.delegate?.locationNotFound(reason: .timeout)
        })
    }
    
    func cancelTimer() {
        timer.invalidate()
    }
    
    func findLocation() {
        let status = CLLocationManager.authorizationStatus()
        
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            delegate?.locationNotFound(reason: .noPermission)
        case .authorizedWhenInUse:
            startTimer()
            locationManager.requestLocation()
        case .authorizedAlways:
            //do nothing - app can't get to this state
            break
        }
    }
}

extension LocationFinder: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        cancelTimer()
        
        manager.stopUpdatingLocation()
        
        let location = locations.first!
        delegate?.locationFound(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            delegate?.locationNotFound(reason: .noPermission)
        case .authorizedWhenInUse:
            startTimer()
            locationManager.requestLocation()
        case .authorizedAlways:
            //do nothing - app can't get to this state
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        cancelTimer()
        
        print(error.localizedDescription)
        delegate?.locationNotFound(reason: .error)
    }
}

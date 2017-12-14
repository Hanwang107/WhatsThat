//
//  FavoriteRecognition.swift
//  whatsthat
//
//  Created by Han on 11/21/17.
//  Copyright © 2017 han. All rights reserved.
//

import Foundation
import MapKit

class FavoriteRecognition: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    let name: String
    let url: URL
    let latitude: Double?
    let longitude: Double?
    
    let nameKey = "name"
    let urlKey = "url"
    let latitudeKey = "lat"
    let longitudeKey = "log"
    
    init(name: String, url: URL, latitude: Double?, longitude: Double?) {
        
        self.name = name
        self.url = url
        self.latitude = latitude
        self.longitude = longitude
        
        guard let lat = latitude, let long = longitude else {
            self.coordinate = CLLocationCoordinate2D()
            
            return
        }
        
        self.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
    }
    
    var title: String? {
        return name
    }
    
    var image: UIImage? {
        // Load image
        let fileName = url.lastPathComponent
        let newUrl = ImageHelper.shareInstance.getDocumentsDirectory(fileName)
        return UIImage(contentsOfFile: newUrl.path)
    }
    
    required init?(coder aDecoder: NSCoder) {
        name = aDecoder.decodeObject(forKey: nameKey) as! String
        url = aDecoder.decodeObject(forKey: urlKey) as! URL
        latitude = aDecoder.decodeObject(forKey: latitudeKey) as? Double
        longitude = aDecoder.decodeObject(forKey: longitudeKey) as? Double
        
        guard let lat = latitude, let long = longitude else {
            self.coordinate = CLLocationCoordinate2D()
            
            return
        }
        
        self.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
    }
}

extension FavoriteRecognition: NSCoding {
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: nameKey)
        aCoder.encode(url, forKey: urlKey)
        aCoder.encode(latitude, forKey: latitudeKey)
        aCoder.encode(longitude, forKey: longitudeKey)
    }
}

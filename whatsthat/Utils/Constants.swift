//
//  Constants.swift
//  whatsthat
//
//  Created by Han on 12/1/17.
//  Copyright © 2017 han. All rights reserved.
//

import Foundation

class Constants {
    // Google vision
    static let photoNotPicked = "No photo picked!!!"
    static let googleAPIKey = "<your api key>"
    
    // Photo Detail
    static let favoriteButton = "fav_button"
    static let favoriteFilledButton = "fav_filled_button"
    static let favoriteRecognitionKey = "favorites"
    
    // Twitter
    static let twitterDataType = "popular"
    static let twitterTitle = "Twitter Timeline"
    
    // Favorite view
    static let favoriteTitle = "Favorites"
    static let mapButton = "map"
    
    // Map view
    static let titleMapView = "View on Map"
    static let currentLocation = "You are here"
    static let favoriteRecognition = "FavoriteRecognition"
    
    // Alert information
    static let alertTitle = "Attention"
    static let alertTitlePhotoNotRecognized = "Problem fetching Google Vision Result"
    static let alertTitleWikiNotFound = "Problem fetching Wikipedia Result"
    static let alertMessageNoCamera = "You don't have camera"
    static let okButton = "Ok"
    static let doneButton = "Done"
    static let cancelButton = "Cancel"
    static let retryButton = "Retry"
    static let camera = "Camera"
    static let photo = "Photo"
    
    // Alert sheet in menu
    static let cameraAction = "Take Photo"
    static let photoAction = "Choose Photo"
    
    // Segue identifier
    static let mapToDetailSegue = "mapToDetailSegue"
    static let cameraToRecognitionSegue = "cameraSegue"
    static let favoriteSegue = "favSegue"
    static let recongtionToDetailSegue = "photoDetailSegue"
    static let favoriteToDetailSegue = "favDetailSegue"
    static let mapSegue = "mapSegue"
    
    // Table cell identifier
    static let visionCell = "visionCell"
    static let favoriteCell = "favCell"
}

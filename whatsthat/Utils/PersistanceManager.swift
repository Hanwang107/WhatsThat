//
//  PersistanceManager.swift
//  whatsthat
//
//  Created by Han on 11/14/17.
//  Copyright © 2017 han. All rights reserved.
//

import Foundation
import UIKit

class PersistanceManager {
    static let sharedInstance = PersistanceManager()
    
    let favoriteRecognitionKey = Constants.favoriteRecognitionKey
    
    // Get the favorites from User defaults
    func fetchFavites() -> [FavoriteRecognition] {
        let userDefaults = UserDefaults.standard
        
        let data = userDefaults.object(forKey: favoriteRecognitionKey) as? Data
        
        if let data = data {
            //data is not nil, so use it
            return NSKeyedUnarchiver.unarchiveObject(with: data) as? [FavoriteRecognition] ?? [FavoriteRecognition]()
        } else {
            //data is nil
            return [FavoriteRecognition]()
        }
    }
    
    // Check and perform favorite or unfavorite
    func isSaveFavorite(_ favorite: FavoriteRecognition) -> Bool {
        let userDefaults = UserDefaults.standard
        var save = false
        
        var favorites = fetchFavites()
        
        //check if the favorite has already been added to the favorites
        if (isFavorite(favorite)) {
            favorites = favorites.filter { $0.name != favorite.name }
        } else {
            favorites.append(favorite)

            save = true
        }
        
        // Save data in use default
        let data = NSKeyedArchiver.archivedData(withRootObject: favorites)
        userDefaults.set(data, forKey: favoriteRecognitionKey)
        
        return save
    }
    
    // Check if the photo label already save or not
    func isFavorite(_ favorite: FavoriteRecognition) -> Bool {
        let favorites = fetchFavites()
        
        for item in favorites {
            if  favorite.name == item.name {
                return true
            }
        }
        
        return false
    }
}

//
//  FavoritePhotosTableTableViewController.swift
//  whatsthat
//
//  Created by Han on 11/20/17.
//  Copyright © 2017 han. All rights reserved.
//

import UIKit

class FavoritePhotosTableViewController: UITableViewController {
    
    var favoritesRecognitions: [FavoriteRecognition] = []
    var selectedFavorite: FavoriteRecognition!
    
    var selectedImage: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = Constants.favoriteTitle
        
        // show favorite button
        self.createMapButton()
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return favoritesRecognitions.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.favoriteCell, for: indexPath) as! FavoriteTableViewCell

        let favorite = favoritesRecognitions[indexPath.row]
        cell.textLabel?.text = "\(favorite.name)"
        
        // Load image
        let url = ImageHelper.shareInstance.getDocumentsDirectory(favorite.url.lastPathComponent)
        cell.imageView?.image = UIImage(contentsOfFile: url.path)

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        selectedFavorite = favoritesRecognitions[indexPath.row]
        
        // Load image
        let url = ImageHelper.shareInstance.getDocumentsDirectory(selectedFavorite.url.lastPathComponent)
        selectedImage = UIImage(contentsOfFile: url.path)
        
        self.performSegue(withIdentifier: Constants.favoriteToDetailSegue, sender: self)
    }
}

extension FavoritePhotosTableViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // upate
        favoritesRecognitions = PersistanceManager.sharedInstance.fetchFavites()
        self.tableView.reloadData()
        
    }
    
    // Create a map button on the right of navigation bar
    func createMapButton() {
        let mapButton = UIBarButtonItem(image: UIImage(named: Constants.mapButton), style: .plain, target: self, action: #selector(mapButtonTapped))
        
        navigationItem.rightBarButtonItem = mapButton
    }
    
    @objc func mapButtonTapped() {
        // change tableview to mapview
        self.performSegue(withIdentifier: Constants.mapSegue, sender: self)
    }
    
    // Passing data with segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Go to detail page
        if segue.identifier == Constants.favoriteToDetailSegue {
            let photoDetail = segue.destination as! PhotoDetailsViewController
            photoDetail.image = selectedImage
            photoDetail.favoriteRecognition = selectedFavorite
        }
    }
}

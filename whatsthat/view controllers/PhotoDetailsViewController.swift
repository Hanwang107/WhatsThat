//
//  PhotoDetailsViewController.swift
//  whatsthat
//
//  Created by Han on 11/16/17.
//  Copyright © 2017 han. All rights reserved.
//

import UIKit
import SafariServices

import TwitterKit
import MBProgressHUD

class PhotoDetailsViewController: UIViewController, SFSafariViewControllerDelegate {

    var image: UIImage?
    var favoriteRecognition: FavoriteRecognition!
    var favButton: UIBarButtonItem!
    
    var query = ""
    var pageId = ""
    var wikipedia: String?

    
    let wiki = WikipediaAPIManager()
    
    @IBOutlet weak var photoDetailText: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Display progress bar
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        query = favoriteRecognition.name

        wiki.delegate = self
        
        title = query.uppercased()
        
        // show favorite button
        createFavButton()
        
        fetchWikiData()
    }
    
    func fetchWikiData() {
        wiki.fetchWikipedia(with: query)
    }
    
    // Favorite button display
    func createFavButton() {
        favButton = UIBarButtonItem(image: UIImage(named: Constants.favoriteButton), style: .plain, target: self, action: #selector(favoriteButtonTapped))
        // Check if the content exsit
        if PersistanceManager.sharedInstance.isFavorite(favoriteRecognition) {
            favButton.image = UIImage(named: Constants.favoriteFilledButton)
        }
        
        navigationItem.rightBarButtonItem = favButton
    }
    @objc func favoriteButtonTapped() {

        if PersistanceManager.sharedInstance.isSaveFavorite(favoriteRecognition) {
            favButton.image = UIImage(named: Constants.favoriteFilledButton)
            
            let imageUrl = favoriteRecognition.url
            
            guard let favImage = image else {return }
            
            ImageHelper.shareInstance.saveImage(image: favImage, url: imageUrl)
            
        } else {
            favButton.image = UIImage(named: Constants.favoriteButton)
        }
         navigationItem.rightBarButtonItem = favButton
    }
}

// Buttons in photo detail page
extension PhotoDetailsViewController {
    
    // Tap on the tweet button
    @IBAction func twitterButtonTapped(_ sender: Any) {
        let twitterViewController = TWTRTimelineViewController()
        
        let dataSource = TWTRSearchTimelineDataSource(searchQuery: "\(query)", apiClient: TWTRAPIClient())
        dataSource.resultType = Constants.twitterDataType
        
        twitterViewController.dataSource = dataSource
        twitterViewController.title = Constants.twitterTitle
        
        navigationController?.pushViewController(twitterViewController, animated: true)
    }
    
    // Share the wikipedia to other apps
    @IBAction func shareButtonTapped(_ sender: Any) {
        //Set the wikipedia text to share
        let vc = UIActivityViewController(activityItems: [photoDetailText.text, image as Any], applicationActivities: [])
        present(vc, animated: true)
    }
    
    // Wiki button tapped
    @IBAction func wikiButtonTapped(_ sender: Any) {
        let urlString = "https://en.wikipedia.org/?curid=\(pageId)"
        
        if let url = NSURL(string: urlString) {
            let vc = SFSafariViewController(url: url as URL, entersReaderIfAvailable: true)
            present(vc, animated: true)
            vc.delegate = self
        }
    }
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        dismiss(animated: true)
    }
}

// Wikipedia api delegate
extension PhotoDetailsViewController: WikipediaDelegate {
    func wikipediaFound(result: WikipediaResult) {
        self.wikipedia = result.extract
        self.pageId = result.pageid
        
        DispatchQueue.main.async {
            MBProgressHUD.hide(for: self.view, animated: true)
            self.photoDetailText.text = self.wikipedia
        }
    }
    
    func wikipediaNotFound(reason: WikipediaAPIManager.FailureReason) {
        DispatchQueue.main.async {
            MBProgressHUD.hide(for: self.view, animated: true)
            
            let alertController = UIAlertController(title: Constants.alertTitleWikiNotFound, message: reason.rawValue, preferredStyle: .alert)
            
            switch reason {
            case .badJSONResponse, .noData:
                let retryAction = UIAlertAction(title: "Retry", style: .default, handler: { (action) in
                     MBProgressHUD.showAdded(to: self.view, animated: true)
                    self.fetchWikiData()
                })
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
                
                alertController.addAction(retryAction)
                alertController.addAction(cancelAction)
                
            case .networkRequestFailed:
                let okayAction = UIAlertAction(title: "Okay", style: .default, handler: { (action) in
                    self.navigationController?.popViewController(animated: true)
                })
                
                alertController.addAction(okayAction)
            }
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
}

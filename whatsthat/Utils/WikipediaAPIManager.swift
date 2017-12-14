//
//  WikipediaAPIManager.swift
//  whatsthat
//
//  Created by Han on 11/14/17.
//  Copyright © 2017 han. All rights reserved.
//

import Foundation

protocol WikipediaDelegate {
    func wikipediaFound(result: WikipediaResult)
    func wikipediaNotFound(reason: WikipediaAPIManager.FailureReason)
}

class WikipediaAPIManager {
    // Failure reasons
    enum FailureReason: String {
        case networkRequestFailed = "No network connection, please connect the network and try again."
        case noData = "No Wikipedia data received"
        case badJSONResponse = "Bad JSON response"
    }
    
    var delegate: WikipediaDelegate?

    func fetchWikipedia (with title: String) {
        guard let encodeTitle = title.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else { return }
        var wikepediaURL: URL {
            return URL(string: "https://en.wikipedia.org/w/api.php?format=json&action=query&prop=extracts&exintro=&explaintext=&titles=\(encodeTitle)")!
        }
        
        var request = URLRequest(url: wikepediaURL)
        request.httpMethod = "GET"
        
        // run the request
        let task: URLSessionDataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            // Check for valid response with 200 (success)
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                self.delegate?.wikipediaNotFound(reason: .networkRequestFailed)
                
                return
            }
            
            // Ensure data is non-nil
            guard let data = data, let wikiJsonObject = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] ?? [String:Any]() else {
                self.delegate?.wikipediaNotFound(reason: .noData)
                
                return
            }
            
            // Ensure query is non-nil
            guard let queryJsonObject = wikiJsonObject["query"] as? [String: Any] else {
                self.delegate?.wikipediaNotFound(reason: .badJSONResponse)
                
                return
            }
            
            //Ensure page is non-page
            guard let pagesJson = queryJsonObject["pages"] as? [String: Any] else {
                self.delegate?.wikipediaNotFound(reason: .badJSONResponse)
                
                return
            }
            
            let pageId = Array(pagesJson.keys)[0]
            
            for (_, subJson): (String, Any) in pagesJson {
                
                let json = subJson as? [String: Any]
                
                if let json = json {
                    let extract = json["extract"] as? String ?? ""
                    let title = json["title"] as? String ?? ""
                    
                    let wikipedia = WikipediaResult(pageid: pageId, title: title, extract: extract)
                    self.delegate?.wikipediaFound(result: wikipedia)
                } else {
                    self.delegate?.wikipediaNotFound(reason: .badJSONResponse)
                }
            }
        }
        
        task.resume()
    }
}

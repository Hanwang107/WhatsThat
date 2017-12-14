//
//  GoogleVisionAPIManager.swift
//  whatsthat
//
//  Created by Han on 11/14/17.
//  Copyright © 2017 han. All rights reserved.
//

import Foundation
import UIKit

protocol GoogleVisionDelegate {
    func photoRecognized(results: [LabelAnnotations])
    func photoNotRecognized(reason: GoogleVisionAPIManager.FailureReason)
}

class GoogleVisionAPIManager {
    // Failure reasons
    enum FailureReason: String {
        case networkRequestFailed = "No network connection, please connect the network and try again."
        case noData = "No GoogleVision data received"
        case badJSONResponse = "Bad JSON response"
        case noLabel = "No result form Google Vision"
    }
    
    var delegate: GoogleVisionDelegate?
    
    let session = URLSession.shared
    
    // TODO: Should not write key here
    let googleAPIKey = Constants.googleAPIKey
    var googleURL: URL {
        return URL(string: "https://vision.googleapis.com/v1/images:annotate?key=\(googleAPIKey)")!
    }
    
    // Google vision api
    func fetchGoogleVision(with imageBase64: String) {
        // Create api request
        var request = URLRequest(url: googleURL)
        request.httpMethod = "POST"
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(Bundle.main.bundleIdentifier ?? "", forHTTPHeaderField: "X-Ios-Bundle-Identifier")
        
        
        request.httpBody = getJsonRequestData(imageBase64)
        
        // Run the request on a background thread
        DispatchQueue.global().async { self.runRequestOnBackgroundThread(request) }
    }
    
    // Generate Json request
    private func getJsonRequestData(_ imageBase64: String) -> Data? {
        // Create Json object
        let jsonRequest = [
            "requests": [
                "image": [
                    "content": imageBase64
                ],
                "features": [
                    [
                        "type": "LABEL_DETECTION",
                        "maxResults": 10
                    ]
                ]
            ]
        ]
        
        // Serialize the JSON
        let data = try? JSONSerialization.data(withJSONObject: jsonRequest)
        
        return data
    }

    // Fetch Google vision API data
    func runRequestOnBackgroundThread(_ request: URLRequest) {
        // Run the request
        let task: URLSessionDataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            // Check for valid response with 200 (success)
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                self.delegate?.photoNotRecognized(reason: .networkRequestFailed)
                
                return
            }
            
            // Ensure data is non-nil
            guard let data = data else {
                self.delegate?.photoNotRecognized(reason: .noData)
                
                return
            }
            
            // Get response json results from Google
            DispatchQueue.main.async(execute: {
                self.analyzeResults(data)
            })
        }

        task.resume()
    }
    
    // Guard let: Get response json results from Google, and write results to GoogleVisionResult
    func analyzeResults(_ dataToParse: Data) {
        
        // Decode google vision response data
        let googleVisionResults = try? JSONDecoder().decode(GoogleVisionResult.self, from: dataToParse)
        
        //Ensure json structure matches our expections and contains a google vision results
        guard let jsonGoogleVisionResults = googleVisionResults else {
            self.delegate?.photoNotRecognized(reason: .badJSONResponse)
            
            return
        }
        
        // Get the array of responses
        let responses = jsonGoogleVisionResults.googleVisionResponses
        // Extract label annatations
        let labelAnnotations = responses[0].labelAnnotations
        // Ensure label annotations contains
        guard let labels = labelAnnotations else {
            self.delegate?.photoNotRecognized(reason: .noLabel)
            
            return
        }
        
        // Check the number of labels get
        if labels.count > 0 {
            self.delegate?.photoRecognized(results: labels)
        } else {
            self.delegate?.photoNotRecognized(reason: .noLabel)
        }
    }
}

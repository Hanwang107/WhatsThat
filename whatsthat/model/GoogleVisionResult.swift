//
//  GoogleVisionResult.swift
//  whatsthat
//
//  Created by Han on 11/14/17.
//  Copyright © 2017 han. All rights reserved.
//

import Foundation

struct GoogleVisionResult: Decodable {
    let googleVisionResponses : [GoogleVisionResponses]
    
    enum CodingKeys: String, CodingKey {
        
        case googleVisionResponses = "responses"
    }
}

struct GoogleVisionResponses: Decodable {
    let labelAnnotations : [LabelAnnotations]?
}

struct LabelAnnotations : Decodable {
    let mid : String
    let description : String
    let score : Double
}

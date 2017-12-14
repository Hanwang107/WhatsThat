//
//  Utilities.swift
//  whatsthat
//
//  Created by Han on 11/14/17.
//  Copyright © 2017 han. All rights reserved.
//

import Foundation
import SystemConfiguration
import UIKit

class ImageHelper {
    static let shareInstance = ImageHelper()
    
    //base64 encode image
    func base64EncodeImage(_ image: UIImage) -> String {
        // return type: Data
        var imagedata = UIImagePNGRepresentation(image)
        let imageSize = imagedata?.count
        
        // Resize the image if it exceeds the 2MB google API limit
        if let imageSize = imageSize, imageSize > 2097152 {
            let oldSize: CGSize = image.size
            let newSize: CGSize = CGSize(width: 800, height: oldSize.height / oldSize.width * 800)
            imagedata = resizeImage(newSize, image: image)
        }
        
        return imagedata!.base64EncodedString(options: .endLineWithCarriageReturn)
    }
    
    // Change the size of image if it exceeds limit
    func resizeImage(_ imageSize: CGSize, image: UIImage) -> Data {
        UIGraphicsBeginImageContext(imageSize)
        image.draw(in: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        let resizedImage = UIImagePNGRepresentation(newImage!)
        UIGraphicsEndImageContext()
        
        return resizedImage!
    }
    
    // Save image in the document directory
    func saveImage(image: UIImage, url: URL) {
        guard let data = UIImageJPEGRepresentation(image, 1) else {return }
        
        try? data.write(to: url)
        
    }
    
    // Resize image by mapview
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        let newSize = CGSize(width: newWidth, height: newHeight)
        UIGraphicsBeginImageContext(newSize)
        image.draw(in: CGRect(origin: CGPoint(x: 0, y: 0), size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    // Get document directory
    func getDocumentsDirectory(_ fileName: String) -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0].appendingPathComponent(_:fileName)
    }
}

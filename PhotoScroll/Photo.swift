//
//  Photo.swift
//  PhotoScroll
//
//  Created by colin.qin on 2025/5/7.
//

import UIKit
import Photos

struct Photo {
    let assetId: String
    let image: UIImage
    let creationDate: Date
    let location: CLLocation?
    
    init(assetId: String, image: UIImage, creationDate: Date, location: CLLocation? = nil) {
        self.assetId = assetId
        self.image = image
        self.creationDate = creationDate
        self.location = location
    }
}

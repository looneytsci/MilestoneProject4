//
//  Photo.swift
//  MilestoneProject4
//
//  Created by Дмитрий Головин on 18.04.2021.
//

import Foundation

class Photo: Codable {
    var image: String
    var caption: String
    
    init(caption: String, image: String) {
        self.image = image
        self.caption = caption
    }
}

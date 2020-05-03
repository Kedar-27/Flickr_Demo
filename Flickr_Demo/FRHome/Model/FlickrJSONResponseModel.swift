//
//  FlickrJSONResponseModel.swift
//  Flickr_Demo
//
//  Created by Kedar Sukerkar on 03/05/20.
//  Copyright © 2020 Kedar-27. All rights reserved.
//

import Foundation

// MARK: - FlickrJSONResponse
struct FlickrJSONResponse: Codable {
    let photos: Photos
    let stat: String
}

// MARK: - Photos
struct Photos: Codable {
    let page, pages, perpage, total: Int
    let photo: [Photo]
}

// MARK: - Photo
struct Photo: Codable {
    let id, owner, secret, server: String
    let farm: Int
    let title: String
    let ispublic, isfriend, isfamily: Int
    let urlS: String
    let heightS, widthS: Int

    enum CodingKeys: String, CodingKey {
        case id, owner, secret, server, farm, title, ispublic, isfriend, isfamily
        case urlS = "url_s"
        case heightS = "height_s"
        case widthS = "width_s"
    }
}

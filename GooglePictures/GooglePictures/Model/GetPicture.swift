//
//  GetPicture.swift
//  GooglePictures
//
//  Created by Ivan on 01.05.2024.
//

import Foundation

struct GetPicture: Decodable {
    let items: [Item]
}

struct Item: Decodable {
    let link: String
}

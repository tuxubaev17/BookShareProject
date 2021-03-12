//
//  Book.swift
//  BookShareProject
//
//  Created by Alikhan Tuxubayev on 07.03.2021.
//

import Foundation


struct Books: Codable {
    var id: Int?
    var isbn, title, author: String?
    var image: String?
//    let publishDate: String
//    let genreID: Int?
//    let createdAt, updatedAt: String`
}

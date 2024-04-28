//
//  AddSongTag.swift
//  harmoni
//
//  Created by Kyle Stokes on 4/17/24.
//

import Foundation

struct AddSongTag: Encodable {
    var songID: Int?
    var tagName: String
    var tagCategoryID: Int?
    
    enum CodingKeys: String, CodingKey {
        case songID = "tagged_song_id"
        case tagName = "new_tag_name"
        case tagCategoryID = "new_tag_category_id"
    }
}

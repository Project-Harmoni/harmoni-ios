//
//  AddManySongTags.swift
//  harmoni
//
//  Created by Kyle Stokes on 4/17/24.
//

import Foundation

struct AddManySongTags: Encodable {
    var songID: Int8?
    var tagNames: [String]
    var tagCategoryID: Int8?
    
    enum CodingKeys: String, CodingKey {
        case songID = "tagged_song_id"
        case tagNames = "new_tag_names"
        case tagCategoryID = "new_tag_category_id"
    }
}

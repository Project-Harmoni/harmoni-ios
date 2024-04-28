//
//  TagExplorer.swift
//  harmoni
//
//  Created by Kyle Stokes on 4/18/24.
//

import Foundation

struct TagExplorer {
    var genreTags: [TagDB] = []
    var moodTags: [TagDB] = []
    var instrumentsTags: [TagDB] = []
    var miscTags: [TagDB] = []
    
    var genres: [Tag] {
        genreTags.map { Tag(serverID: $0.id, name: $0.name, category: .genres) }
    }
    
    var moods: [Tag] {
        moodTags.map { Tag(serverID: $0.id, name: $0.name, category: .moods) }
    }
    
    var instruments: [Tag] {
        instrumentsTags.map { Tag(serverID: $0.id, name: $0.name, category: .instruments) }
    }
    
    var misc: [Tag] {
        miscTags.map { Tag(serverID: $0.id, name: $0.name, category: .miscellaneous) }
    }
}

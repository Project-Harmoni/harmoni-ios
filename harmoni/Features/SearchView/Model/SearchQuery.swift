//
//  SearchQuery.swift
//  harmoni
//
//  Created by Kyle Stokes on 4/7/24.
//

import Foundation

struct SearchQuery {
    var query: String = ""
    var songTitle: String = ""
    var albumTitle: String = ""
    var artistName: String = ""
    var genreTags: [Tag] = []
    var moodTags: [Tag] = []
    var instrumentsTags: [Tag] = []
    var miscTags: [Tag] = []
    
    init(query: String) {
        self.query = query
    }
    
    init(filters: SearchFilterViewModel) {
        self.songTitle = filters.songTitle
        self.albumTitle = filters.albumTitle
        self.artistName = filters.artistName
        self.genreTags = filters.genreTagsViewModel.tags
        self.moodTags = filters.moodTagsViewModel.tags
        self.instrumentsTags = filters.instrumentsTagsViewModel.tags
        self.miscTags = filters.miscTagsViewModel.tags
    }
    
    var value: String {
        return "*" + query + "*"
    }
    
    var tagValue: [String] {
        [query]
    }
    
    var advancedSongTitleValue: String {
        "*" + songTitle + "*"
    }
    
    var advancedAlbumTitleValue: String {
        "*" + albumTitle + "*"
    }
    
    var advancedArtistNameValue: String {
        "*" + artistName + "*"
    }
    
    var genreTagsQuery: [String] {
        genreTags.map { $0.name }
    }
    
    var moodTagsQuery: [String] {
        moodTags.map { $0.name }
    }
    
    var instrumentsTagsQuery: [String] {
        instrumentsTags.map { $0.name }
    }
    
    var miscTagsQuery: [String] {
        miscTags.map { $0.name  }
    }
    
    var isAdvancedSongTitleAvailable: Bool {
        songTitle.trimmingCharacters(in: .whitespacesAndNewlines).isNotEmpty
    }
    
    var isAdvancedAlbumTitleAvailable: Bool {
        albumTitle.trimmingCharacters(in: .whitespacesAndNewlines).isNotEmpty
    }
    
    var isAdvancedArtistNameAvailable: Bool {
        artistName.trimmingCharacters(in: .whitespacesAndNewlines).isNotEmpty
    }
}

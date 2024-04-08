//
//  SearchResults.swift
//  harmoni
//
//  Created by Kyle Stokes on 4/7/24.
//

import Foundation

struct SearchResults {
    /// Songs that match search query
    var songs: [Song]
    /// Songs that are associated with tag(s)
    var songsWithTags: [Song]
    /// Albums that match search query
    var albums: [AlbumDB]
    /// Artists that match search query
    var artists: [ArtistDB]
}

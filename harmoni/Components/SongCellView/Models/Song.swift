//
//  Song.swift
//  harmoni
//
//  Created by Kyle Stokes on 4/12/24.
//

import Foundation

struct Song: Identifiable {
    let id = UUID()
    var details: SongDB
    var artistName: String
    var albumID: Int8? = nil
}

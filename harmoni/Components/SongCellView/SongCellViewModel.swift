//
//  SongCellViewModel.swift
//  harmoni
//
//  Created by Kyle Stokes on 4/12/24.
//

import Foundation

class SongCellViewModel: ObservableObject {
    private let database: DBServiceProviding = DBService()
    var song: Song
    var isDetailed: Bool = true
    
    init(
        song: Song,
        isDetailed: Bool = false
    ) {
        self.song = song
        self.isDetailed = isDetailed
    }
}

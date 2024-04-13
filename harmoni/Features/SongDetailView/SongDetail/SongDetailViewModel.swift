//
//  SongDetailViewModel.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/16/24.
//

import Foundation

class SongDetailViewModel: ObservableObject {
    @Published var song: SongDB?
    
    init(song: SongDB?) {
        self.song = song
    }
}

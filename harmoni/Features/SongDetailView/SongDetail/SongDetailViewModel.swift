//
//  SongDetailViewModel.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/16/24.
//

import Foundation

class SongDetailViewModel: ObservableObject {
    @Published var fileURL: URL?
    
    init(fileURL: URL?) {
        self.fileURL = fileURL
    }
}

//
//  EditTrackPayoutViewModel.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/22/24.
//

import Foundation

class EditTrackPayoutViewModel: ObservableObject {
    @Published var track: Track
    @Published var streamThreshold: String = ""
    @Published var isShowingEditStreamAlert: Bool = false
    
    init(track: Track) {
        self.track = track
    }
}

//
//  Tag.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/20/24.
//

import Foundation

struct Tag: Identifiable, Equatable, Hashable {
    let id = UUID()
    var serverID: Int?
    var name: String
    var category: TagCategory
}
// MARK: - Filter specific categories

extension [Tag] {
    var genres: [Tag] {
        self.filter { $0.category == .genres }
    }
    
    var moods: [Tag] {
        self.filter { $0.category == .moods }
    }
    
    var instruments: [Tag] {
        self.filter { $0.category == .instruments }
    }
    
    var misc: [Tag] {
        self.filter { $0.category == .miscellaneous }
    }
}

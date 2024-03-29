//
//  Tag.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/20/24.
//

import Foundation

struct Tag: Identifiable, Equatable {
    let id = UUID()
    var name: String
    var category: TagCategory
    var createdAt: Date?
}

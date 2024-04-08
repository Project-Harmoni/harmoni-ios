//
//  SearchQuery.swift
//  harmoni
//
//  Created by Kyle Stokes on 4/7/24.
//

import Foundation

struct SearchQuery {
    var query: String
    var tags: [String] {
        let tags = query
            .components(separatedBy: .whitespaces)
            .filter({ $0.hasPrefix("#") })
        return tags.map {
            var tag = $0
            tag.removeFirst()
            return tag
        }
    }
    
    var value: String {
        let queryWithoutTags = query
            .components(separatedBy: .whitespaces)
            .filter({ !$0.hasPrefix("#") })
            .joined(separator: " ")
        return "*" + queryWithoutTags + "*"
    }
}

//
//  TagExplorerViewModel.swift
//  harmoni
//
//  Created by Kyle Stokes on 4/18/24.
//

import Foundation

class TagExplorerViewModel: ObservableObject {
    let database: DBServiceProviding = DBService()
    @Published var tagExplorer: TagExplorer?
    
    init() {
        Task { @MainActor [weak self] in
            guard let self else { return }
            async let genreTags = self.getTags(for: .genres)
            async let moodTags = self.getTags(for: .moods)
            async let instrumentsTags = self.getTags(for: .instruments)
            async let miscTags = self.getTags(for: .moods)
            
            self.tagExplorer = try await TagExplorer(
                genreTags: genreTags,
                moodTags: moodTags,
                instrumentsTags: instrumentsTags,
                miscTags: miscTags
            )
        }
    }
    
    private func getTags(for category: TagCategory) async throws -> [TagDB] {
        try await self.database.tags(in: category)
    }
}

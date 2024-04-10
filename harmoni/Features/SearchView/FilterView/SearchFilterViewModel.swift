//
//  SearchFilterViewModel.swift
//  harmoni
//
//  Created by Kyle Stokes on 4/8/24.
//

import Combine
import Foundation

class SearchFilterViewModel: ObservableObject {
    @Published var areFiltersApplied: Bool = true
    @Published var songTitle: String = ""
    @Published var albumTitle: String = ""
    @Published var artistName: String = ""
    @Published var genreTagsViewModel = TagListViewModel(
        tags: [],
        category: .genres,
        isSearching: true
    )
    @Published var moodTagsViewModel = TagListViewModel(
        tags: [],
        category: .moods,
        isSearching: true
    )
    @Published var instrumentsTagsViewModel = TagListViewModel(
        tags: [],
        category: .instruments,
        isSearching: true
    )
    @Published var miscTagsViewModel = TagListViewModel(
        tags: [],
        category: .miscellaneous,
        isSearching: true
    )
    @Published var allTagsViewModel: AllTagsViewModel = AllTagsViewModel()
    
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        allTagsViewModel.genreTagsViewModel = genreTagsViewModel
        allTagsViewModel.moodTagsViewModel = moodTagsViewModel
        allTagsViewModel.instrumentsTagsViewModel = instrumentsTagsViewModel
        allTagsViewModel.miscTagsViewModel = miscTagsViewModel
        
        allTagsViewModel.genreTagsViewModel.$tags
            .receive(on: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] tags in
                guard let self else { return }
                self.genreTagsViewModel.tags = tags
            }
            .store(in: &cancellables)
        
        allTagsViewModel.moodTagsViewModel.$tags
            .receive(on: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] tags in
                guard let self else { return }
                self.moodTagsViewModel.tags = tags
            }
            .store(in: &cancellables)
        
        allTagsViewModel.instrumentsTagsViewModel.$tags
            .receive(on: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] tags in
                guard let self else { return }
                self.instrumentsTagsViewModel.tags = tags
            }
            .store(in: &cancellables)
        
        allTagsViewModel.miscTagsViewModel.$tags
            .receive(on: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] tags in
                guard let self else { return }
                self.miscTagsViewModel.tags = tags
            }
            .store(in: &cancellables)
    }
}

//
//  TagViewModel.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/20/24.
//

import Foundation

class TagListViewModel: ObservableObject {
    @Published var newTagName: String = ""
    @Published var editedTagName: String = ""
    @Published var selectedTag: Tag?
    @Published var tags: [Tag] = []
    var onChanged: (([Tag]) -> Void)?
    var isReadOnly: Bool
    var isSearching: Bool = false
    let category: TagCategory
    
    init(tags: [Tag] = [], category: TagCategory, isReadOnly: Bool = false, isSearching: Bool = false) {
        self.tags = tags
        self.category = category
        self.isReadOnly = isReadOnly
        self.isSearching = isSearching
    }
    
    func configure(with tags: [Tag], isReadOnly: Bool, isSearching: Bool) {
        self.tags = tags
        self.isReadOnly = isReadOnly
        self.isSearching = isSearching
    }
    
    func createTag() {
        guard !newTagName.isEmpty else { return }
        let tag = Tag(name: newTagName, category: category)
        tags.append(tag)
    }
    
    func editTag() {
        guard let selectedTag else { return }
        guard let index = tags.firstIndex(where: { $0 == selectedTag }) else { return }
        guard !editedTagName.isEmpty else { return }
        tags[index].name = editedTagName
    }
    
    func removeTag() {
        guard let selectedTag else { return }
        guard let index = tags.firstIndex(where: { $0 == selectedTag }) else { return }
        tags.remove(at: index)
    }
    
    var createTagTitle: String {
        let action = isSearching ? "Add" : "Create"
        return "\(action) '\(category.rawValue.capitalized)' Tag"
    }
    
    var editTagTitle: String {
        if let selectedTag {
            return "Edit '\(selectedTag.name.capitalized)'"
        } else {
            return "Edit Tag"
        }
    }
    
    var deleteTagTitle: String {
        let action = isSearching ? "Remove" : "Delete"
        if let selectedTag {
            return "\(action) '\(selectedTag.name.capitalized)'?"
        } else {
            return "\(action) Tag"
        }
    }
}

// MARK: - Equatable

extension TagListViewModel: Equatable {
    static func == (lhs: TagListViewModel, rhs: TagListViewModel) -> Bool {
        lhs.category == rhs.category &&
        lhs.tags == rhs.tags
    }
}

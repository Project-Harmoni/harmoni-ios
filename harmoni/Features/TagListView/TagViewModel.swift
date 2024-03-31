//
//  TagViewModel.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/20/24.
//

import Foundation

class TagListViewModel: ObservableObject {
    @MainActor @Published var isDisplayingCreateTagAlert: Bool = false
    @MainActor @Published var isDisplayingEditTagAlert: Bool = false
    @MainActor @Published var isDisplayingDeleteTagAlert: Bool = false
    @Published var newTagName: String = ""
    @Published var editedTagName: String = ""
    @Published var selectedTag: Tag?
    @Published var tags: [Tag] = []
    var isReadOnly: Bool
    let category: TagCategory
    
    init(tags: [Tag] = [], category: TagCategory, isReadOnly: Bool = false) {
        self.tags = tags
        self.category = category
        self.isReadOnly = isReadOnly
    }
    
    func configure(with tags: [Tag], isReadOnly: Bool) {
        self.tags = tags
        self.isReadOnly = isReadOnly
    }
    
    func createTag() {
        guard !newTagName.isEmpty else { return }
        let tag = Tag(name: newTagName, category: category, createdAt: .now)
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
        "Create '\(category.rawValue.capitalized)' Tag"
    }
    
    var editTagTitle: String {
        if let selectedTag {
            return "Edit '\(selectedTag.name.capitalized)'"
        } else {
            return "Edit Tag"
        }
    }
    
    var deleteTagTitle: String {
        if let selectedTag {
            return "Delete '\(selectedTag.name.capitalized)'?"
        } else {
            return "Delete Tag"
        }
    }
}

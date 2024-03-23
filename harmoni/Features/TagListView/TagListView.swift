//
//  TagListView.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/18/24.
//

import SwiftUI
import WrappingStack

struct TagListView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var viewModel: TagListViewModel
    
    var body: some View {
        tags
            .alert(
                viewModel.createTagTitle,
                isPresented: $viewModel.isDisplayingCreateTagAlert
            ) {
                TextField("Name", text: $viewModel.newTagName)
                Button("Cancel", role: .cancel, action: {})
                Button("Create", role: .none, action: {
                    viewModel.createTag()
                })
            } message: {}
            .alert(
                viewModel.editTagTitle,
                isPresented: $viewModel.isDisplayingEditTagAlert
            ) {
                TextField("Edit name", text: $viewModel.editedTagName)
                Button("Cancel", role: .cancel, action: {})
                Button("Delete", role: .destructive, action: {
                    viewModel.isDisplayingDeleteTagAlert.toggle()
                })
                Button("Save", role: .none, action: {
                    viewModel.editTag()
                })
            } message: {}
            .alert(
                viewModel.deleteTagTitle,
                isPresented: $viewModel.isDisplayingDeleteTagAlert
            ) {
                Button("Cancel", role: .cancel, action: {})
                Button("Delete", role: .destructive, action: {
                    viewModel.removeTag()
                })
            } message: {}
    }
    
    private var tags: some View {
        HStack(alignment: .top) {
            createNewTag
            WrappingHStack(
                alignment: .leading,
                horizontalSpacing: 8,
                verticalSpacing: 16
            ) {
                ForEach(viewModel.tags) { tag in
                    chip(for: tag)
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private func chip(for tag: Tag) -> some View {
        Button {
            viewModel.selectedTag = tag
            viewModel.editedTagName = tag.name
            viewModel.isDisplayingEditTagAlert.toggle()
        } label: {
            Text(tag.name)
        }
        .buttonStyle(.bordered)
        .clipShape(RoundedRectangle(cornerRadius: 25))
    }
    
    private var createNewTag: some View {
        Button {
            viewModel.newTagName = ""
            viewModel.isDisplayingCreateTagAlert.toggle()
        } label: {
            Image(systemName: "plus")
                .foregroundStyle(colorScheme == .dark ? .black : .white)
        }
        .buttonStyle(.borderedProminent)
        .clipShape(Circle())
        .tint(.secondary)
    }
}

#Preview {
    TagListView(
        viewModel: TagListViewModel(
            tags: [
                Tag(name: "Test", category: .genres, createdAt: .now),
                Tag(name: "Test2", category: .genres, createdAt: .now),
                Tag(name: "Test3", category: .genres, createdAt: .now),
                Tag(name: "Test4", category: .genres, createdAt: .now)
            ],
            category: .genres
        )
    )
}

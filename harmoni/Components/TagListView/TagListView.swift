//
//  TagListView.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/18/24.
//

import SwiftUI
import WrappingStack

struct TagListView: View {
    @EnvironmentObject private var uploadStore: UploadStore
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
                Button(isSearching ? "Add" : "Create", role: .none, action: {
                    viewModel.createTag()
                })
            } message: {}
            .alert(
                viewModel.editTagTitle,
                isPresented: $viewModel.isDisplayingEditTagAlert
            ) {
                TextField("Edit name", text: $viewModel.editedTagName)
                Button("Cancel", role: .cancel, action: {})
                Button(isSearching ? "Remove" : "Delete", role: .destructive, action: {
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
                Button(isSearching ? "Remove" : "Delete", role: .destructive, action: {
                    viewModel.removeTag()
                })
            } message: {}
            .onChange(of: viewModel.tags) { _, tags in
                switch viewModel.category {
                case .genres:
                    uploadStore.genreTagsViewModel.tags = tags
                case .moods:
                    uploadStore.moodTagsViewModel.tags = tags
                case .instruments:
                    uploadStore.instrumentsTagsViewModel.tags = tags
                case .miscellaneous:
                    uploadStore.miscTagsViewModel.tags = tags
                }
            }
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
                .foregroundStyle(viewModel.isReadOnly ? Color.primary : .blue)
        }
        .buttonStyle(.bordered)
        .clipShape(RoundedRectangle(cornerRadius: 25))
        .disabled(viewModel.isReadOnly)
    }
    
    @ViewBuilder
    private var createNewTag: some View {
        if !viewModel.isReadOnly {
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
    
    private var isSearching: Bool {
        viewModel.isSearching
    }
}

#Preview {
    TagListView(
        viewModel: TagListViewModel(
            tags: [
                Tag(name: "Test", category: .genres),
                Tag(name: "Test2", category: .genres),
                Tag(name: "Test3", category: .genres),
                Tag(name: "Test4", category: .genres)
            ],
            category: .genres
        )
    )
}

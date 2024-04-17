//
//  MyUploadsView.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/27/24.
//

import AlertToast
import SwiftUI

struct MyUploadsView: View {
    @EnvironmentObject var router: AccountViewRouter
    @Environment(\.editMode) var editMode
    @Environment(\.currentUser) private var currentUser
    @StateObject private var viewModel = MyUploadsViewModel()
    
    var body: some View {
        uploads
            .task {
                viewModel.currentUser = currentUser
                await viewModel.getAlbums()
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if !viewModel.albums.isEmpty {
                        EditButton()
                            .disabled(viewModel.isDeleting)
                    }
                }
            }
            .alert("Delete Albums", isPresented: $viewModel.isShowingDeleteConfirm) {
                Button("Cancel", role: .cancel, action: {})
                Button("Delete", role: .destructive, action: {
                    viewModel.deleteSelected()
                })
            } message: {
                Text("Are you sure you want to delete the selected albums?")
            }
            .toast(
                isPresenting: $viewModel.isDeleted,
                duration: 2,
                tapToDismiss: true,
                alert: {
                    AlertToast(type: .complete(.green), title: "Deleted")
                }, completion: {
                    Task {
                        await viewModel.reload()
                    }
                }
            )
            .toast(isPresenting: $viewModel.isDeleting) {
                AlertToast(
                    type: .loading,
                    title: "Deleting"
                )
            }
            .navigationTitle("My Uploads")
            .safeAreaInset(edge: .bottom) {
                if !viewModel.albums.isEmpty, isEditing {
                    HStack {
                        deleteSelected
                        Spacer()
                        selectionToggle
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                }
            }
    }
    
    @ViewBuilder
    private var uploads: some View {
        if viewModel.isLoading {
            ProgressView()
        } else if viewModel.albums.isEmpty {
            Text("**No uploads!** Come back after you've uploaded something.")
                .multilineTextAlignment(.center)
        } else {
            albumList
        }
    }
    
    private var albumList: some View {
        List(selection: $viewModel.selectedAlbums) {
            ForEach(viewModel.albums) { album in
                AlbumCellView(
                    viewModel: AlbumViewModel(
                        album: album,
                        onDelete: {
                            Task {
                                await viewModel.reload()
                            }
                        }
                    )
                )
            }
        }
    }
    
    @ViewBuilder
    private var deleteSelected: some View {
        if isSelected {
            Button {
                viewModel.isShowingDeleteConfirm.toggle()
            } label: {
                Text("Delete Selected")
                    .padding()
                    .frame(height: 32)
                    .background(.red)
                    .foregroundStyle(.white)
                    .bold()
                    .clipShape(RoundedRectangle(cornerRadius: 25))
            }
            .disabled(viewModel.isDeleting)
        }
    }
    
    @ViewBuilder
    private var selectionToggle: some View {
        if isEditing {
            Button(viewModel.isSelectingAll ? "Select All" : "Deselect All") {
                if viewModel.isSelectingAll {
                    viewModel.albums.forEach { album in
                        viewModel.selectedAlbums.insert(album.id)
                    }
                } else {
                    viewModel.albums.forEach { album in
                        viewModel.selectedAlbums.remove(album.id)
                    }
                }
                
                viewModel.isSelectingAll.toggle()
            }
            .disabled(viewModel.isDeleting)
            .bold()
            .onAppear() {
                viewModel.isSelectingAll = true
            }
        }
    }
    
    private var isEditing: Bool {
        guard let editMode = editMode?.wrappedValue else { return false }
        return editMode.isEditing
    }
    
    private var isSelected: Bool {
        isEditing && !viewModel.selectedAlbums.isEmpty
    }
}

#Preview {
    MyUploadsView()
}

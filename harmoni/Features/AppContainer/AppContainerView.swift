//
//  AppContainerView.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/9/24.
//

import AlertToast
import SwiftUI
import Supabase

/// Root level container for all views
struct AppContainerView: View {
    @EnvironmentObject var nowPlayingManager: NowPlayingManager
    @State private var user: User?
    @StateObject var viewModel = AppContainerViewModel()
    
    init() {
      UITextField.appearance().clearButtonMode = .whileEditing
    }
    
    var body: some View {
        TabView {
            Group {
                AccountView()
                    .tabItem {
                        Image(systemName: "person.crop.circle")
                        Text("Account")
                    }
                
                NavigationStack {
                    LibraryView()
                        .navigationTitle("Library")
                }
                .tabItem {
                    Image(systemName: "music.note")
                    Text("Library")
                }
                
                SearchView()
                    .tabItem {
                        Image(systemName: "magnifyingglass")
                        Text("Search")
                    }
            }
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    nowPlayingBar
                }
            }
        }
        .toast(
            isPresenting: $viewModel.isPresentingSuccessToast,
            duration: 2,
            tapToDismiss: true,
            alert: {
                AlertToast(type: .complete(.green), title: viewModel.successToastTitle)
            }, completion: {
                viewModel.successToastCompletion?()
            }
        )
        .toast(isPresenting: $viewModel.isPresentingLoadingToast) {
            AlertToast(
                type: .loading,
                title: viewModel.loadingToastTitle
            )
        }
        .environment(\.isAdmin, viewModel.isAdmin)
        .environment(\.isArtist, viewModel.isArtist)
        .environment(\.isNew, viewModel.isNew)
        .environment(\.isAdult, viewModel.isAdult)
        .environment(\.currentUser, viewModel.currentUser)
        .environment(\.container, viewModel)
    }
    
    @ViewBuilder
    private var nowPlayingBar: some View {
        if nowPlayingManager.song != nil {
            viewModel.nowPlayingBar
        }
    }
}

#Preview {
    AppContainerView()
}

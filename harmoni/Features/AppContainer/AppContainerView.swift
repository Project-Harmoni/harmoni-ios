//
//  AppContainerView.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/9/24.
//

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
                    Text("Library")
                        .navigationTitle("Library")
                }
                .tabItem {
                    Image(systemName: "music.note")
                    Text("Library")
                }
                
                NavigationStack {
                    SearchView()
                        .navigationTitle("Search")
                }
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
        .environment(\.isAdmin, viewModel.isAdmin)
        .environment(\.isArtist, viewModel.isArtist)
        .environment(\.currentUser, viewModel.currentUser)
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

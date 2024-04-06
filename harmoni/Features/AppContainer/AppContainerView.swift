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
            AccountView()
                .tabItem {
                    Image(systemName: "person.crop.circle")
                    Text("Account")
                }
                .toolbar {
                    ToolbarItem(placement: .bottomBar) {
                        if nowPlayingManager.song != nil {
                            NowPlayingBar()
                        }
                    }
                }
            
            NavigationStack {
                Text("Library")
                    .navigationTitle("Library")
            }
            .tabItem {
                Image(systemName: "music.note")
                Text("Library")
            }
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    if nowPlayingManager.song != nil {
                        NowPlayingBar()
                    }
                }
            }
            
            NavigationStack {
                Text("Search")
                    .navigationTitle("Search")
            }
            .tabItem {
                Image(systemName: "magnifyingglass")
                Text("Search")
            }
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    if nowPlayingManager.song != nil {
                        NowPlayingBar()
                    }
                }
            }
        }
        .environment(\.isAdmin, viewModel.isAdmin)
        .environment(\.isArtist, viewModel.isArtist)
        .environment(\.currentUser, viewModel.currentUser)
    }
}

#Preview {
    AppContainerView()
}

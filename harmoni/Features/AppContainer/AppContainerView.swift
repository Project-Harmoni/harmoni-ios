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
            
            NavigationStack {
                Text("Library")
                    .navigationTitle("Library")
            }
            .tabItem {
                Image(systemName: "music.note")
                Text("Library")
            }
            
            NavigationStack {
                Text("Search")
                    .navigationTitle("Search")
            }
            .navigationTitle("Search")
            .tabItem {
                Image(systemName: "magnifyingglass")
                Text("Search")
            }
        }
        .environment(\.isAdmin, viewModel.isAdmin)
        .environment(\.isArtist, viewModel.isArtist)
        .environment(\.isNew, viewModel.isNew)
        .environment(\.currentUser, viewModel.currentUser)
    }
}

#Preview {
    AppContainerView()
}

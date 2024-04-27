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
    @StateObject var viewModel = AppContainerViewModel.shared
    
    init() {
      UITextField.appearance().clearButtonMode = .whileEditing
    }
    
    var body: some View {
        TabView(selection: $viewModel.selectedTab) {
            Group {
                AccountView()
                    .tabItem {
                        Image(systemName: "person.crop.circle")
                        Text("Account")
                    }
                    .tag(0)
                
                if let _ = viewModel.currentUser {
                    NavigationStack {
                        LibraryView()
                            .navigationTitle("Library")
                    }
                    .tabItem {
                        Image(systemName: "music.note")
                        Text("Library")
                    }
                    .tag(1)
                }
                
                SearchView()
                    .tabItem {
                        Image(systemName: "magnifyingglass")
                        Text("Search")
                    }
                    .tag(2)
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
        .toast(
            isPresenting: $viewModel.isPresentingImageToast,
            duration: 1,
            tapToDismiss: true,
            alert: {
                AlertToast(
                    type: .systemImage(viewModel.imageToastSystemName, .primary),
                    title: viewModel.imageToastTitle
                )
            }, completion: {
                viewModel.imageToastCompletion?()
            }
        )
        .toast(isPresenting: $viewModel.isPresentingLoadingToast) {
            AlertToast(
                type: .loading,
                title: viewModel.loadingToastTitle
            )
        }
        .alert(
            viewModel.alertTitle,
            isPresented: $viewModel.isPresentingAlert,
            actions: {
                Button("OK", role: .none, action: {})
            }, message: {
                Text(viewModel.alertMessage)
            }
        )
        .environmentObject(nowPlayingManager)
        .environment(\.container, viewModel)
        .environment(\.currentUser, viewModel.currentUser)
        .environment(\.isAdmin, viewModel.isAdmin)
        .environment(\.isAdult, viewModel.isAdult)
        .environment(\.isArtist, viewModel.isArtist)
        .environment(\.isNew, viewModel.isNew)
        .environment(\.platformConstants, viewModel.platformConstants)
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

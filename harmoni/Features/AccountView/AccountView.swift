//
//  AccountView.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/9/24.
//

import Supabase
import SwiftUI

struct AccountView: View {
    @Environment(\.isArtist) private var isArtist
    @Environment(\.isAdmin) private var isAdmin
    @StateObject var viewModel = AccountViewModel()
    
    var body: some View {
        NavigationStack {
            if true { // isAuthorized {
                accountView
            } else {
                AuthView()
            }
        }
    }
    
    @ViewBuilder
    private var accountView: some View {
        Form {
            Section(contactInfoSectionTitle) {
                name
                email
            }
            
            if true { //isArtist {
                artistView
            }
            
            Section("Wallet") {
                HStack {
                    Text("Token Balance")
                    Spacer()
                    Text("10,000")
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Circle()
                    .frame(height: 34)
                    .foregroundStyle(.gray)
                    .overlay {
                        Image(systemName: "photo")
                            .resizable()
                            .padding(7)
                            .scaledToFit()
                            .foregroundStyle(.white)
                    }
            }
            ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.isEditing.toggle()
                    } label: {
                        Text(isEditing ? "Save" : "Edit")
                            .padding(.horizontal, isEditing ? 12 : 0)
                            .padding(.vertical, isEditing ? 4 : 0)
                            .tint(isEditing ? .white : .blue)
                            .background(isEditing ? .blue : .clear)
                            .clipShape(RoundedRectangle(cornerRadius: 25))
                    }
            }
            if !isEditing {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            Task {
                                await AuthManager.shared.logout()
                            }
                        } label: {
                            Text("Sign Out")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private var artistView: some View {
        Section("Artist") {
            HStack {
                Text("Name")
                Spacer()
                Text("Bliss Nova")
            }
            HStack(spacing: 32) {
                Text("Bio")
                Spacer()
                Text("Really great stuff yada yada yada yada yada yada yada yada yada yada yada yada yada yada yada yada yada yada yada yada yada yada yada yada yada yada yada yada yada yada yada yada yada yada yada yada yada yada yada yada yada yada yada yada yada yada yada yada yada yada yada yada yada yada yada yada yada yada yada yada yada yada")
                    .lineLimit(2)
            }
            HStack {
                Text("Website")
                Spacer()
                Text("www.google.com")
            }
            uploadView
        }
    }
    
    @ViewBuilder
    private var uploadView: some View {
        NavigationLink("Upload Track(s)") {
            UploadView()
        }
        .foregroundStyle(.blue)
    }
}

// MARK: - Helpers

private extension AccountView {
    var user: User? {
        viewModel.user
    }
    
    var listener: ListenerDB? {
        viewModel.listener
    }
    
    var artist: ArtistDB? {
        viewModel.artist
    }
    
    var isSignedIn: Bool {
        viewModel.isSignedIn
    }
    
    var isListener: Bool {
        !isArtist
    }
    
    var isEditing: Bool {
        viewModel.isEditing
    }
    
    var isRegistrationComplete: Bool {
        viewModel.isRegistrationComplete
    }
    
    var isAuthorized: Bool {
        true //isSignedIn && isRegistrationComplete && user != nil
    }
}

// MARK: - View Builders

private extension AccountView {
    @ViewBuilder
    private var name: some View {
        if isListener {
            HStack {
                Image(systemName: "person")
                Spacer()
                Text(nameLabel)
            }
        }
    }
    
    private var email: some View {
        HStack {
            Image(systemName: "envelope")
            Spacer()
            Text(emailLabel)
        }
    }
}

// MARK: - View Label Helpers

private extension AccountView {
    var nameLabel: String {
        if let name = artist?.name {
            return name
        } else if let name = listener?.name {
            return name
        } else {
            return ""
        }
    }
    
    var emailLabel: String {
        user?.email ?? ""
    }
    
    var contactInfoSectionTitle: String {
        isArtist ? "Contact" : "Listener"
    }
}

#Preview {
    AccountView()
}

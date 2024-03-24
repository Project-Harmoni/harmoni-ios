//
//  AccountView.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/9/24.
//

import PhotosUI
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
                listenerName
                email
            }
            
            if true { //isArtist {
                artistView
            }
            
            Section("Wallet") {
                wallet
            }
            
            Section {
                NavigationLink("Settings") {
                    SettingsView()
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
               profilePictureView
            }
            ToolbarItem(placement: .topBarTrailing) {
                actionButton
            }
            if !isEditing {
                ToolbarItem(placement: .topBarTrailing) {
                    menu
                }
            }
        }
    }
    
    @ViewBuilder
    private var artistView: some View {
        Section("Artist") {
            artistName
            artistBio
            artistWebsite
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
    private var profilePictureView: some View {
        ZStack {
            Circle()
                .frame(height: 34)
                .foregroundStyle(.gray)
                .overlay {
                    profileImage
                }
            profileImagePicker
        }
    }
    
    @ViewBuilder
    private var profileImage: some View {
        AsyncImage(url: viewModel.profileImage) { image in
            switch image {
            case .empty:
                profileImagePlaceholder
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
                    .clipShape(Circle())
            case .failure(_):
                profileImagePlaceholder
            @unknown default:
                profileImagePlaceholder
            }
        }
    }
    
    private var profileImagePlaceholder: some View {
        Image(systemName: "photo")
            .resizable()
            .padding(7)
            .scaledToFit()
            .foregroundStyle(.white)
    }
    
    private var profileImagePicker: some View {
        PhotosPicker(
            "",
            selection: $viewModel.profileImageItem,
            matching: .images,
            photoLibrary: .shared()
        )
        .labelsHidden()
    }
    
    private var actionButton: some View {
        Button {
            viewModel.actionButtonTapped()
        } label: {
            Text(isEditing ? "Save" : "Edit")
                .padding(.horizontal, isEditing ? 12 : 0)
                .padding(.vertical, isEditing ? 4 : 0)
                .tint(isEditing ? .white : .blue)
                .background(isEditing ? .blue : .clear)
                .clipShape(RoundedRectangle(cornerRadius: 25))
        }
    }
    
    private var menu: some View {
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
    
    @ViewBuilder
    private var listenerName: some View {
        if isListener {
            HStack {
                Image(systemName: "person")
                Spacer()
                nameBuilder
            }
        }
    }
    
    private var artistName: some View {
        HStack {
            Text("Name")
            Spacer()
            nameBuilder
        }
    }
    
    private var artistBio: some View {
        HStack(spacing: 32) {
            Text("Bio")
            Spacer()
            if isEditing {
                ZStack(alignment: .trailing) {
                    TextEditor(text: $viewModel.bio)
                    Text("Bio")
                        .foregroundStyle(.gray.secondary)
                        .opacity(viewModel.bio.isEmpty ? 1 : 0)
                        .allowsHitTesting(false)
                        .padding(.trailing, 4)
                        .padding(.bottom, 14)
                }
                .multilineTextAlignment(.trailing)
            } else {
                Text(bioLabel)
                    .lineLimit(2)
                    .foregroundStyle(.gray)
            }
        }
    }
    
    private var artistWebsite: some View {
        HStack {
            Text("Website")
            Spacer()
            if isEditing {
                TextField("Website", text: $viewModel.website)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.URL)
                    .multilineTextAlignment(.trailing)
            } else {
                Text(websiteLabel)
                    .foregroundStyle(.gray)
            }
        }
    }
    
    @ViewBuilder
    private var nameBuilder: some View {
        if isEditing {
            TextField("Name", text: $viewModel.name)
                .textInputAutocapitalization(.words)
                .multilineTextAlignment(.trailing)
        } else {
            Text(nameLabel)
                .foregroundStyle(.gray)
        }
    }
    
    private var email: some View {
        HStack {
            Image(systemName: "envelope")
            Spacer()
            Text(emailLabel)
                .foregroundStyle(.gray)
        }
    }
    
    private var wallet: some View {
        HStack {
            Text("Token Balance")
            Spacer()
            Text("\(viewModel.tokens)")
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
    
    var bioLabel: String {
        artist?.biography ?? ""
    }
    
    var websiteLabel: String {
        artist?.socialLinkURL ?? ""
    }
    
    var contactInfoSectionTitle: String {
        isArtist ? "Contact" : "Listener"
    }
}

#Preview {
    AccountView()
}

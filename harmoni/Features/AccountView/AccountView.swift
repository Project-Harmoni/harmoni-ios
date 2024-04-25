//
//  AccountView.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/9/24.
//

import Kingfisher
import PhotosUI
import StoreKit
import Supabase
import SwiftUI

struct AccountView: View {
    @Environment(\.isArtist) private var isArtist
    @Environment(\.isAdmin) private var isAdmin
    @StateObject private var viewModel = AccountViewModel()
    @StateObject private var router = AccountViewRouter()
    
    var body: some View {
        NavigationStack(path: $router.path) {
            if isAuthorized {
                accountView
            } else {
                AuthView() {
                    Task {
                        await viewModel.handleAccountData()
                    }
                }
            }
        }
        .environmentObject(router)
    }
    
    @ViewBuilder
    private var accountView: some View {
        Form {
            Section(contactInfoSectionTitle) {
                listenerName
                email
            }
            
            if isArtist {
                artistView
            }
            
            Section("Wallet") {
                wallet
                Button {
                    viewModel.isDisplayingTokenPurchase.toggle()
                } label: {
                    Text("Buy Tokens")
                }

            }
            
            Section {
                NavigationLink("Settings") {
                    SettingsView(
                        viewModel: .init(
                            logoutAction: viewModel.logout
                        )
                    )
                }
            }
        }
        .refreshable {
            await viewModel.handleAccountData()
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                profilePictureView
            }
            ToolbarItemGroup(placement: .topBarTrailing) {
                actionButton
                if !isEditing { menu }
            }
        }
        .navigationTitle("Account")
        .alert("Uh Oh!", isPresented: $viewModel.isError) {
            Button("OK", role: .none, action: {})
        } message: {
            Text("Hm, that didn't work. Please try again.")
        }
        .sheet(isPresented: $viewModel.isDisplayingWelcomeView) {
            WelcomeView()
        }
        .sheet(isPresented: $viewModel.isDisplayingTokenPurchase) {
            VStack(alignment: .leading) {
                Text("Buy")
                    .font(.title2)
                    .bold()
                    .padding()
                    .padding(.bottom, -16)
                ForEach(["com.harmoni.test.1000.tokens"], id: \.self) { id in
                    ProductView(id: id) {
                        Image(systemName: "music.quarternote.3")
                    }
                    .productViewStyle(.compact)
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
            .presentationBackground(.thinMaterial)
            .presentationCornerRadius(24)
            .presentationDragIndicator(.visible)
            .presentationDetents([.fraction(0.2)])
        }
        .onInAppPurchaseCompletion { product, result in
            if case .success(.success(_)) = result {
                viewModel.purchaseTokens()
            } else {
                viewModel.isDisplayingTokenPurchase.toggle()
            }
        }
        .navigationDestination(for: AccountViewPath.self) { destination in
            switch destination {
            case .uploader: UploadView()
            case .myUploads: MyUploadsView()
            case .albums: Text("Albums")
            case .tags: Text("Tags")
            }
        }
    }
    
    @ViewBuilder
    private var artistView: some View {
        Section("Artist") {
            artistName
            artistBio
            artistWebsite
        }
        
        Section("Music") {
            myUploads
            uploadView
        }
    }
    
    @ViewBuilder
    private var uploadView: some View {
        NavigationLink("New Upload", value: AccountViewPath.uploader)
            .foregroundStyle(.blue)
    }
    
    private var myUploads: some View {
        NavigationLink("My Uploads", value: AccountViewPath.myUploads)
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
        isSignedIn && isRegistrationComplete && user != nil
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
        if let image = viewModel.justChangedProfileImage {
            image
                .resizable()
                .scaledToFill()
                .clipShape(Circle())
        } else {
            if let url = viewModel.profileImage {
                KFImage(url)
                    .placeholder {
                        profileImagePlaceholder
                    }
                    .cancelOnDisappear(true)
                    .resizable()
                    .scaledToFill()
                    .clipShape(Circle())
            } else {
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
                    await viewModel.logout()
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
            Text(tokenBalance)
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
    
    var tokenBalance: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        return formatter.string(from: NSNumber(value: viewModel.tokens)) ?? "0.00"
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

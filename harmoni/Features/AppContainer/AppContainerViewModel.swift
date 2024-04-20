//
//  AppContainerViewModel.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/9/24.
//

import Combine
import Foundation
import Supabase

class AppContainerViewModel: ObservableObject {
    @Published var isPresentingLoadingToast: Bool = false
    @Published var isPresentingSuccessToast: Bool = false
    @Published var isPresentingImageToast: Bool = false
    @Published var imageToastSystemName: String = ""
    @Published var imageToastTitle: String = ""
    @Published var imageToastCompletion: (() -> Void)? = nil
    @Published var loadingToastTitle: String = ""
    @Published var successToastTitle: String = ""
    @Published var successToastCompletion: (() -> Void)? = nil
    @Published var isArtist: Bool = false
    @Published var isAdmin: Bool = false
    @Published var isNew: Bool = false
    @Published var isAdult: Bool = false
    @Published var currentUser: User?
    @Published var platformConstants: PlatformConstants = PlatformConstants()
    private var database: DBServiceProviding = DBService()
    private var userProvider: UserProviding = UserProvider()
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        AuthManager.shared.$isSignedIn
             .receive(on: DispatchQueue.main)
             .sink { [weak self] _ in
                 self?.checkPermissions()
             }
             .store(in: &cancellables)
        
        AuthManager.shared.$isRegistrationComplete
             .receive(on: DispatchQueue.main)
             .sink { [weak self] isComplete in
                 guard let isComplete, isComplete else { return }
                 self?.checkPermissions()
             }
             .store(in: &cancellables)
        
        getPlatformConstants()
    }
    
    private func getPlatformConstants() {
        Task { @MainActor [weak self] in
            guard let self else { return }
            self.platformConstants = try await self.database.getPlatformConstants() ?? PlatformConstants()
        }
    }
    
    private func checkPermissions() {
        Task { @MainActor [weak self] in
            self?.isArtist = await self?.userProvider.isArtist ?? false
            self?.isAdmin = await self?.userProvider.isAdmin ?? false
            self?.isNew = await self?.userProvider.isNew ?? false
            self?.isAdult = await self?.userProvider.isAdult ?? false
            self?.currentUser = await self?.userProvider.currentUser
        }
    }
    
    func isPresentingLoadingToast(title: String) {
        loadingToastTitle = title
        isPresentingLoadingToast.toggle()
    }
    
    func isPresentingSuccessToast(title: String, with completion: (() -> Void)? = nil) {
        isPresentingLoadingToast = false
        successToastTitle = title
        isPresentingSuccessToast.toggle()
        successToastCompletion = completion
    }
    
    func isPresentingImageToast(
        systemName: String,
        title: String,
        with completion: (() -> Void)? = nil
    ) {
        isPresentingLoadingToast = false
        imageToastSystemName = systemName
        imageToastTitle = title
        isPresentingImageToast.toggle()
        imageToastCompletion = completion
    }
    
    lazy var nowPlayingBar: NowPlayingBar = {
        NowPlayingBar()
    }()
}

//
//  UploadViewModel.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/16/24.
//

import Combine
import PhotosUI
import SwiftUI

class UploadViewModel: ObservableObject {
    @MainActor @Published var isShowingFileImporter: Bool = false
    @MainActor @Published var isShowingNamePopover: Bool = false
    @MainActor @Published var currentArtistName: String = ""
    @MainActor @Published var payoutThreshold: Int = 0
    @MainActor @Published var listenerPayoutPercentage: Double = 20
    @MainActor @Published var isError: Bool = false
    
    // Upload Store
    @MainActor @Published var uploadStore: UploadStore = UploadStore()
    @MainActor @Published var albumTitle: String = "" {
        didSet {
            uploadStore.albumTitle = albumTitle
        }
    }
    @MainActor @Published var artistName: String = "" {
        didSet {
            uploadStore.artistName = artistName
        }
    }
    @MainActor @Published var isExplicit: Bool = false {
        didSet {
            uploadStore.isExplicit = isExplicit
        }
    }
    @MainActor @Published var yearReleased: String = "" {
        didSet {
            uploadStore.yearReleased = yearReleased
        }
    }
    @MainActor @Published var recordLabel: String = "" {
        didSet {
            uploadStore.recordLabel = recordLabel
        }
    }
    @MainActor @Published var albumCoverItem: PhotosPickerItem? {
        didSet {
            uploadStore.albumCoverItem = albumCoverItem
        }
    }
    @MainActor @Published var albumCoverImage: Image? {
        didSet {
            uploadStore.albumCoverImage = albumCoverImage
        }
    }
    @MainActor @Published var tracks: [Track] = [] {
        didSet {
            uploadStore.tracks = tracks
            payoutViewModel.tracks = tracks
        }
    }
    
    // Payout
    @Published var payoutViewModel = EditPayoutViewModel(tracks: [])
    
    // Alerts
    @Published var isShowingDeleteTrackAlert: Bool = false
    @Published var isShowingEditTrackNameAlert: Bool = false
    @Published var editedTrackName: String = ""
    @Published var selectedTrack: Track?
    
    private let database: DBServiceProviding = DBService()
    private let userProvider: UserProviding = UserProvider()
    private let storage: StorageProviding = StorageService()
    private var cancellables: Set<AnyCancellable> = []
    let isEditingAlbum: Bool
    
    init() {
        isEditingAlbum = false
        $albumCoverItem
            .receive(on: DispatchQueue.main)
            .sink { [weak self] item in
                /// handle chosen album cover image
                self?.handle(picked: item)
            }
            .store(in: &cancellables)
        
        getArtistName()
    }
    
    /// Initializer for edit album
    init(album: AlbumDB, songs: [SongDB], tags: [TagDB]) {
        isEditingAlbum = true
    }
    
    private func getArtistName() {
        Task { @MainActor [weak self] in
            guard let self else { return }
            guard let id = await self.userProvider.currentUserID else { return }
            let name = try await self.database.getArtist(with: id)?.name ?? ""
            self.artistName = name
            self.currentArtistName = name
        }
    }
    
    func handle(_ error: Error) {
        Task { @MainActor [weak self] in
            self?.isError = true
            dump(error)
        }
    }
    
    func handle(_ files: [URL]) {
        Task { @MainActor [weak self] in
            self?.tracks = files.enumerated().map { offset, url in
                let fileExtension = ".\(url.pathExtension)"
                return Track(
                    ordinal: offset, 
                    url: url,
                    name: url.lastPathComponent.replacingOccurrences(of: fileExtension, with: ""),
                    fileExtension: fileExtension
                )
            }
        }
    }
    
    func moveTrack(from: IndexSet, to: Int) {
        Task { @MainActor [weak self] in
            guard let self else { return }
            self.tracks.move(fromOffsets: from, toOffset: to)
            for (index, _) in self.tracks.enumerated() {
                self.tracks[index].ordinal = index
            }
        }
    }
    
    func update(_ track: Track) {
        Task { @MainActor [weak self] in
            guard let self else { return }
            if let trackIndex = self.tracks.firstIndex(where: { $0.url == track.url }) {
                self.tracks[trackIndex].name = self.editedTrackName
                self.editedTrackName = ""
            }
        }
    }
    
    func remove(_ file: URL) {
        Task { @MainActor [weak self] in
            self?.tracks.removeAll(where: { $0.url == file })
        }
    }
    
    /// Convert chosen album cover item as image
    private func handle(picked item: PhotosPickerItem?) {
        Task { @MainActor [weak self] in
            if let data = try? await item?.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data){
                self?.albumCoverImage = Image(uiImage: uiImage)
            } else {
                self?.isError = true
            }
        }
    }
}

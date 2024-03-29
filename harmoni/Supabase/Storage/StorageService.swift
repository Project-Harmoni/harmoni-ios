//
//  StorageService.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/15/24.
//

import Foundation
import Supabase

protocol StorageProviding {
    func uploadSong(_ data: Data, name: String) async throws -> String
    func uploadImage(_ data: Data, name: String) async throws -> String
    func getMusicURL(for song: String) throws -> URL
    func getImageURL(for image: String) throws -> URL
}

struct StorageService: StorageProviding {
    func uploadSong(_ data: Data, name: String) async throws -> String {
        return try await Supabase.shared.client.storage
            .music
            .upload(
                path: name,
                file: data,
                options: .init(upsert: true)
            )
    }
    
    func uploadImage(_ data: Data, name: String) async throws -> String {
        return try await Supabase.shared.client.storage
            .images
            .upload(
                path: name,
                file: data,
                options: .init(
                    contentType: "image/jpeg",
                    upsert: true
                )
            )
    }
    
    func getMusicURL(for song: String) throws -> URL {
        return try Supabase.shared.client.storage
            .music
            .getPublicURL(path: song)
    }
    
    func getImageURL(for image: String) throws -> URL {
        return try Supabase.shared.client.storage
            .images
            .getPublicURL(path: image)
    }
}

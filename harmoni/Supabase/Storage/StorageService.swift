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
    func updateSong(_ data: Data, name: String) async throws -> String
    func updateImage(_ data: Data, name: String) async throws -> String
    func deleteSong(name: String) async throws
    func deleteImage(name: String) async throws
    func deleteAccountFiles(for user: String) async throws
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
    
    func updateSong(_ data: Data, name: String) async throws -> String {
        return try await Supabase.shared.client.storage
            .music
            .update(
                path: name,
                file: data
            )
    }
    
    func updateImage(_ data: Data, name: String) async throws -> String {
        return try await Supabase.shared.client.storage
            .images
            .update(
                path: name,
                file: data,
                options: .init(
                    contentType: "image/jpeg"
                )
            )
    }
    
    func deleteSong(name: String) async throws {
        _ = try await Supabase.shared.client.storage
            .music
            .remove(paths: [name])
    }
    
    func deleteImage(name: String) async throws {
        _ = try await Supabase.shared.client.storage
            .images
            .remove(paths: [name])
    }
    
    func deleteAccountFiles(for user: String) async throws {
        let imagePaths = try await Supabase.shared.client.storage
            .images
            .list(path: user)
        
        let songPaths = try await Supabase.shared.client.storage
            .music
            .list(path: user)
        
        if imagePaths.isNotEmpty {
            _ = try await Supabase.shared.client.storage
                .images
                .remove(paths: imagePaths.map { "\(user)/\($0.name)" })
        }
        
        if songPaths.isNotEmpty {
            _ = try await Supabase.shared.client.storage
                .music
                .remove(paths: songPaths.map { "\(user)/\($0.name)" })
        }
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

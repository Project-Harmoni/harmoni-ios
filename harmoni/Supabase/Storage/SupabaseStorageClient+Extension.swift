//
//  SupabaseStorageClient+Extension.swift
//  harmoni
//
//  Created by Kyle Stokes on 3/15/24.
//

import Foundation
import Supabase

fileprivate enum StorageBuckets: String {
    case music = "music"
    case images = "images"
}

extension SupabaseStorageClient {
    var music: StorageFileApi {
        Supabase.shared.client.storage
            .from(StorageBuckets.music.rawValue)
    }
    
    var images: StorageFileApi {
        Supabase.shared.client.storage
            .from(StorageBuckets.images.rawValue)
    }
}

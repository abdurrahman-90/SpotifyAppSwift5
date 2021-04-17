//
//  LibraryAlbumResponse.swift
//  SpotifyApp
//
//  Created by Akdag's Pro on 17.04.2021.
//

import Foundation

struct LibraryAlbumResponse: Codable {
    let items: [SavedAlbum]
}

struct SavedAlbum: Codable {
    let added_at: String
    let album: Album
}

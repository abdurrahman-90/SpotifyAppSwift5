//
//  SearchResult.swift
//  SpotifyApp
//
//  Created by Akdag's Pro on 15.04.2021.
//

import Foundation
enum SearchResult {
    case artist(model: Artist)
    case album(model: Album)
    case track(model: AudioTracks)
    case playlist(model: Playlist)
}

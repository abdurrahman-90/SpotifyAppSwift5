//
//  FeaturesPLayListResponsive.swift
//  SpotifyApp
//
//  Created by Akdag's Pro on 13.04.2021.
//

import Foundation
struct FeaturesPLayListResponsive  :Codable{
    let playlists : PlaylistResponsive
}
struct CategoryPLayListResponsive  :Codable{
    let playlists : PlaylistResponsive
}
struct PlaylistResponsive:Codable {
    let items : [Playlist]
}

struct User : Codable {
    let display_name : String
    let external_urls : [String :String]
    let id : String
}


//
//  SettingsModel.swift
//  SpotifyApp
//
//  Created by Akdag's Pro on 13.04.2021.
//

import Foundation
struct Section {
    let title : String
    let options : [Option]
}
struct Option {
    let title : String
    let handler : () -> Void
}

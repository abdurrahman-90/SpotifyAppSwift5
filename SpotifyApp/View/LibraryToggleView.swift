//
//  LibraryToggleView.swift
//  SpotifyApp
//
//  Created by Akdag's Pro on 17.04.2021.
//

import UIKit

protocol LibraryToggleViewDelegate : AnyObject {
    func libraryToggleViewDidTapPlaylists(_ toggleView : LibraryToggleView)
    func libraryToggleViewDidTapAlbums(_ toggleView : LibraryToggleView)
}

class LibraryToggleView: UIView {
    // gösterge çubuğunun hareket ettirme
    enum State {
        case playlist
        case albums
    }
    var state : State = .playlist
    
    var delegate : LibraryToggleViewDelegate?
    
    private let playlistButton : UIButton = {
        let button = UIButton()
        button.setTitle("Playlist", for: .normal)
        button.setTitleColor(.label, for: .normal)
        return button
    }()
    
    private let albumsButton : UIButton = {
        let button = UIButton()
        button.setTitle("Albums", for: .normal)
        button.setTitleColor(.label, for: .normal)
        return button
    }()
    
    // Buttonların altına gösterge ekleme
    private let indicator : UIView = {
        let view = UIView()
        view.backgroundColor = .systemGreen
        view.layer.cornerRadius = 4
        view.layer.masksToBounds = true
        return view
    }()


    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(playlistButton)
        addSubview(albumsButton)
        addSubview(indicator)
        
        playlistButton.addTarget(self, action: #selector(didTapPlaylistButton), for: .touchUpInside)
        albumsButton.addTarget(self, action: #selector(didTapAlbumsButton), for: .touchUpInside)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    @objc func didTapPlaylistButton(){
        state = .playlist
        UIView.animate(withDuration: 0.2){
            self.layoutIndicator()
        }
        delegate?.libraryToggleViewDidTapPlaylists(self)
    }
    @objc func didTapAlbumsButton(){
        state = .albums
        UIView.animate(withDuration: 0.2){
            self.layoutIndicator()
        }
        delegate?.libraryToggleViewDidTapAlbums(self)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playlistButton.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        albumsButton.frame = CGRect(x: playlistButton.right, y: 0, width: 100, height: 40)
        layoutIndicator()
    }

    func layoutIndicator(){
        switch state {
        case .playlist:
            indicator.frame = CGRect(x: 0, y: playlistButton.bottom, width: 100, height: 3)
        case .albums:
            indicator.frame = CGRect(x: 100, y: playlistButton.bottom, width: 100, height: 3)

        }
    }
    func update(for state : State) {
        self.state = state
        UIView.animate(withDuration: 0.2){
            self.layoutIndicator()
        }
    }
}

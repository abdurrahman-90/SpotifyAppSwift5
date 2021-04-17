//
//  LibraryViewController.swift
//  SpotifyApp
//
//  Created by Akdag's Pro on 12.04.2021.
//

import UIKit

class LibraryViewController: UIViewController {
    
    private let playlistVC = LibraryPlaylistsViewController()
    
    private let albumsVC = LibraryAlbumsViewController()
    
    private var scrollView : UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        return scrollView
    }()
    private let toggleView = LibraryToggleView()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        scrollView.delegate = self
        
        
        view.addSubview(toggleView)
        toggleView.delegate = self
        
        //sayfayı yana kaydırarark açma
        scrollView.contentSize = CGSize(width: view.width*2, height: scrollView.height)
       
        view.addSubview(scrollView)
        addChildren()
        updateBarButton()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = CGRect(
            x: 0,
            y: view.safeAreaInsets.top+55,
            width: view.width,
            height: view.height-view.safeAreaInsets.top-view.safeAreaInsets.bottom-55)
        toggleView.frame = CGRect(
            x: 0,
            y: view.safeAreaInsets.top,
            width: 200,
            height: 55)
    }
    private func updateBarButton(){
        switch toggleView.state {
        case .albums:
            navigationItem.rightBarButtonItem = nil
        case .playlist:
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAdd))
        }
    }
    @objc func didTapAdd(){
        playlistVC.showCreatePlaylistAlert()
    }
    //scrollview içine UIViewController ekleme
    private func addChildren(){
    addChild(playlistVC)
        scrollView.addSubview(playlistVC.view)
        playlistVC.view.frame = CGRect(
         x: 0,
         y: 0,
         width: scrollView.width,
         height: scrollView.height)
        playlistVC.didMove(toParent: self)
        
        addChild(albumsVC)
            scrollView.addSubview(albumsVC.view)
        albumsVC.view.frame = CGRect(
            x: view.width,
            y: 0,
            width: scrollView.width,
            height: scrollView.height)
            albumsVC.didMove(toParent: self)
    }

  
}
extension LibraryViewController : UIScrollViewDelegate {
    // gösterge ile beraber koordineli hareket
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x >= (view.width-100){
            toggleView.update(for: .albums)
            updateBarButton()
        }else {
            toggleView.update(for: .playlist)
            updateBarButton()
        }
        
    }
}
// Playlist ve album butonlarını etkinlik kazandırma
extension LibraryViewController : LibraryToggleViewDelegate {
    func libraryToggleViewDidTapPlaylists(_ toggleView: LibraryToggleView) {
        scrollView.setContentOffset(.zero, animated: true)
        updateBarButton()
    }
    func libraryToggleViewDidTapAlbums(_ toggleView: LibraryToggleView) {
        scrollView.setContentOffset(CGPoint(x: view.width, y: 0), animated: true)
        updateBarButton()
    }
}

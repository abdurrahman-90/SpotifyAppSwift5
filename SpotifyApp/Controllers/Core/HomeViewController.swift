//
//  ViewController.swift
//  SpotifyApp
//
//  Created by Akdag's Pro on 12.04.2021.
//

import UIKit
enum BrowseSectionType {
    case newReleases(viewsModel : [NewReleasesCellViewModel]) // 1
    case featuredPlaylists(viewsModel : [FeaturedPlaylistCellViewModel]) // 2
    case recommendedTracks(viewsModel : [RecommendedTracksCellViewModel]) // 3
    
    var title :String {
        switch self {
        case .newReleases:
            return "Yeni Çıkan Albüm"
        case .featuredPlaylists:
            return "Oynatma Listesinin Özelliği"
        case .recommendedTracks:
            return "Öneriler"
        }
    }
}

class HomeViewController: UIViewController {
    
    private var newAlbums : [Album] = []
    private var playlists : [Playlist] = []
    private var tracks : [AudioTracks] = []
    
    private var collectionView : UICollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewCompositionalLayout{ sectionIndex , _ -> NSCollectionLayoutSection? in
            return HomeViewController.createSectionLayout(section : sectionIndex)
            
        })
    //Navigasyon yazısı browse gizler
    private let spinner : UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView()
        spinner.tintColor = .label
        spinner.hidesWhenStopped = true
        return spinner
    }()
    private var sections = [BrowseSectionType]()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Browse"
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gear"),
                                                            style: .done, target: self,
                                                            action: #selector(didTapSetting))
       
        configureCollectionViewCell()
        fetchData()
        view.addSubview(spinner)
        addLongTapGesture() 
  
    }
    private func addLongTapGesture() {
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress(_:)))
        collectionView.isUserInteractionEnabled = true
        collectionView.addGestureRecognizer(gesture)
    }

    @objc func didLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else {
            return
        }

        let touchPoint = gesture.location(in: collectionView)
       

        guard let indexPath = collectionView.indexPathForItem(at: touchPoint),
              indexPath.section == 2 else {
            return
        }

        let model = tracks[indexPath.row]

        let actionSheet = UIAlertController(
            title: model.name,
            message: "Would you like to add this to a playlist?",
            preferredStyle: .actionSheet
        )

        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        actionSheet.addAction(UIAlertAction(title: "Add to Playlist", style: .default, handler: { [weak self] _ in
            DispatchQueue.main.async {
                let vc = LibraryPlaylistsViewController()
                vc.selectionHandler = { playlist in
                    APICaller.shared.addTrackToPlaylist(
                        track: model,
                        playlist: playlist
                    ) { success in
                        print("Added to playlist success: \(success)")
                    }
                }
                vc.title = "Select Playlist"
                self?.present(UINavigationController(rootViewController: vc),
                              animated: true, completion: nil)
            }
        }))

        present(actionSheet, animated: true)
    }

    
    private  func configureCollectionViewCell(){
        view.addSubview(collectionView)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.register(NewReleasesCollectionViewCell.self, forCellWithReuseIdentifier: NewReleasesCollectionViewCell.identifier)
        collectionView.register(FeaturedPlaylistCollectionViewCell.self, forCellWithReuseIdentifier: FeaturedPlaylistCollectionViewCell.identifier)
        collectionView.register(RecommendedTracksCollectionViewCell.self, forCellWithReuseIdentifier: RecommendedTracksCollectionViewCell.identifier)
        collectionView.register(TitleHeaderCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TitleHeaderCollectionReusableView.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .systemBackground
    }
  
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
    private func fetchData() {
        let group = DispatchGroup()
        group.enter()
        group.enter()
        group.enter()
        
        var newReleases : NewReleasesResponsive?
        var featuredPlaylist : FeaturesPLayListResponsive?
        var recommmendedGenres : RecommendationsResponse?
        // New Releases
        APICaller.shared.getNewReleases(completion: {result in
            defer{
                group.leave()
            }
            switch result {
            case .success(let model):
                newReleases = model
            case .failure(let error) :
                print(error.localizedDescription)
            }
        })
        // Featured Playlist
        APICaller.shared.getFeaturedPlayList(completion: {result in
            defer{
                group.leave()
            }
            switch result {
            case .success(let model):
                featuredPlaylist = model
            case .failure(let error):
                print(error.localizedDescription)
            }
        })
        //recommended tracks
        APICaller.shared.getRecommendationGenres(completion: {result in
            switch result {
            case .success(let model):
                let genres = model.genres
                var seeds = Set<String>()
                while seeds.count < 5 {
                    if let random = genres.randomElement() {
                        seeds.insert(random)
                    }
                }
                
                APICaller.shared.getRecomendations(genres: seeds) { (recommendedResult) in
                    defer{
                        group.leave()
                    }
                    switch recommendedResult {
                    case .success(let model) :
                        recommmendedGenres = model
                    case .failure(let error) :
                        print(error.localizedDescription)
                    }
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
            
        })
        group.notify(queue: .main) {
            guard let newAlbums = newReleases?.albums.items,
                  let playlists = featuredPlaylist?.playlists.items,
                  let tracks = recommmendedGenres?.tracks else {
                return
            }
            self.configureModels(newAlbums: newAlbums, playlist: playlists, tracks: tracks)
        }
        
    }
   
    
    private func configureModels(newAlbums : [Album],playlist : [Playlist] ,tracks : [AudioTracks]){
       
        self.newAlbums = newAlbums
        self.playlists = playlist
        self.tracks = tracks
        
        
        sections.append(.newReleases(viewsModel: newAlbums.compactMap({
            return NewReleasesCellViewModel(name: $0.name,
                                            artworkURL: URL(string: $0.images.first?.url ?? ""),
                                            numberOfTracks: $0.total_tracks,
                                            artistName: $0.artists.first?.name ?? "-")
        })))
        sections.append(.featuredPlaylists(viewsModel: playlist.compactMap({
            return FeaturedPlaylistCellViewModel(
               name: $0.name,
               artworkURL: URL(string: $0.images.first?.url ?? ""),
               creatorName: $0.owner.display_name)
        })))
        sections.append(.recommendedTracks(viewsModel: tracks.compactMap({
            return RecommendedTracksCellViewModel(
                name: $0.name,
                artistName: $0.artists.first?.name ?? "",
                artworkURL: URL(string: $0.album?.images.first?.url ?? ""))
        })))
        collectionView.reloadData()
    }
    
    @objc func didTapSetting(){
        let vc = SettingViewController()
        vc.title = "Setting"
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }


}
extension HomeViewController : UICollectionViewDelegate , UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       let type = sections[section]
        switch type{
        
        case .newReleases( let viewsModel):
            return viewsModel.count
        case .featuredPlaylists( let viewsModel):
            return viewsModel.count
        case .recommendedTracks( let viewsModel):
            return viewsModel.count
        }
      
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let type = sections[indexPath.section]
         switch type{
         
         case .newReleases( let viewsModel):
            guard  let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NewReleasesCollectionViewCell.identifier, for: indexPath) as? NewReleasesCollectionViewCell else {
                return UICollectionViewCell()
                
            }
            cell.backgroundColor = .red
            let viewModel = viewsModel[indexPath.row]
            cell.configure(with: viewModel)
            return cell
           
         case .featuredPlaylists( let viewsModel):
            guard  let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FeaturedPlaylistCollectionViewCell.identifier, for: indexPath) as? FeaturedPlaylistCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.configure(with: viewsModel[indexPath.row])
            return cell
         case .recommendedTracks( let viewsModel):
            guard  let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecommendedTracksCollectionViewCell.identifier, for: indexPath) as? RecommendedTracksCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.configure(with: viewsModel[indexPath.row])
            return cell
         }

       
       
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let section = sections[indexPath.section]
        switch section {
        case .newReleases:
            let album = newAlbums[indexPath.row]
            let vc = AlbumViewController(album: album)
            vc.title = album.name
            vc.navigationItem.largeTitleDisplayMode = .never
            self.navigationController?.pushViewController(vc, animated: true)
           
        case .featuredPlaylists:
            let playlist = playlists[indexPath.row]
            let vc = PlaylistViewController(playlist: playlist)
            vc.title = playlist.name
            vc.navigationItem.largeTitleDisplayMode = .never
            self.navigationController?.pushViewController(vc, animated: true)
            
        case .recommendedTracks:
            let track = tracks[indexPath.row]
            PlaybackPresenter.shared.startPlayback(from:self,track : track)
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TitleHeaderCollectionReusableView.identifier, for: indexPath) as? TitleHeaderCollectionReusableView , kind == UICollectionView.elementKindSectionHeader else{
            return UICollectionReusableView()
        }
        let section = indexPath.section
        let title = sections[section].title
        header.configure(with: title)
        return header
    }
    
    private static func createSectionLayout(section : Int)-> NSCollectionLayoutSection{
        let suplementaryViews = [
            NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(50)),
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top)
        ]
        switch section {
        case 0:
            //item
            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
                                                widthDimension: .fractionalWidth(1.0),
                                                heightDimension: .fractionalWidth(1.0)))
            item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
            //group erkanda gösterilecek kaç bölüm olduğu
            let verticalGroup = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(390)),
                subitem: item,
                count: 3)
            let horizontalGroup = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(0.9),
                    heightDimension: .absolute(390)),
                subitem: verticalGroup,
                count: 1)
            //Section
            let section = NSCollectionLayoutSection(group: horizontalGroup)
            section.orthogonalScrollingBehavior = .groupPaging
           section.boundarySupplementaryItems = suplementaryViews
            return section
        case 1 :
            //item
            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
                        widthDimension: .absolute(200 ),
                        heightDimension: .absolute(200)))
            item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 1)
            //group erkanda gösterilecek kaç bölüm olduğu
            let verticalGroup = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .absolute(200),
                         heightDimension: .absolute(400)),
                           subitem: item,
                            count: 2)
            let horizontalGroup = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(
                        widthDimension: .absolute(200),
                          heightDimension: .absolute(400)),
                            subitem: verticalGroup,
                             count: 1)
            //Section
            let section = NSCollectionLayoutSection(group: horizontalGroup)
            section.orthogonalScrollingBehavior = .continuous
            section.boundarySupplementaryItems = suplementaryViews
            return section
        case 2 :
            //item
            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
                                                widthDimension: .fractionalWidth(1.0),
                                                heightDimension: .fractionalWidth(1.0)))
            item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 1)
            //group erkanda gösterilecek kaç bölüm olduğu
            let verticalGroup = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1.0),
                        heightDimension: .absolute(80)),
                        subitem: item,
                         count: 1)
            
            //Section
            let section = NSCollectionLayoutSection(group: verticalGroup)
        
            section.boundarySupplementaryItems = suplementaryViews
            return section
        default :
            //item
            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
                                                widthDimension: .fractionalWidth(1.0),
                                                heightDimension: .absolute(120)))
            item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 1)
            //group erkanda gösterilecek kaç bölüm olduğu
            let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                                                            heightDimension: .absolute(390)),
                                                         subitem: item,
                                                         count: 1)
          
            //Section
            let section = NSCollectionLayoutSection(group: group)
            section.boundarySupplementaryItems = suplementaryViews
            return section
        }
        
    }
    
    
}


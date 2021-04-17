//
//  RecommendedTracksCollectionViewCell.swift
//  SpotifyApp
//
//  Created by Akdag's Pro on 15.04.2021.
//

import UIKit

class RecommendedTracksCollectionViewCell: UICollectionViewCell {
    static let identifier = "RecommendedTracksCollectionViewCell"
    private let albumCoverImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "photo")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let trackNameLabel : UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.numberOfLines = 0
        return label
    }()
    
  
    
    private let artistNameLAbel : UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.numberOfLines = 0
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .secondarySystemBackground
        contentView.addSubview(albumCoverImageView)
        contentView.addSubview(trackNameLabel)
        contentView.clipsToBounds = true
        contentView.addSubview(artistNameLAbel)
       
    }
    required init?(coder: NSCoder) {
        fatalError()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        albumCoverImageView.frame = CGRect(
            x: 5,
            y: 2,
            width: contentView.height-4,
            height: contentView.height-4)
        artistNameLAbel.frame = CGRect(
            x: albumCoverImageView.right+10,
            y: contentView.height/2,
            width: contentView.width-albumCoverImageView.right-15,
            height: contentView.height/2)
        trackNameLabel.frame = CGRect(
            x: albumCoverImageView.right+10,
            y: 0,
            width: contentView.width-albumCoverImageView.right-15,
            height: contentView.height/2)
    
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        trackNameLabel.text = nil
        artistNameLAbel.text = nil
        albumCoverImageView.image = nil
    }
    func configure(with viewModel : RecommendedTracksCellViewModel){
        trackNameLabel.text = viewModel.name
        artistNameLAbel.text = viewModel.artistName
        albumCoverImageView.sd_setImage(with: viewModel.artworkURL, completed: nil)
    }
}
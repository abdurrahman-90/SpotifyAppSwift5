//
//  FeaturedPlaylistCollectionViewCell.swift
//  SpotifyApp
//
//  Created by Akdag's Pro on 15.04.2021.
//

import UIKit

class FeaturedPlaylistCollectionViewCell: UICollectionViewCell {
    static let identifier = "FeaturedPlaylistCollectionViewCell"
    private let PlaylistConvertImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 4
        imageView.image = UIImage(systemName: "photo")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let PlaylistNameLabel : UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
  
    
    private let creatorNameLAbel : UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(PlaylistConvertImageView)
        contentView.addSubview(PlaylistNameLabel)
        contentView.clipsToBounds = true
        contentView.addSubview(creatorNameLAbel)
       
    }
    required init?(coder: NSCoder) {
        fatalError()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        creatorNameLAbel.frame = CGRect(
            x: 3,
            y: contentView.height-30,
            width: contentView.width-6,
            height: 30)
        PlaylistNameLabel.frame = CGRect(
            x: 3,
            y: contentView.height-60,
            width: contentView.width-6,
            height: 30)
        let imageSize = contentView.height-70
        PlaylistConvertImageView.frame = CGRect(
            x: (contentView.width-imageSize)/2,
            y: 3, width: imageSize,
            height: imageSize)
    
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        PlaylistNameLabel.text = nil
        creatorNameLAbel.text = nil
        PlaylistConvertImageView.image = nil
    }
    func configure(with viewModel : FeaturedPlaylistCellViewModel){
        PlaylistNameLabel.text = viewModel.name
        creatorNameLAbel.text = viewModel.creatorName
        PlaylistConvertImageView.sd_setImage(with: viewModel.artworkURL, completed: nil)
    }
}

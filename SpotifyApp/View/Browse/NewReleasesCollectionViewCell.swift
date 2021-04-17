//
//  NewReleasesCollectionViewCell.swift
//  SpotifyApp
//
//  Created by Akdag's Pro on 15.04.2021.
//

import UIKit
import SDWebImage

class NewReleasesCollectionViewCell: UICollectionViewCell {
    static let identifier = "NewReleasesCollectionViewCell"
    private let albumConvertImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "photo")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let albumNameLabel : UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .semibold)
        label.numberOfLines = 0
        return label
    }()
    
    private let numberOfTracks : UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .light)
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
        contentView.addSubview(albumConvertImageView)
        contentView.addSubview(albumNameLabel)
        contentView.clipsToBounds = true
        contentView.addSubview(artistNameLAbel)
        contentView.addSubview(numberOfTracks)
    }
    required init?(coder: NSCoder) {
        fatalError()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        let imageSize : CGFloat = contentView.height - 10
        let albumLabelSize = albumNameLabel.sizeThatFits(
            CGSize(
                width: contentView.width - imageSize - 10,
                height:contentView.height - 10
                )
        )
        
        albumNameLabel.sizeToFit()
        numberOfTracks.sizeToFit()
        artistNameLAbel.sizeToFit()
        
        
        albumConvertImageView.frame = CGRect(x: 5, y: 5, width: imageSize, height: imageSize)
        let albumHeight = min(60, albumLabelSize.height)
        
        albumNameLabel.frame = CGRect(
            x: albumConvertImageView.right + 10,
            y: 5,
            width: albumLabelSize.width,
            height: albumHeight)
        
        artistNameLAbel.frame = CGRect(
            x: albumConvertImageView.right + 10,
            y: albumNameLabel.bottom,
            width: contentView.width-albumConvertImageView.right-10,
            height: 30)
        
        numberOfTracks.frame = CGRect(
            x: albumConvertImageView.right + 10,
            y: contentView.bottom - 44,
            width: numberOfTracks.width,
            height: 44)
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        albumNameLabel.text = nil
        artistNameLAbel.text = nil
        numberOfTracks.text = nil
        albumConvertImageView.image = nil
    }
    func configure(with viewModel : NewReleasesCellViewModel){
        albumNameLabel.text = viewModel.name
        artistNameLAbel.text = viewModel.artistName
        numberOfTracks.text = "Tracks : \(viewModel.numberOfTracks)"
        albumConvertImageView.sd_setImage(with: viewModel.artworkURL, completed: nil)
    }
}

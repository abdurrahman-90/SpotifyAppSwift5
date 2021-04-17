//
//  AlbumTrackCoolectionViewCell.swift
//  SpotifyApp
//
//  Created by Akdag's Pro on 15.04.2021.
//

import UIKit

class AlbumTrackCollectionViewCell: UICollectionViewCell {
    static let identifier = "AlbumTrackCollectionViewCell"

    
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
      
        contentView.addSubview(trackNameLabel)
        contentView.clipsToBounds = true
        contentView.addSubview(artistNameLAbel)
       
    }
    required init?(coder: NSCoder) {
        fatalError()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
      
        artistNameLAbel.frame = CGRect(
            x: 10,
            y: contentView.height/2,
            width: contentView.width-15,
            height: contentView.height/2)
        trackNameLabel.frame = CGRect(
            x: 10,
            y: 0,
            width: contentView.width-15,
            height: contentView.height/2)
    
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        trackNameLabel.text = nil
        artistNameLAbel.text = nil
       
    }
    func configure(with viewModel : AlbumCollectionViewCellModel){
        trackNameLabel.text = viewModel.name
        artistNameLAbel.text = viewModel.artistName
       
    }
}


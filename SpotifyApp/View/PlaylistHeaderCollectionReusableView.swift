//
//  PlaylistHeaderCollectionReusableView.swift
//  SpotifyApp
//
//  Created by Akdag's Pro on 15.04.2021.
//
import SDWebImage
import UIKit
protocol PLaylistHeaderCollectionReusableViewDelegate: AnyObject {
    func pLaylistHeaderCollectionReusableViewDidTapPlayAll(_ header : PlaylistHeaderCollectionReusableView)
}

final class PlaylistHeaderCollectionReusableView: UICollectionReusableView {
    static let identifier = "PlaylistHeaderCollectionReusableView"
    weak var delegate: PLaylistHeaderCollectionReusableViewDelegate?
    
    private let nameLabel : UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .semibold)
        return label
    }()
    private let descriptionLabel : UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 18, weight: .regular)
        return label
    }()
    private let ownerLabel : UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 18, weight: .light)
        return label
    }()
    private let imageView : UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "photo")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    private let playButton : UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemGreen
        //play tuşundaki üçgni ayarlama
        let image = UIImage(systemName: "play.fill",withConfiguration: UIImage.SymbolConfiguration(pointSize: 30, weight: .regular))
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.layer.cornerRadius = 25
        button.layer.masksToBounds = true
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        addSubview(nameLabel)
        addSubview(descriptionLabel)
        addSubview(ownerLabel)
        addSubview(imageView)
        addSubview(playButton)
        playButton.addTarget(self, action: #selector(TappedPlaybutton), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    @objc func TappedPlaybutton(){
        delegate?.pLaylistHeaderCollectionReusableViewDidTapPlayAll(self)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        let imageSize : CGFloat = height / 1.5
        imageView.frame = CGRect(x: (width-imageSize)/2, y: 20, width: imageSize, height: imageSize)
        nameLabel.frame = CGRect(x: 10, y: imageView.bottom, width: width-20, height: 44)
        descriptionLabel.frame = CGRect(x: 10, y: nameLabel.bottom-10, width: width-20, height: 44)
        ownerLabel.frame = CGRect(x: 10, y: descriptionLabel.bottom-20, width: width-20, height: 44)
        playButton.frame = CGRect(x: width-60, y: height-50, width: 50, height: 50)
        
    }
    
    func configure(with viewModel : PlaylistHeaderViewModel){
        nameLabel.text = viewModel.name
        descriptionLabel.text = viewModel.description
        ownerLabel.text = viewModel.ownerName
        
        imageView.sd_setImage(with: viewModel.artworkURL, completed: nil)
    }
}

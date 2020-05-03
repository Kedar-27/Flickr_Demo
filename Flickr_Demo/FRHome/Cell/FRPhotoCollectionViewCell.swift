//
//  FRPhotoCollectionViewCell.swift
//  Flickr_Demo
//
//  Created by Kedar Sukerkar on 03/05/20.
//  Copyright © 2020 Kedar-27. All rights reserved.
//

import UIKit
import Kingfisher
class FRPhotoCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Outlets
    var photoImageView: UIImageView = {
       let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    
    // MARK: - Properties
    
    
    
    
    // MARK: - UIView
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        // Initialization code
        self.setupView()
        self.setupConstraints()

    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
        
    func setupView(){
        self.addSubview(self.photoImageView)
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.photoImageView.image = nil
    }
    
    
    func setupConstraints(){
        [
        self.photoImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
        self.photoImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
        self.photoImageView.widthAnchor.constraint(equalTo: self.widthAnchor),
        self.photoImageView.heightAnchor.constraint(equalTo: self.heightAnchor)
        ].forEach({$0.isActive = true})
    }
    
    func configureCell(image: String){
        
        self.photoImageView.kf.setImage(with: URL(string: image))
    }
}

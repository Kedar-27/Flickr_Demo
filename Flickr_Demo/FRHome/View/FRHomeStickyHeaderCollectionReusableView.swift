//
//  FRHomeStickyHeaderCollectionReusableView.swift
//  Flickr_Demo
//
//  Created by Kedar Sukerkar on 04/05/20.
//  Copyright © 2020 Kedar-27. All rights reserved.
//

import UIKit

class FRHomeStickyHeaderCollectionReusableView: UICollectionReusableView {
    
    // MARK: - Outlets
    var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.text = ""
        label.numberOfLines = 1
        return label
    }()
    
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .gray
        // Customize here
        self.setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    func setupConstraints(){
        self.addSubview(self.titleLabel)
        [
            self.titleLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            self.titleLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            self.titleLabel.widthAnchor.constraint(equalTo: self.widthAnchor),
            self.titleLabel.heightAnchor.constraint(equalTo: self.heightAnchor)
            ].forEach({$0.isActive = true})
    }
    
    func configureView(title: String){
        
        self.titleLabel.text = "Page No. " + title
    }

}

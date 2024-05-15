//
//  ItemCollectionViewCell.swift
//  GooglePictures
//
//  Created by Ivan on 13.04.2024.
//

import UIKit

class ItemCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.imageView.image = nil
    }
    
    func configure(with picture: UIImage) {
        imageView.image = picture
    }
}
  


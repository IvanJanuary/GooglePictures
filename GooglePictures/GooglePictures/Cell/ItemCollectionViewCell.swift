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
    
    func configure(with urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data, error == nil else { return }
            
            DispatchQueue.main.async {
                let image = UIImage(data: data)
                self?.imageView.image = image
            }
        }
        .resume()
    }
    
//    var picture: Picture? {
//        didSet {
//            guard let image = picture?.name else { return }
//            imageView.image = UIImage(named: image)
//        }
//    }
//
//
//    func setupCell(picture: Picture) {
//        self.imageView.image = picture.image
//    }
}

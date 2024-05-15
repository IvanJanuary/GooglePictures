//
//  DetailViewController.swift
//  GooglePictures
//
//  Created by Ivan on 14.04.2024.
//

import UIKit

class DetailViewController: UIViewController {
    
    var apiHelper = ApiHelper()
    var picture: UIImage?
    
    @IBOutlet weak var imageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imageView.image = picture
    }
    
    @IBAction func downloadButtonTapped(_ sender: UIButton) {
        if let image = imageView.image {
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            print("Error saving image: \(error.localizedDescription)")
        } else {
            print("Image saved successfully")
        }
    }
}

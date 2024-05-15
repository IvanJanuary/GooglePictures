//
//  ViewController.swift
//  GooglePictures
//
//  Created by Ivan on 12.04.2024.
//

import UIKit

class ViewController: UIViewController, UISearchResultsUpdating {
    
    let idCell = "picCell"
    let searchController = UISearchController(searchResultsController: nil)
    var itemCollectionArray = ["AtlanticPuffin.jpg", "DrinkingJaguar", "GreenTurtle.jpg"]
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Search"
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
        
        collectionView.dataSource = self
        collectionView.delegate = self
    }

    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else {
            return
        }

        print(text)
    }
}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemCollectionArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let itemCell = collectionView.dequeueReusableCell(withReuseIdentifier: "picCell", for: indexPath) as? ItemCollectionViewCell else {
            
            itemCell = itemCollectionArray[indexPath.row]
            return itemCell
        }
        return UICollectionViewCell()
    }
    
    
}

